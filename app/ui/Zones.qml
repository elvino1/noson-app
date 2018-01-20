/*
 * Copyright (C) 2016
 *      Jean-Luc Barriere <jlbarriere68@gmail.com>
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
import Ubuntu.Components.Popups 1.3
import NosonApp 1.0
import "../components"
import "../components/Delegates"
import "../components/Flickables"
import "../components/ListItemActions"
import "../components/HeadState"
import "../components/BottomEdge"

BottomEdgePage {
    id: zonesPage

    bottomEdgeEnabled: true
    bottomEdgePage: Page {
        header: PageHeader {
            title: currentZoneTag

            leadingActionBar {
                actions: [
                    Action {
                        iconName: "back"
                        objectName: "backAction"
                        onTriggered: mainPageStack.pop()
                    }
                ]
            }

            StyleHints {
                backgroundColor: mainView.headerColor
                dividerColor: Qt.darker(mainView.headerColor, 1.1)
            }
        }

        ZoneControls {
            controlledZone: currentZone
        }
    }
    bottomEdgeTitle: "" //i18n.tr("Zone controls")
    bottomEdgeMarging: musicToolbar.visible ? musicToolbar.height : 0

    property string pageTitle: i18n.tr("Zones")
    property Item pageFlickable: zoneList

    state: zoneList.state === "multiselectable" ? "selection" : "default"
    states: [
        State {
            id: defaultState
            name: "default"
            property PageHeader thisHeader: PageHeader {
                flickable: zonesPage.pageFlickable
                title: zonesPage.pageTitle

                leadingActionBar {
                    actions: [
                        Action {
                            iconName: "back"
                            objectName: "backAction"
                            onTriggered: mainPageStack.pop()
                        }
                    ]
                    objectName: "zonesLeadingActionBar"
                }
                trailingActionBar {
                    actions: [
                        Action {
                            //iconName: "settings"
                            iconSource: Qt.resolvedUrl("../graphics/cogs.svg")
                            text: i18n.tr("Settings")
                            visible: true
                            onTriggered: PopupUtils.open(Qt.resolvedUrl("../components/Dialog/DialogSettings.qml"), mainView)
                        },
                        Action {
                          iconName: "reload"
                          text: i18n.tr("Reload zones")
                          visible: true
                          onTriggered: {
                              connectSonos()
                          }
                        },
                        Action {
                            //iconName: "compose"
                            iconSource: Qt.resolvedUrl("../graphics/group.svg")
                            text: i18n.tr("Create group")
                            visible: zoneList.model.count > 1
                            onTriggered: zoneList.clearSelection() // change view state to multiselectable
                        }
                    ]
                    objectName: "zonesTrailingActionBar"
                }
                visible: zonesPage.state === "default"

                StyleHints {
                    backgroundColor: mainView.headerColor
                    dividerColor: Qt.darker(mainView.headerColor, 1.1)
                }
            }

            PropertyChanges {
                target: zonesPage
                header: defaultState.thisHeader
            }
        },
        State {
            id: selectionState
            name: "selection"
            property PageHeader thisHeader: PageHeader {
                flickable: zonesPage.pageFlickable
                title: zonesPage.pageTitle

                leadingActionBar {
                    actions: [
                        Action {
                            text: "back"
                            iconName: "back"
                            onTriggered: {
                                if (zoneList.getSelectedIndices().length > 1) {
                                    handleJoinZones()
                                }
                                zoneList.closeSelection()
                            }
                        }
                    ]
                    objectName: "zonesLeadingActionBar"
                }
                trailingActionBar {
                    actions: [
                        Action {
                            iconName: zoneList.model.count > zoneList.getSelectedIndices().length ? "select" : "clear"
                            text: zoneList.model.count > zoneList.getSelectedIndices().length ? i18n.tr("Select All") : i18n.tr("Clear")
                            visible: zoneList.model.count > 0

                            onTriggered: {
                                if (zoneList.model.count > zoneList.getSelectedIndices().length)
                                    zoneList.selectAll()
                                else
                                    zoneList.clearSelection()
                            }
                        }
                    ]
                    objectName: "zonesSelectionTrailingActionBar"
                }
                visible: zonesPage.state === "selection"

                StyleHints {
                    backgroundColor: mainView.headerColor
                    dividerColor: Qt.darker(mainView.headerColor, 1.1)
                }
            }

            PropertyChanges {
                target: zonesPage
                header: selectionState.thisHeader
            }
        }
    ]

    function handleJoinZones() {
        var indicies = zoneList.getSelectedIndices();
        // get current as master
        for (var z = 0; z < zoneList.model.count; ++z) {
            if (zoneList.model.get(z).name === currentZone) {
                var master = zoneList.model.get(z)
                // join zones
                for (var i = 0; i < indicies.length; ++i) {
                    if (indicies[i] !== z) {
                        if (!Sonos.joinZone(zoneList.model.get(indicies[i]).payload, master.payload))
                            return false;
                    }
                }
                // all changes done
                return true;
            }
        }
        return false;
    }

    MultiSelectListView {
        id: zoneList        
        anchors {
            fill: parent
        }
        footer: Item {
            height: mainView.height - (styleMusic.common.expandHeight + zoneList.currentHeight) + units.gu(8)
        }
        model: AllZonesModel
        objectName: "zoneList"

        delegate: MusicListItem {
            id: zoneListItem
            color: currentZone === model.name ? "#2c2c34" : styleMusic.mainView.backgroundColor
            column: Column {
                Label {
                    id: zoneName
                    color: currentZone === model.name ? UbuntuColors.blue : styleMusic.common.music
                    fontSize: "medium"
                    objectName: "nameLabel"
                    text: model.isGroup ? model.shortName : model.name
                }

                Label {
                    id: fullName
                    color: styleMusic.common.subtitle
                    fontSize: "x-small"
                    objectName: "fillNameLabel"
                    text: model.name
                    visible: model.isGroup
                }
            }
            leadingActions: ListItemActions {
                actions: [
                    Clear {
                        visible: model.isGroup
                        onTriggered: {
                            Sonos.unjoinZone(model.payload)
                        }
                    }
                ]
            }
            multiselectable: true
            reorderable: false
            objectName: "zoneListItem" + index
            trailingActions: ListItemActions {
                actions: [
                    Action {
                        visible: model.isGroup
                        iconName: "edit-cut"
                        text: i18n.tr("Group")

                        onTriggered: {
                            mainPageStack.push(Qt.resolvedUrl("Group.qml"),
                                               {"zoneId": model.id})
                        }
                    }
                ]
                delegate: ActionDelegate {

                }
            }

            onItemClicked: {
                connectZone(model.name)
            }

            onSelectedChanged: {
                if (zoneList.state === "multiselectable")
                    zoneList.checkSelected()
            }

        }

        onStateChanged: {
            if (state === "multiselectable")
                selectCurrentZone()
        }

        function selectCurrentZone() {
            var tmp = [];
            for (var i = 0; i < model.count; i++) {
                if (model.get(i).name === currentZone) {
                    tmp.push(i);
                    break;
                }
            }
            ViewItems.selectedIndices = tmp
        }

        function checkSelected() {
            // keep currentZone selected
            var indicies = getSelectedIndices();
            for (var i = 0; i < indicies.length; i++) {
                if (model.get(indicies[i]).name === currentZone)
                    return;
            }
            for (var i = 0; i < model.count; i++) {
                if (model.get(i).name === currentZone) {
                    indicies.push(i);
                    ViewItems.selectedIndices = indicies;
                    break;
                }
            }
        }
    }
}