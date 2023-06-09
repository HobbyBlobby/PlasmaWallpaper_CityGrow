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

import org.kde.plasma.core 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

//We need units from it
import org.kde.plasma.core 2.0 as Plasmacore

import "code/city.js" as City


Canvas {
    id: root
    anchors.fill: parent

    onPaint: {
        var ctx = getContext("2d");
        var bRunning = City.paintMatrix(ctx);
        if(!bRunning) {
            stepTimer.stop();
            resetTimer.start();
        };
    }

    onWidthChanged: {
        stepTimer.stop();
        City.dimensionChanged(width,height);
        stepTimer.start();
    }
    onHeightChanged: {
        stepTimer.stop();
        City.dimensionChanged(width,height);
        stepTimer.start();
    }

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
            City.restart(getContext("2d"));
            stepTimer.start();
        }
    }
}
