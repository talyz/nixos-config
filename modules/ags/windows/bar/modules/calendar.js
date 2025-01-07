import PopupWindow from "../../../utils/popup_window.js";
import { Hyprland } from "../../../imports.js";

const CalendarWidget = Widget.Calendar({
    className: "calendar",
    showDayNames: true,
    // showDetails: true,
    showHeading: true,
    showWeekNumbers: true,
    // detail: (self, y, m, d) => {
    //     return `<span color="white">${y}. ${m}. ${d}.</span>`
    // },
    onDaySelected: (self) =>
    {
        const [year, month, day] = self.date;
        self.mark_day(day);
        print(day)
    },
})

export default (monitor = 0) =>
    PopupWindow({
        monitor: Hyprland.active.monitor.bind("id"),
        anchor: ["top"],
        name: "calendar",
        child: CalendarWidget,
    });
