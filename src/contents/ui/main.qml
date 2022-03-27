import QtQuick 2.1
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import QtCharts 2.15

Kirigami.ApplicationWindow {
    id: root
    property bool activityTracking: true

    Dashboard {
        id: myDashboard
    }
    TopAppsPage {
        id: myTopAppsPage
    }

    pageStack.initialPage: myDashboard

}
