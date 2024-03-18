/*
 * Copyright (C) %{CURRENT_YEAR} by %{AUTHOR} <%{EMAIL}>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as
 * published by the Free Software Foundation; either version 2 or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

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
