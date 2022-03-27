import QtQuick 2.1
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami

// KountdownDelegate {
Component {
    id: kountdownDelegate
    Kirigami.AbstractListItem {
        contentItem: Item {
            // implicitWidth/Height define the natural width/height of an item if no width or height is specified.
            // The setting below defines a component's preferred size based on its content
            implicitWidth: delegateLayout.implicitWidth
            implicitHeight: delegateLayout.implicitHeight
            GridLayout {
                id: delegateLayout
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                }
                rowSpacing: Kirigami.Units.largeSpacing
                columnSpacing: Kirigami.Units.largeSpacing
                columns: root.wideScreen ? 4 : 2

                Kirigami.Icon {
                    Layout.fillHeight: true
                    source: icon
                }

                ColumnLayout {
                    Kirigami.Heading {
                        Layout.fillWidth: true
                        level: 2
                        text: name
                    }
                    Kirigami.Separator {
                        Layout.fillWidth: true
                        visible: description.length > 0
                    }
                    Controls.Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: description
                        visible: description.length > 0
                    }
                }
                Controls.Label {
                    Layout.alignment: Qt.AlignRight
                    Layout.columnSpan: 2
                    text: duration
                    // onClicked: to be done... soon!
                }
            }
        }
    }
}
