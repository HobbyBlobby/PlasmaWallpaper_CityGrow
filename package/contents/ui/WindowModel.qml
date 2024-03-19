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


// Large parts of this code is copied from the smart video wallpaper (by ADHE)
// https://store.kde.org/p/1316299 

import QtQuick
import QtQuick.Window
import org.kde.taskmanager as TaskManager
import org.kde.plasma.core as PlasmaCore
import org.kde.kitemmodels as KItemModels

Item {
    id: wModel
    property alias screenGeometry: tasksModel.screenGeometry
    property bool runSimulation: true
    property bool checkSmartPlay: wallpaper.configuration.checkedSmartPlay
    property var screen: Screen

    TaskManager.VirtualDesktopInfo { id: virtualDesktopInfo }
    TaskManager.ActivityInfo { id: activityInfo }
    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled

        activity: activityInfo.currentActivity
        virtualDesktop: virtualDesktopInfo.currentDesktop
        screenGeometry: wallpaper.screenGeometry  || Qt.rect(screen.virtualX, screen.virtualY, screen.width, screen.height) // take virtual coordinates for multiple displays

        filterByActivity: true
        filterByVirtualDesktop: true
        filterByScreen: true
        
        onActiveTaskChanged: updateWindowsinfo(wModel.checkSmartPlay)
        onDataChanged: updateWindowsinfo(wModel.checkSmartPlay)
        Component.onCompleted: {
            maximizedWindowModel.sourceModel = tasksModel
            fullScreenWindowModel.sourceModel = tasksModel
            onlyWindowsModel.sourceModel = tasksModel
            minimizedWindowModel.sourceModel = tasksModel
        }
    }

    KItemModels.KSortFilterProxyModel {
        id: maximizedWindowModel
        filterRoleName: 'IsMaximized'
        filterRegularExpression: RegExp("true")
        onDataChanged: updateWindowsinfo(wModel.checkSmartPlay)
        onCountChanged: updateWindowsinfo(wModel.checkSmartPlay)
    }
    KItemModels.KSortFilterProxyModel {
        id: fullScreenWindowModel
        filterRoleName: 'IsFullScreen'
        filterRegularExpression: RegExp("true")
        onDataChanged: updateWindowsinfo(wModel.checkSmartPlay)
        onCountChanged: updateWindowsinfo(wModel.checkSmartPlay)
    }
    KItemModels.KSortFilterProxyModel {
        id: onlyWindowsModel
        filterRoleName: 'IsWindow'
        filterRegularExpression: RegExp("true")
        onDataChanged: updateWindowsinfo(wModel.checkSmartPlay)
        onCountChanged: updateWindowsinfo(wModel.checkSmartPlay)
    }
    KItemModels.KSortFilterProxyModel {
        id: minimizedWindowModel
        filterRoleName: 'IsMinimized'
        filterRegularExpression: RegExp("true")
        onDataChanged: updateWindowsinfo(wModel.checkSmartPlay)
        onCountChanged: updateWindowsinfo(wModel.checkSmartPlay)
    }

    function updateWindowsinfo(checkActive) {
        if(!checkActive) {
            runSimulation = true;
            return;
        }
        if(maximizedWindowModel.count + fullScreenWindowModel.count > 0) {
            // we have full screen and/or maximized Windows > but the can be minimized at the same time > have a closer look
            var joinApps  = [];
            var minApps  = [];
            var aObj;
            var i;
            var j;
            // add fullscreen apps
            findAppIds(fullScreenWindowModel, joinApps);
            // add maximized apps
            findAppIds(maximizedWindowModel, joinApps);
            // add minimized apps
            findAppIds(minimizedWindowModel, minApps);
            joinApps = removeDuplicates(joinApps) // for qml Kubuntu 18.04
            
            joinApps.sort();
            minApps.sort();

            var twoStates = 0
            j = 0;
            for(i = 0 ; i < minApps.length ; i++){
                if(minApps[i] === joinApps[j]){
                    twoStates = twoStates + 1;
                    j = j + 1;
                }
            }

            if(fullScreenWindowModel.count + maximizedWindowModel.count - twoStates > 0) {
                runSimulation = false;
                return;
            }
        }
        runSimulation = true;
    }
    
    function findAppIds(model, arr) {
        for(let row = 0; row < model.rowCount(); row++) {
            for(let column = 0 ; column < model.columnCount(); column++) {
                let aObj = model.data(model.index(row,column));
                arr.push(aObj);
            }
        }
        return arr;
    }
    
    function removeDuplicates(arrArg) {
        return arrArg.filter(function(elem, pos,arr) {
            return arr.indexOf(elem) == pos;
        });
    }

}
