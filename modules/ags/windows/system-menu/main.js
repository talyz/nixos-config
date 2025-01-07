import { Widget, Hyprland } from "../../imports.js";
import PopupWindow from "../../utils/popup_window.js";

import Toggles from "./toggles.js";
import PowerProfiles from "./powerprofiles.js";
import Sliders from "./sliders.js";
import BatteryInfo from "./battery_info.js";

const SystemMenuBox = () =>
      Widget.Box({
          className: "system-menu",
          vertical: true,

          children: [
              Toggles(),
              PowerProfiles(),
              Sliders(),
              BatteryInfo(),
          ],
      });

export default (monitor = 0) =>
PopupWindow({
    monitor: Hyprland.active.monitor.bind("id"),
    anchor: ["top", "right"],
    name: "system-menu",
    child: SystemMenuBox(),
});
