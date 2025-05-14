// The MIT License
// 
// Copyright (c) 2024 Felix Lemke
// 
// Permission is hereby granted, free of charge, 
// to any person obtaining a copy of this software and 
// associated documentation files (the "Software"), to 
// deal in the Software without restriction, including 
// without limitation the rights to use, copy, modify, 
// merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom 
// the Software is furnished to do so, 
// subject to the following conditions:
// 
// The above copyright notice and this permission notice 
// shall be included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

var cell_count_x = 0;
var cell_count_y = 0;
// var SIZE = wallpaper.configuration.scale; // default = 3
var SIZE = 3; // default = 3

var lifeTime = 8000; //> config
var lifeTime_branch = 15; //> config
var prop_city2land = 12.0; //> config
var prop_land2city = 0.003;
var prop_branchOff =15; //> config
var prop_branchOff_land = 6; //> config
var prop_branchOff_tomain = 1;
var branch_fallOff = 50;
var change_hue_newMain = 9;
// var start_branches = wallpaper.configuration.start_branches; // 3
var start_branches = 0;
// var start_branches = 3; // 3
var showReverse = true;//wallpaper.configuration.show_reverse; // true
var fillCity = true;//wallpaper.configuration.fill_city; // true

var max_steps_back = 300; //> config

var lightness_default = 140;
var lightness_branch = 60;

var cells = [];
var branchList = [];

var width = 100;
var height = 100;
var firstDraw = true;
var config_save = null;
var size_save = null;
var reverseRunning = false;

var cells = [];
var branchList = [];
var allBranches = [];

class StackEntry {
    constructor(type, par1, par2, par3, par4) {
        this.type = type; // LINE or RECT
        this.par1 = par1;
        this.par2 = par2;
        this.par3 = par3;
        this.par4 = par4;
    }
}
var history = [];

class Pos {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }
    toIdx(off_x = 0, off_y = 0) {
        return (this.y + off_y) * cell_count_x + (this.x + off_x);
    }
    static fromIdx(idx) {
        let y = Math.floor(idx / cell_count_x);
        let x = idx - y * cell_count_x;
        return new Pos(x, y);
    }
}

class Branch {
    constructor(pos) {
        this.pos = pos;
        this.state = "RUNNING";
        this.mode = "CITY";
        this.expandDirection = new Pos(0,0);
        this.ownFields = [pos];
        this.age = 0;
        this.lifeTime = lifeTime;
        this.hue = Math.round(Math.random() * 255);
        this.saturation = 255;
        this.lightness = lightness_default;
        this.history = [];
    }
    getColor() {
        return 'hsl(' + this.hue + ',' + this.saturation + ',' + this.lightness + ')';
    }
    getSecondaryColor() {
      return 'hsla(' + this.hue + ',' + this.saturation + ',' + this.lightness + ', 0.25)';
    }
    createLine(toPos, context, fromPos = null) {
        if(!fromPos) {
            fromPos = this.pos;
        }
        let width = 2;
        let offset = width / 2.0; // this is to move the line away from the screen corner (due to the linewidth)
        if(this.mode === "LAND") {
          width = 2;
        }
        let margin = width / 2.0; // this is to avoid overlap of filled squares with lines
        if(fillCity && this.mode === "CITY") {
            if(this.ownFields.length >= 1) {
                // what happens here: 
                // 1) take the line from the lastPosition to the newPositon
                let lastPosition = this.ownFields[this.ownFields.length-1];
                // 2) calculate the perpendicular direction (with length 1)
                let perpendicular = new Pos(toPos.y - lastPosition.y, toPos.x - lastPosition.x);
                // 3) add the perpendicular vector the lastPosition > there is an imaginary square
                let imaginaryPoint = new Pos(lastPosition.x + perpendicular.x, lastPosition.y + perpendicular.y);
                // 4) find the top left corner (always the point with minimal x and y)
                let leftTop = new Pos(Math.min(toPos.x, imaginaryPoint.x), Math.min(toPos.y, imaginaryPoint.y));
                // 5) draw a filled rect with topLeft Point and width/height = 1 (but scaled with grid Size and additional margin to not overlap with lines)
                context.fillStyle = this.getSecondaryColor();
                context.globalCompositeOperation = 'overlay';
                context.fillRect(2*SIZE*leftTop.x+margin+offset, 2*SIZE*leftTop.y+margin+offset, 2*SIZE-2*margin, 2*SIZE-2*margin);
                this.history.push(new StackEntry("RECT", 2*SIZE*leftTop.x+margin+offset, 2*SIZE*leftTop.y+margin+offset, 2*SIZE-2*margin, 2*SIZE-2*margin));
                // 6) repeat step 2, but mirrored at the line (so basically -x and -y of the first perpendicular vector)
                perpendicular = new Pos(- toPos.y + lastPosition.y, - toPos.x + lastPosition.x);
                // 7) get new imaginary rect (on the other side of the line), find topLeft corner, draw rect
                imaginaryPoint = new Pos(lastPosition.x + perpendicular.x, lastPosition.y + perpendicular.y);
                leftTop = new Pos(Math.min(toPos.x, imaginaryPoint.x), Math.min(toPos.y, imaginaryPoint.y));
                context.fillRect(2*SIZE*leftTop.x+margin+offset, 2*SIZE*leftTop.y+margin+offset, 2*SIZE-2*margin, 2*SIZE-2*margin);
                this.history.push(new StackEntry("RECT", 2*SIZE*leftTop.x+margin+offset, 2*SIZE*leftTop.y+margin+offset, 2*SIZE-2*margin, 2*SIZE-2*margin));
            }
        }

        context.globalCompositeOperation = 'source-over';
        context.lineWidth = width;
        context.strokeStyle = this.getColor();
        context.beginPath();
        context.moveTo(2*SIZE*fromPos.x+offset, 2*SIZE*fromPos.y+offset);
        context.lineTo(2*SIZE*toPos.x+offset, 2*SIZE*toPos.y+offset);
        this.history.push(new StackEntry("LINE", 2*SIZE*fromPos.x+offset, 2*SIZE*fromPos.y+offset, 2*SIZE*toPos.x+offset, 2*SIZE*toPos.y+offset));
        context.stroke();
        this.pos = toPos;
        this.ownFields.push(toPos);
    }


