/*
 * Copyright (C) 2016-2019
 *      Jean-Luc Barriere <jlbarriere68@gmail.com>
 *      Adam Pigg <adam@piggz.co.uk>
 *      Andrew Hayzen <ahayzen@gmail.com>
 *      Daniel Holm <d.holmen@gmail.com>
 *      Victor Thompson <victor.thompson@gmail.com>
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


Rectangle {
    id: playlistsEmptyState
    anchors.fill: parent
    color: "transparent"

    Column {
        anchors.centerIn: parent
        spacing: units.gu(4)
        width: parent.width > units.gu(44) ? parent.width - units.gu(8) : units.gu(40)

        Label {
            color: styleMusic.view.labelColor
            elide: Text.ElideRight
            font.pixelSize: units.fx("x-large")
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 2
            text: qsTr("No playlists found")
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Label {
            color: styleMusic.view.labelColor
            elide: Text.ElideRight
            font.pixelSize: units.fx("large")
            horizontalAlignment: Text.AlignHCenter
            maximumLineCount: 6
            text: qsTr("Get more out of Sonos by tapping the %1 icon to start making playlists for every mood and occasion.").arg('"+"')
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }
}
