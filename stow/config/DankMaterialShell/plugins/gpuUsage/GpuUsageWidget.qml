import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property var widgetData: null
    property var popoutService: null
    property real gpuUsage: -1
    readonly property bool minimumWidth: (widgetData && widgetData.minimumWidth !== undefined) ? widgetData.minimumWidth : true
    readonly property color usageColor: {
        if (gpuUsage > 80)
            return Theme.tempDanger;
        if (gpuUsage > 60)
            return Theme.tempWarning;
        return Theme.widgetIconColor;
    }

    function updateGpuUsage() {
        Proc.runCommand(
            "gpuUsage.poll",
            [
                "nvidia-smi",
                "--query-gpu=utilization.gpu",
                "--format=csv,noheader,nounits"
            ],
            (output, exitCode) => {
                if (exitCode !== 0) {
                    root.gpuUsage = -1;
                    return;
                }

                const value = parseFloat(output.trim().split("\n")[0]);
                root.gpuUsage = Number.isFinite(value) ? Math.max(0, Math.min(value, 100)) : -1;
            },
            50
        );
    }

    Component.onCompleted: updateGpuUsage()

    pillClickAction: (x, y, width, section, screen) => {
        popoutService?.toggleProcessList(x, y, width, section, screen);
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.updateGpuUsage()
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: "speed"
                size: root.iconSizeLarge
                color: root.usageColor
                anchors.verticalCenter: parent.verticalCenter
            }

            NumericText {
                isMonospace: false
                text: root.gpuUsage < 0 ? "--%" : root.gpuUsage.toFixed(0) + "%"
                reserveText: root.minimumWidth ? "100%" : ""
                width: Math.ceil(Math.max(implicitWidth, reservedWidth))
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 1

            DankIcon {
                name: "speed"
                size: root.iconSizeLarge
                color: root.usageColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            NumericText {
                isMonospace: false
                text: root.gpuUsage < 0 ? "--" : root.gpuUsage.toFixed(0)
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
