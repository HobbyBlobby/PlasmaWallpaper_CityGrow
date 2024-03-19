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

import QtQuick 2.0

import org.kde.plasma.core
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

import "code/city.js" as City

WallpaperItem {
    id: wallpaper;
    
    Canvas {
        id: root
        anchors.fill: parent
        property bool running: windowModel.runSimulation
        onRunningChanged: pauseOnHide()
        
        WindowModel {
            id: windowModel
        }
        
        property var screen: Screen
        property var screenSize: !!screen.geometry ? Qt.size(screen.geometry.width, screen.geometry.height):  Qt.size(screen.width, screen.height)
        
        function pauseOnHide() {
            if(root.running) {
                stepTimer.start();
            } else {
                stepTimer.stop();
                resetTimer.stop(); // in case we are in the state of waiting for new restart
                // the reset timer will automatically be started, if the stepTimer is started, but no brnaches are available in the "city"
            }
        }
        
        onPaint: {
            // if(!root.running) {stepTimer.stop();}
            var ctx = getContext("2d");
            var bRunning = City.paintMatrix(ctx, screenSize, wallpaper.configuration);
            if(!bRunning) {
                stepTimer.stop();
                resetTimer.start();
            };
        }
    
        // onWidthChanged: {
        //     stepTimer.stop();
        //     City.dimensionChanged(width,height, wallpaper.configuration);
        //     stepTimer.start();
        // }
        // onHeightChanged: {
        //     stepTimer.stop();
        //     City.dimensionChanged(width,height, wallpaper.configuration);
        //     stepTimer.start();
        // }
    
        Timer {
            id: stepTimer
            interval: 40
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: {
                root.requestPaint();
            }
    
        }
        
        Timer {
            id: resetTimer
            interval: 5000
            repeat: false
            running: false
            triggeredOnStart: false
            onTriggered: {
                City.restart(root.getContext("2d"), wallpaper.configuration);
                stepTimer.start();
            }
        }
    }
}
