import { Widget, Hyprland } from "../../imports.js";
import Battery from "./modules/battery.js";
import Bluetooth from "./modules/bluetooth.js";
import Date from "./modules/date.js";
import Music from "./modules/music.js";
import Net from "./modules/net.js";
import CpuRam from "./modules/cpu_ram.js";
import Tray from "./modules/tray.js";
import Workspaces from "./modules/workspaces.js";

const SystemInfo = () =>
      Widget.EventBox({
          className: "system-menu-toggler",
          onPrimaryClick: () => App.toggleWindow("system-menu"),

          child: Widget.Box({
              children: [
                  Net(),
                  Bluetooth(),
                  Battery(),
              ],
          }),
      })
      .hook(
          App,
          (self, window, visible) => {
              if (window === "system-menu") {
                  self.toggleClassName("active", visible);
              }
          },
      );

const Start = () =>
      Widget.Box({
          hexpand: true,
          hpack: "start",
          children: [
              Workspaces(),
              Music(),
              // Indicators
          ],
      });

const Center = () =>
      Widget.Box({
          children: [
              Date(),
          ],
      });

const End = () =>
      Widget.Box({
          hexpand: true,
          hpack: "end",

          children: [
              Tray(),
              // CpuRam(),
              SystemInfo(),
              // Date(),
          ],
      });

export default (monitor = 0) =>
Widget.Window({
    monitor,// : Hyprland.active.monitor.bind("id")
    name: `bar-${monitor}`,
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",

    child: Widget.CenterBox({
        className: "bar",

        startWidget: Start(),
        centerWidget: Center(),
        endWidget: End(),
    }),
});