    static reverseLine(context, stackEntry) {
        let width = 2;
        let offset = width / 2.0;
        context.globalCompositeOperation = 'source-over';
        if(stackEntry.type === "RECT") {
            context.fillStyle = "#000";
            context.strokeStyle = null;
            context.fillRect(stackEntry.par1, stackEntry.par2, stackEntry.par3, stackEntry.par4);
        }
        if(stackEntry.type === "LINE") {
            context.lineWidth = width;
            context.strokeStyle = "#000";
            context.beginPath();
            context.moveTo(stackEntry.par1, stackEntry.par2);
            context.lineTo(stackEntry.par3, stackEntry.par4);
            context.stroke();
        }
    }

    moveToNewPos() {
        for(let i = this.ownFields.length-1; i >= Math.max(0, this.ownFields.length - max_steps_back); i--) {
            let testPos = this.ownFields[i];
            if(this.getFreeFields(testPos).length > 0) {
                this.pos = testPos;
                return true;
            }
        }
        return false;
    }
    getFreeFields(pos = null) {
        if(!pos) { pos = this.pos; }
        let freeFields = [];
        if (pos.x + 1 < cell_count_x && cells[pos.toIdx(1,0)] === 0) {
            freeFields.push(new Pos(pos.x+1, pos.y));
        }
        if (pos.x - 1 > 0 && cells[pos.toIdx(-1,0)] === 0) {
            freeFields.push(new Pos(pos.x-1, pos.y));
        }
        if (pos.y + 1 < cell_count_y && cells[pos.toIdx(0,1)] === 0) {
            freeFields.push(new Pos(pos.x, pos.y+1));
        }
        if (pos.x - 1 > 0 && cells[pos.toIdx(0,-1)] === 0) {
            freeFields.push(new Pos(pos.x, pos.y-1));
        }
        return freeFields;
    }
    findNextMove() {
        if(this.state !== "RUNNING") {return null;}
        let freeFields = this.getFreeFields();
        if(freeFields.length === 0) {
            if(this.moveToNewPos()) {
                return this.findNextMove();
            }
            this.state = "STOPPED";
            return null;
        }
        if(this.lifeTime - this.age < lifeTime_branch) {
            this.mode = "CITY";
        } else {
            if(this.mode === "LAND") {
                let expandField = new Pos(this.pos.x + this.expandDirection.x, this.pos.y + this.expandDirection.y);
                if (freeFields.find(field => {return field.x === expandField.x && field.y === expandField.y })) {
                    for(let i = 0; i < 10; i++) {
                        freeFields.push(expandField);
                    }
                } else {
                    this.mode = "CITY";
                    this.age = Math.round(Math.random() * this.age);
                }
            }
        }
        return freeFields[Math.round(Math.random() * (freeFields.length-1))];
    }
    setExpandDirection() {
        let freeFields = this.getFreeFields();
        if(freeFields.length === 0) {return;}
        let targetPos = randomChoice(freeFields);
        this.expandDirection = new Pos(targetPos.x - this.pos.x, targetPos.y - this.pos.y);
    }
    drawMove(context) {
        if(this.age >= this.lifeTime) {
            this.state = "STOPPED";
            return null;
        }
        if(this.mode === "CITY" && Math.random() <= prop_city2land/100.0) {
            this.mode = "LAND";
            this.setExpandDirection();
        } else if(this.mode === "CITY" && Math.random() <= prop_land2city/100.0) {
            this.mode = "CITY";
            this.age = Math.round(Math.random() * this.age);
        }
        let newPos = this.findNextMove();
        if(!newPos) {
            return null;
        }
        this.createLine(newPos, context);
        this.age++;
        cells[newPos.toIdx()] = 1;
    }
    setMain() {
        this.saturation = 255;
        this.lightness = lightness_default;
        this.hue += change_hue_newMain;
        if(this.hue > 255) {
            this.hue -= 255;
        }
        this.lifeTime = lifeTime;
    }
    branchOff(context) {
        if(this.ownFields.length <= 1) {return null;}
        let searchPos = this.ownFields[this.ownFields.length-1];
        let freeFields = this.getFreeFields(searchPos);
        if(freeFields.length === 0) {return null;}
        let newPos = randomChoice(freeFields);
        this.createLine(newPos, context, searchPos);
        let newBranch = new Branch(this.pos);
        newBranch.hue = this.hue;
        newBranch.lightness = lightness_branch;
        newBranch.lifeTime = lifeTime_branch;
        cells[newPos.toIdx()] = 1;
        return newBranch;
    }
}

