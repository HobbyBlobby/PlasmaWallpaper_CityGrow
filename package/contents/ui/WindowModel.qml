import QtQuick
import QtQuick.Window
import org.kde.taskmanager as TaskManager
import org.kde.plasma.core as PlasmaCore

Item {
    id: wModel
    // property alias screenGeometry: tasksModel.screenGeometry
    property bool runSimulation: true
    property bool checkSmartPlay: wallpaper.configuration.checkedSmartPlay
    
    TaskManager.VirtualDesktopInfo { id: virtualDesktopInfo }
    TaskManager.ActivityInfo { id: activityInfo }
    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled

        activity: activityInfo.currentActivity
        virtualDesktop: virtualDesktopInfo.currentDesktop
        // screenGeometry: wallpaper.screenGeometry // Warns "Unable to assign [undefined] to QRect" during init, but works thereafter.

        filterByActivity: true
        filterByVirtualDesktop: true
        filterByScreen: true
        
        onActiveTaskChanged: updateWindowsinfo(wModel.checkSmartPlay)
        onDataChanged: updateWindowsinfo(wModel.checkSmartPlay)
        Component.onCompleted: {
            maximizedWindowModel.sourceModel = tasksModel
            fullScreenWindowModel.sourceModel = tasksModel
        }
    }
    
    PlasmaCore.SortFilterModel {
        id: maximizedWindowModel
        filterRole: 'IsMaximized'
        filterRegExp: 'true'
        onDataChanged: updateWindowsinfo(wModel.checkSmartPlay)
        onCountChanged: updateWindowsinfo(wModel.checkSmartPlay)
    }
    PlasmaCore.SortFilterModel {
        id: fullScreenWindowModel
        filterRole: 'IsFullScreen'
        filterRegExp: 'true'
        onDataChanged: updateWindowsinfo(wModel.checkSmartPlay)
        onCountChanged: updateWindowsinfo(wModel.checkSmartPlay)
    }
    
    function updateWindowsinfo(checkActive) {
        if(!checkActive) {
            runSimulation = true;
            return;
        }
        if(maximizedWindowModel.count + fullScreenWindowModel.count > 0) {
            runSimulation = false;
            return;
        }
    }
}
