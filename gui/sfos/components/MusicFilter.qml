/*
 * Copyright (C) 2019
 *      Jean-Luc Barriere <jlbarriere68@gmail.com>
 *      Adam Pigg <adam@piggz.co.uk>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import QtQuick.Layouts 1.1

Rectangle {
    id: filter
    visible: true
    width: parent.width
    height: visible ? units.gu(6) : 0
    color: styleMusic.playerControls.backgroundColor

    property alias displayText: field.text

    RowLayout {
        spacing: 0
        anchors.fill: parent
        anchors.rightMargin: units.gu(1.5)

        Item {
            width: units.gu(6)
            height: units.gu(6)
            anchors.verticalCenter: parent.center

            MusicIcon {
                width: units.gu(5)
                height: width
                anchors.verticalCenter: parent.center
                anchors.right: parent.right
                source: "qrc:/images/edit-clear.svg"
                onClicked: {
                    field.text = "";
                    filter.visible = false;
                }
            }
        }

        TextField {
            id: field
            Layout.fillWidth: true
            font.pixelSize: units.fx("large")
            placeholderText: qsTr("Search music")
        }
    }

    onVisibleChanged: {
        if (visible) {
            field.enabled = true;
            field.forceActiveFocus();
        } else {
            field.enabled = false;
        }
    }
}