function randomChoice(fromList) {
    return fromList[Math.round(Math.random() * (fromList.length-1))];
}

function randomPos() {
    return Pos.fromIdx(Math.round(Math.random() * cells.length));
}

function initialize(config) {
    start_branches = config.start_branches;
    SIZE = config.scale;
    showReverse = config.show_reverse;
    fillCity = config.fill_city;

    cell_count_x = Math.round(width / config.scale / 2);
    cell_count_y = Math.round(height / config.scale / 2);

    allBranches = [];
    reverseRunning = false;
    firstDraw = true;
    for(let y=0;y<cell_count_y;y++) {
        for(let x=0;x<cell_count_x;x++) {
            let idx = y*cell_count_x+x;
            cells[idx] = 0;
        }
    }
    branchList = [];
    for(let i = 0; i < start_branches; i++) {
        branchList.push(new Branch(randomPos()));
    }
    allBranches = branchList;
    console.log("Initialize the City");
}

function dimensionChanged(width,height) {
  cell_count_x = Math.round(width / SIZE / 2);
  cell_count_y = Math.round(height / SIZE / 2);
  initialize();
}

function paintMatrix(ctx, size, config){    
    if(config != config_save || size != size_save) {
        width = size.width;
        height = size.height;
        restart(ctx, config);
        config_save = config;
        size_save = size;
    }
    
    if(reverseRunning === true) {
        if(showReverse === false) {
            return false;
        }
        allBranches = allBranches.filter(branch => {
            if(branch.history.length === 0) {
                return false;
            }
            // const reversePoints = branch.mode === "CITY" ? 200/allBranches.length : 1;
            const reversePoints = Math.ceil(50/allBranches.length);
            for(let i = 0; i < Math.min(branch.history.length, reversePoints); i++) {
                let lastAction = branch.history.pop();
                Branch.reverseLine(ctx, lastAction);
            };
            return true;
        });
        if(allBranches.length === 0) {
            return false;
        }

        return true;
    }
    
    branchList.forEach(oldBranch => {
        let scaled_branchOff = prop_branchOff * (1.0+branch_fallOff) / (branch_fallOff + branchList.length);
        let scaled_branchOff_land = prop_branchOff_land * (1.0+branch_fallOff) / (branch_fallOff + branchList.length);
        if((oldBranch.mode === "CITY" && Math.random() <= scaled_branchOff/100.0) || (oldBranch.mode === "LAND" && Math.random() <= scaled_branchOff_land/100.0)) {
            let newBranch = oldBranch.branchOff(ctx);
            if(newBranch) {
                if(Math.random() <= prop_branchOff_tomain/100.0) {
                    newBranch.setMain();
                }
                branchList.push(newBranch);
                allBranches.push(newBranch);
            }
        }
    });
    branchList = branchList.filter(branch => {
        branch.drawMove(ctx);
        return branch.state === "RUNNING";
    });
    if(branchList.length === 0) {
        reverseRunning = true;
        return true;
    }
    return true;
}

function restart(ctx, config) {
    ctx.reset();
    allBranches = [];
    reverseRunning = false;
    firstDraw = true;
    initialize(config);
}
