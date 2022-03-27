import QtQuick 2.1
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import QtCharts 2.15

    Kirigami.ScrollablePage {
        title: "Dashboard"

        actions {
            main: Kirigami.Action {
                text: (root.activityTracking ? "Disable": "Enable") + " activity tracking"
                icon.name: "clock"
                onTriggered: {
                    root.activityTracking = !root.activityTracking
                }
            }
            right: Kirigami.Action {
                text: "Refresh"
                icon.name: "view-refresh"
                onTriggered: {
                    updateData();
                }
            }
        }

        Component.onCompleted: {
            updateData();
        }

        Controls.BusyIndicator {
            id: busyIndicator
            running: false
        }

        RowLayout {
            ChartView {
                id: chart
                width: 400
                height: 500
                title: "Top programs today"
                legend.alignment: Qt.AlignLeft
                antialiasing: true

                backgroundColor: "transparent"
                titleColor: Kirigami.Theme.textColor
                legend.color: Kirigami.Theme.textColor
                legend.labelColor: Kirigami.Theme.textColor
                legend.visible: false


                PieSeries {
                    id: pieSeries
                    holeSize: 0.5
                    PieSlice { label: "productive"; value: 1; color: get_category_color("productive"); labelVisible: true; labelColor: get_category_color("productive") }
                    PieSlice { label: "distracting"; value: 3; color: get_category_color("distracting"); labelVisible: true; labelColor: get_category_color("distracting") }
                    PieSlice { label: "uncategorized"; value: 1; color: get_category_color("uncategorized"); labelVisible: true; labelColor: get_category_color("uncategorized") }
                }
            }
            ColumnLayout {
                Controls.Frame {
                    ColumnLayout {
                        Kirigami.Heading {
                            text: "5h 41m today"
                        }
                        GridView {
                            height: 200
                            width: 200
                            // anchors.fill: parent
                            flow: GridLayout.TopToBottom
                            model: deviceModel
                            delegate: deviceDelegate
                            Component {
                                id: deviceDelegate
                                RowLayout {
                                    Kirigami.Icon {
                                        source: icon
                                    }
                                    Controls.Label {
                                        text: duration
                                    }
                                }
                            }
                            ListModel {
                                id: deviceModel
                                ListElement { icon: "computer"; duration: "2h 18m" }
                                ListElement { icon: "smartphone"; duration: "2h 13m" }
                                ListElement { icon: "tv"; duration: "50m" }
                            }
                        }
                    }
                }
                Controls.Frame {
                    ColumnLayout {
                        Controls.Label {
                            text: `1h 48m mostly <font color="${get_category_color('productive')}">productive</font>`
                        }
                        Controls.Label {
                            text: `50m mostly <font color="${get_category_color('distracting')}">distracting</font>`
                        }
                        Controls.Label {
                            text: `33m <font color="${get_category_color('uncategorized')}">uncategorized</font>`
                        }
                    }
                }
            }
            Controls.Frame {
                ColumnLayout {
                    anchors.fill: parent
                    RowLayout {
                        Kirigami.Heading {
                            text: "Top appliactions"
                        }
                        Controls.ToolButton {
                            icon.name: "go-next"
                            Layout.alignment: Qt.AlignHCenter
                            onClicked: pageStack.push(Qt.resolvedUrl("TopAppsPage.qml"), {})
                        }
                    }

                    ListView {
                        height: 200
                        model: appModel
                        delegate: appDelegate
                        Component {
                            id: appDelegate
                            RowLayout {
                                Kirigami.Icon {
                                    source: icon
                                }
                                Controls.Label {
                                    text: name
                                    color: category == "productive" ? Kirigami.Theme.positiveTextColor : category == "distracting" ? Kirigami.Theme.negativeTextColor : "grey"
                                }
                                Controls.Label {
                                    Layout.alignment: Qt.AlignRight
                                    text: duration
                                }
                            }
                        }
                        ListModel {
                            id: appModel
                            ListElement { name: "YouTube"; icon: "im-youtube"; duration: "1h 10m"; category: "distracting" }
                            ListElement { name: "Kate"; icon: "kate"; duration: "55m"; category: "productive" }
                            ListElement { name: "Blender"; icon: "blender"; duration: "40m"; category: "uncategorized" }
                        }
                    }
                }
            }
        }

        function request(url, callback) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if(xhr.readyState === 4) {
                callback(JSON.parse(xhr.responseText));
            }
        }
        xhr.open('POST', url, true);
        xhr.setRequestHeader("Content-Type", "application/json");

        var start = new Date();
        start.setHours(0,0,0,0);
        switch ("today") {
            default:
            case "today": {
            start.setHours(0,0,0,0);
            break;
        }
            case "last 7 days": {
                start.setDate(start.getDate() - 7);
                break;
            }
        }
        var end = new Date(start.getTime());
        end.setHours(23,59,59,999);

        var data = JSON.stringify({
            "query": [
                "afk_events = query_bucket(find_bucket('aw-watcher-afk_'));",
                "window_events = query_bucket(find_bucket('aw-watcher-window_'));",
                "window_events = filter_period_intersect(window_events, filter_keyvals(afk_events, 'status', ['not-afk']));",
                // "merged_events = merge_events_by_keys(window_events, ['app', 'title']);",
                "merged_events = merge_events_by_keys(window_events, ['app']);",
                "RETURN = sort_by_duration(merged_events);"
            ],
            "timeperiods": [start.toISOString() + '/' + end.toISOString()]
        });
        xhr.send(data);
    }

    function format_duration(duration) {
        // convert the duration (in s) to a human readable format
        var hours = Math.floor(duration / 3600);
        var minutes = Math.floor((duration - (hours * 3600)) / 60);
        if (hours) {
            return `${hours}h ${minutes}m`;
        }
        else {
            return `${minutes}m`;
        }
    }

    function updateData(cb) {
        busyIndicator.running = true;
            request("http://localhost:5600/api/0/query/", (response) => {
                let topEvents = response[0].splice(0, 5);

                // calculate the duration for each category
                let durationByCategory = {
                    "productive": 0,
                    "distracting": 0,
                    "uncategorized": 0,
                };
                for (let event of topEvents) {
                    const category = get_category(event.data.app)
                    if (category) {
                        durationByCategory[category] += event.duration;
                    }
                    else {
                        durationByCategory["uncategorized"] += event.duration;
                    }
                }

                // update pieSeries
                // pieSeries.clear();
                for (let category in durationByCategory) {
                    // Passing the color is apparently not supported.
                    // Instead, we modify the value of existing PieSlices.
                    let slice = pieSeries.find(category);
                    slice.value = durationByCategory[category];
                }

                // update appModel
                appModel.clear();
                for (let event of topEvents) {
                    appModel.append({
                        name: event.data.app,
                        icon: get_icon(event.data.app),
                        duration: format_duration(event.duration),
                        category: get_category(event.data.app)
                    });
                    // event.data.app, event.duration, event.data.category
                }

                // update busyIndicator
                busyIndicator.running = false;
            });
        }

    function get_icon(appname) {
        const MAP = {
            "code-oss": "com.visualstudio.code.oss",
            "konsole": "utilities-terminal",
            "ksystemlog": "utilities-log-viewer",
            "Produktive": "ktimetracker",
            "firefox": "firefox"
        }
        return MAP[appname] || "applications-other";
        // return MAP[appname] || appname;
    }

    function get_category(appname) {
        const MAP = {
            "code-oss": "productive",
            "Produktive": "productive",
            "firefox": "distracting",
            "konsole": "uncategorized",
        }
        return MAP[appname] || "uncategorized";
    }

    function get_category_color(category) {
        const MAP = {
            "productive": Kirigami.Theme.positiveTextColor,
            "distracting": Kirigami.Theme.negativeTextColor,
            "uncategorized": "grey",
        }
        return MAP[category] || "grey";
    }

}
