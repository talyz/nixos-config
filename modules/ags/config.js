import { Audio, Notifications, Utils, Hyprland } from "./imports.js";
import Bar from "./windows/bar/main.js";
import Music from "./windows/music/main.js";
import NotificationPopup from "./windows/notifications/popups.js";
import Osd from "./windows/osd/main.js";
import SystemMenu from "./windows/system-menu/main.js";
import Calendar from "./windows/bar/modules/calendar.js";

const css = App.configDir + "/style.css";

Notifications.popupTimeout = 10000;
Notifications.forceTimeout = false;
Notifications.cacheActions = true;
Audio.maxStreamVolume = 1;

function createWindows() {
    return [
        ...Hyprland.monitors.map(monitor => Bar(monitor.id)),
        Music(),
        Osd(),
        SystemMenu(),
        Calendar(),
        NotificationPopup(),
    ]// .map(w => w.on("destroy", self => App.removeWindow(self)))
    ;
}

// const hyprlandCreateWindows = () => Hyprland.monitors.flatMap(monitor => createWindows(monitor.id));

const hyprlandAddWindows = () => {
    hyprlandCreateWindows().forEach((win) => App.addWindow(win));
}

function hyprlandRecreateWindows() {
    print("hejsan")
    print(JSON.stringify(App))
    for (const win of App.windows) {
        print("hej")
        App.removeWindow(win);
    }
    App.config({ windows: createWindows() });
    // hyprlandAddWindows();
    print(JSON.stringify(App))
}

App.connect("config-parsed", () => {
    print("config parsed!");
    Hyprland.connect("monitor-added", hyprlandRecreateWindows);
    Hyprland.connect("monitor-removed", hyprlandRecreateWindows);
});

App.config({
    style: css,
    windows: createWindows(),
    closeWindowDelay: {
        "system-menu": 200,
    },
});

export {}
