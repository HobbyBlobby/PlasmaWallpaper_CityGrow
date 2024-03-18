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

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.8
import org.kde.plasma.plasmoid

// for "units"
import org.kde.plasma.components 3.0 as PlasmaComponents
// import org.kde.kquickcontrols 2.0 as KQuickControls
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami as Kirigami

// Item {

    Kirigami.FormLayout {
      id: page

      
        property alias cfg_start_branches : start_branches.value;
        property alias cfg_scale : scale.value;

        anchors.left: parent.left
        anchors.right: parent.right

        signal configurationChanged()

        PlasmaComponents.Slider {
            id: start_branches
            Kirigami.FormData.label: i18n("Stat Branches (%1)", start_branches.value)
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
    }
// }
