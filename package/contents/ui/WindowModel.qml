// Large parts of this code is copied from the smart video wallpaper
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
        screenGeometry: wallpaper.screenGeometry || Qt.rect(0, 0, screen.width, screen.height) // default QRect for init process

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
            for (i = 0 ; i < fullScreenWindowModel.count ; i++){
                aObj = fullScreenWindowModel.data(fullScreenWindowModel.index(i,0));
                joinApps.push(aObj.AppPid);
            }
            // add maximized apps
            for (i = 0 ; i < maximizedWindowModel.count ; i++){
                aObj = maximizedWindowModel.data(maximizedWindowModel.index(i,0));
                joinApps.push(aObj.AppPid);               
            }

            // add minimized apps
            for (i = 0 ; i < minimizedWindowModel.count ; i++){
                aObj = minimizedWindowModel.data(minimizedWindowModel.index(i,0));
                minApps.push(aObj.AppPid);
            }

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
    
    function removeDuplicates(arrArg) {
        return arrArg.filter(function(elem, pos,arr) {
            return arr.indexOf(elem) == pos;
        });
    }

}
