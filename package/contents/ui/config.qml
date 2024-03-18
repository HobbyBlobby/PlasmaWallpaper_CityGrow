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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
// import QtQuick.Controls.Styles
import org.kde.plasma.plasmoid

// for "units"
import org.kde.plasma.components 3.0 as PlasmaComponents
// import org.kde.kquickcontrols 2.0 as KQuickControls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami as Kirigami

// Item {
//     id: root    
//       
//     property alias cfg_start_branches : start_branches.value;
//     property alias cfg_scale : scale.value;
//     property alias cfg_checkedSmartPlay : checkedSmartPlay.checked;
//     
//     RowLayout {
//         id: simStartBranchesRow
//         anchors.top: parent.top
//         anchors.horizontalCenter: parent.horizontalCenter
//         anchors.topMargin: 15
//         Layout.fillWidth: true
//         Label {
//          text: i18n("Start Branches (%1)", start_branches.value)
//          Layout.alignment: Qt.AlignLeft
//         }
//         Slider {
//             Layout.alignment: Qt.AlignRight
//             id: start_branches
//             from: 1
//             to: 10
//             value: 3
//             snapMode: Slider.SnapAlways
//             stepSize: 1
//         }        
//     }
//     RowLayout {
//         id: simScaleRow
//         anchors.top: simStartBranchesRow.bottom
//         anchors.horizontalCenter: parent.horizontalCenter
//         anchors.topMargin: 5
//         Layout.fillWidth:true
//         Label {
//          text: i18n("Scale (%1)", scale.value)
//          Layout.alignment: Qt.AlignLeft
//         }
//         Slider {
//             Layout.alignment: Qt.AlignRight
//             id: scale
//             from: 1
//             to: 10
//             value: 3
//             snapMode: Slider.SnapAlways
//             stepSize: 1
//         }        
//     }
// 
//     RowLayout {
//         id: checkedSmartPlayRow
//         anchors.top: simScaleRow.bottom
//         anchors.horizontalCenter: parent.horizontalCenter
//         anchors.topMargin: 5
//         Layout.fillWidth:true
//         CheckBox {
//             id: checkedSmartPlay
//             text: i18n("Pause simulationwhen when wallpaper not visible\nDo not use in screen saver mode!")
//             checked: cfg_checkedSmartPlay        
//         }        
//     }
// 
// }
Kirigami.FormLayout {
      id: root
          
    property alias cfg_start_branches : start_branches.value;
    property alias cfg_scale : scale.value;
    property alias cfg_checkedSmartPlay : checkedSmartPlay.checked;

        PlasmaComponents.Slider {
            id: start_branches
            Kirigami.FormData.label: i18n("Start Branches (%1)", start_branches.value)
            from: 1
            to: 10
            value: 3
            snapMode: Slider.SnapAlways
            stepSize: 1
        }

        PlasmaComponents.Slider {
            id: scale
            Kirigami.FormData.label: i18n("Scale (%1)", scale.value)
            from: 1
            to: 10
            value: 3
            snapMode: Slider.SnapAlways
            stepSize: 1
        }
        PlasmaComponents.CheckBox {
            id: checkedSmartPlay
            Kirigami.FormData.label: i18n("Pause simulation when when wallpaper is not visible\nDo not use in screen saver mode!")
            checked: cfg_checkedSmartPlay
        }
    }
