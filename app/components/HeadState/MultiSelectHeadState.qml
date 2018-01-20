/*
 * Copyright (C) 2015, 2016
 *      Jean-Luc Barriere <jlbarriere68@gmail.com>
 *      Andrew Hayzen <ahayzen@gmail.com>
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

import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Flickables"

State {
    name: "selection"

    property var containerItem
    property bool addToQueue: true
    property bool addToPlaylist: true
    property MultiSelectListView listview
    property bool removable: false
    property PageHeader thisHeader: PageHeader {
        id: selectionState
        flickable: thisPage.pageFlickable
        leadingActionBar {
            actions: [
                Action {
                    text: i18n.tr("Cancel selection")
                    iconName: "back"
                    onTriggered: listview.closeSelection()
                }
            ]
        }
        title: thisPage.pageTitle
        trailingActionBar {
            actions: [
                Action {
                    iconName: "select"
                    text: i18n.tr("Select All")
                    visible: listview !== null ?
                                 (listview.model.count > 0) || listview.getSelectedIndices().length > 0 : false

                    onTriggered: {
                        if (listview.getSelectedIndices().length > 0) {
                            listview.clearSelection()
                        } else {
                            listview.selectAll()
                        }
                    }
                },
                Action {
                    iconName: "add"
                    text: i18n.tr("Add to queue")
                    visible: listview !== null ? listview.getSelectedIndices().length > 0 && addToQueue : false

                    onTriggered: {
                        var indicies = listview.getSelectedIndices();
                        // when select all then add the container if exists
                        if (containerItem && indicies.length === listview.model.count) {
                            if (addQueue(containerItem))
                                listview.closeSelection();
                        }
                        else {
                            var items = [];
                            for (var i = 0; i < indicies.length; i++) {
                                items.push(listview.model.get(indicies[i]));
                            }
                            if (addMultipleItemsToQueue(items))
                                listview.closeSelection();
                        }
                    }
                },
                Action {
                    iconName: "add-to-playlist"
                    text: i18n.tr("Add to playlist")
                    visible: listview !== null ? listview.getSelectedIndices().length > 0 && addToPlaylist : false

                    onTriggered: {
                        var items = []
                        var indicies = listview.getSelectedIndices();
                        // when select all then add the container if exists
                        if (containerItem && indicies.length === listview.model.count)
                            items.push(containerItem);
                        else {
                            for (var i = 0; i < indicies.length; i++) {
                                items.push({"payload": listview.model.get(indicies[i]).payload});
                            }
                        }
                        mainPageStack.push(Qt.resolvedUrl("../../ui/AddToPlaylist.qml"),
                                           {"chosenElements": items})
                        listview.closeSelection()
                    }
                },
                Action {
                    iconName: "delete"
                    text: i18n.tr("Delete")
                    visible: listview !== null ? listview.getSelectedIndices().length > 0 && removable : false

                    onTriggered: {
                        removed(listview.getSelectedIndices())
                        listview.closeSelection()
                    }
                }
            ]
        }
        visible: thisPage.state === "selection"

        StyleHints {
            backgroundColor: mainView.headerColor
            dividerColor: Qt.darker(mainView.headerColor, 1.1)
        }
    }
    property Item thisPage

    signal removed(var selectedIndices)

    PropertyChanges {
        target: thisPage
        header: thisHeader
    }
}