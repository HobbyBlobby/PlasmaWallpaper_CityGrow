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
    property alias cfg_show_reverse : show_reverse.checked;
    property alias cfg_fill_city : fill_city.checked;

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
            Kirigami.FormData.label: i18n("Pause simulation when wallpaper is not visible?\n(Do not use in screen saver mode.)")
            checked: cfg_checkedSmartPlay
        }
    
        PlasmaComponents.CheckBox {
            id: show_reverse
            Kirigami.FormData.label: i18n("Show reverse process at end of animation?")
            checked: cfg_show_reverse
        }
        
        PlasmaComponents.CheckBox {
            id: fill_city
            Kirigami.FormData.label: i18n("Fill spaces inbetween the lines?")
            checked: cfg_fill_city
        }
    }
