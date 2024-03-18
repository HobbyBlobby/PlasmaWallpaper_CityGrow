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

var max_steps_back = 300; //> config

var lightness_default = 130;
var lightness_branch = 50;

var cells = [];
var branchList = [];

var width = 100;
var height = 100;
var firstDraw = true;
var config_save = null;
var size_save = null;

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
    }
    getColor() {
        return 'hsl(' + this.hue + ',' + this.saturation + ',' + this.lightness + ')';
    }
    createLine(toPos, context, fromPos = null) {
        if(!fromPos) {
            fromPos = this.pos;
        }
        context.lineWidth = 2;
        context.strokeStyle = this.getColor();
        context.beginPath();
        context.moveTo(2*SIZE*fromPos.x, 2*SIZE*fromPos.y);
        context.lineTo(2*SIZE*toPos.x, 2*SIZE*toPos.y);
        context.stroke();
        this.pos = toPos;
        this.ownFields.push(toPos);
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

    cell_count_x = Math.round(width / config.scale / 2);
    cell_count_y = Math.round(height / config.scale / 2);

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
}

function dimensionChanged(width,height, config) {
  width = width; 
  height = height;
  initialize(config);
}

function paintMatrix(ctx, size, config){    
    if(config != config_save || size != size_save) {
        width = size.width;
        height = size.height;
        restart(ctx, config);
        config_save = config;
        size_save = size;
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
            }
        }
    });
    branchList = branchList.filter(branch => {
        branch.drawMove(ctx);
        return branch.state === "RUNNING";
    });
    if(branchList.length === 0) {
        return false;
    }
    return true;
}

function restart(ctx, config) {
    ctx.reset();
    initialize(config);
}

function testDraw(ctx) {
            ctx.lineWidth = 5;
            ctx.strokeStyle = 'cyan';
            ctx.beginPath();
            ctx.moveTo(500, 500);
            ctx.lineTo(500+Math.round(Math.random()*100), 500+Math.round(Math.random()*100));
            ctx.stroke();
}

