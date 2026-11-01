import QtQuick
import QtQuick.Layouts
import org.kde.kwin
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore

Item {
    id: root

    // Cuánto tiempo se queda visible el popup tras el último cambio (ms)
    readonly property int hideDelay: 600
    // Factor de tamaño del popup (1.0 = tamaño original)
    readonly property real sizeFactor: 0.7

    PlasmaCore.Dialog {
        id: osd
        visible: false
        type: PlasmaCore.Dialog.OnScreenDisplay
        location: PlasmaCore.Types.Floating
        outputOnly: true
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.WindowTransparentForInput

        mainItem: ColumnLayout {
            id: content
            spacing: Kirigami.Units.gridUnit * root.sizeFactor

            Kirigami.Heading {
                id: label
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: Kirigami.Units.gridUnit * root.sizeFactor
                Layout.leftMargin: Kirigami.Units.gridUnit * 2 * root.sizeFactor
                Layout.rightMargin: Kirigami.Units.gridUnit * 2 * root.sizeFactor
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * 2.2 * root.sizeFactor
                text: Workspace.currentDesktop ? Workspace.currentDesktop.name : ""
            }

            Grid {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: Kirigami.Units.gridUnit * root.sizeFactor
                columns: Math.max(1, Workspace.desktopGridWidth)
                spacing: Kirigami.Units.gridUnit * 0.6 * root.sizeFactor

                Repeater {
                    model: Workspace.desktops
                    delegate: Rectangle {
                        readonly property bool current: modelData === Workspace.currentDesktop
                        width: Kirigami.Units.gridUnit * root.sizeFactor
                        height: width
                        radius: width / 2
                        color: current ? Kirigami.Theme.highlightColor : "transparent"
                        border.width: current ? 0 : 1.5
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g,
                                              Kirigami.Theme.textColor.b, 0.6)
                    }
                }
            }
        }
    }

    Timer {
        id: hideTimer
        interval: root.hideDelay
        onTriggered: osd.visible = false
    }

    function show() {
        osd.visible = true;
        const area = Workspace.clientArea(KWin.FullScreenArea, Workspace.activeScreen, Workspace.currentDesktop);
        osd.x = area.x + (area.width - osd.width) / 2;
        osd.y = area.y + (area.height - osd.height) / 2;
        hideTimer.restart();
    }

    Connections {
        target: Workspace
        function onCurrentDesktopChanged() { root.show(); }
    }
}
