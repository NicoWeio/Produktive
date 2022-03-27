import QtQuick 2.1
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import QtCharts 2.15

Kirigami.ScrollablePage {
    title: "Top applications"

    actions {
        main: Kirigami.Action {
            text: "Close"
            icon.name: "view-right-close"
            onTriggered: {
                pageStack.pop()
            }
        }
    }

    Controls.Label {
        text: "Nothing here yet"
    }
}
