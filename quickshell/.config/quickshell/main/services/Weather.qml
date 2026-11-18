pragma Singleton

// Weather at the current location from Open-Meteo (no API key): the
// temperature and weather now, and the high, low, weather and chance of rain
// for today and the next 3 days. The location comes from geoclue, which
// automatic-timezoned already uses, and is rounded to 2 decimals (about
// 1 km) before it is sent. Refreshes every 30 minutes while the session is
// active; the last forecast and location survive config reloads.
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int interval: 30 * 60000
    readonly property var forecast: {
        try {
            return JSON.parse(saved.forecast);
        } catch (e) {
            return null;
        }
    }
    // { temperature, code, isDay }, or null before the first forecast.
    readonly property var current: forecast === null ? null : {
        temperature: forecast.current.temperature_2m,
        code: forecast.current.weather_code,
        isDay: forecast.current.is_day === 1
    }
    // [{ date, code, high, low, rain }], today first.
    readonly property var days: forecast === null ? [] : forecast.daily.time.map((day, i) => {
        const parts = day.split("-").map(Number);
        return {
            date: new Date(parts[0], parts[1] - 1, parts[2]),
            code: forecast.daily.weather_code[i],
            high: forecast.daily.temperature_2m_max[i],
            low: forecast.daily.temperature_2m_min[i],
            rain: forecast.daily.precipitation_probability_max[i]
        };
    })
    // True when the last forecast is more than two intervals old.
    property bool stale: false

    // Fetches a new forecast unless the last one is less than an interval old.
    function refresh() {
        stale = saved.updated > 0 && Date.now() - saved.updated > 2 * interval;
        if (Date.now() - saved.updated < interval - 60000)
            return;
        locate.running = true;
    }

    function fetchForecast() {
        if (saved.location === "") {
            console.warn("Weather: no location from geoclue yet");
            return;
        }
        fetch.running = true;
    }

    // Short description of a WMO weather code, as used by Open-Meteo.
    function describe(code) {
        switch (code) {
        case 0: return "Clear";
        case 1: return "Mostly clear";
        case 2: return "Partly cloudy";
        case 3: return "Overcast";
        case 45: return "Fog";
        case 48: return "Rime fog";
        case 51: return "Light drizzle";
        case 53: return "Drizzle";
        case 55: return "Heavy drizzle";
        case 56: case 57: return "Freezing drizzle";
        case 61: return "Light rain";
        case 63: return "Rain";
        case 65: return "Heavy rain";
        case 66: case 67: return "Freezing rain";
        case 71: return "Light snow";
        case 73: return "Snow";
        case 75: return "Heavy snow";
        case 77: return "Snow grains";
        case 80: return "Light showers";
        case 81: return "Showers";
        case 82: return "Heavy showers";
        case 85: case 86: return "Snow showers";
        case 95: return "Thunderstorm";
        case 96: case 99: return "Thunder, hail";
        default: return "Unknown";
        }
    }

    // Kind of weather for coloring: "clear", "partly", "cloudy" (with fog),
    // "rain" (with drizzle and sleet), "snow" or "storm".
    function kind(code) {
        if (code <= 1)
            return "clear";
        if (code === 2)
            return "partly";
        if (code === 3 || code === 45 || code === 48)
            return "cloudy";
        if ((code >= 71 && code <= 77) || code === 85 || code === 86)
            return "snow";
        if (code >= 95)
            return "storm";
        return "rain";
    }

    function icon(code, isDay) {
        switch (code) {
        case 0: case 1: return isDay ? "󰖙" : "󰖔";
        case 2: return isDay ? "󰖕" : "󰼱";
        case 3: return "󰖐";
        case 45: case 48: return "󰖑";
        case 65: case 82: return "󰖖";
        case 56: case 57: case 66: case 67: return "󰙿";
        case 71: case 73: case 77: case 85: return "󰖘";
        case 75: case 86: return "󰼶";
        case 95: return "󰙾";
        case 96: case 99: return "󰖒";
        default: return "󰖗";
        }
    }

    PersistentProperties {
        id: saved

        reloadableId: "weather"

        // The Open-Meteo response as JSON text.
        property string forecast: ""
        // Time of the last successful fetch, in ms since the epoch.
        property real updated: 0
        // The rounded location as "latitude,longitude".
        property string location: ""
    }

    Timer {
        interval: root.interval
        running: Session.active
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // geoclue's demo client prints "Latitude:    55.123456°" and a matching
    // longitude line for each fix. The first fix ends it; without a fix in
    // 20 s the last known location is used.
    Process {
        id: locate

        property real latitude: NaN

        command: ["/usr/lib/geoclue-2.0/demos/where-am-i", "-a", "4", "-t", "20"]
        stdout: SplitParser {
            onRead: line => {
                const match = line.match(/^(Latitude|Longitude):\s*(-?[0-9.]+)/);
                if (!match)
                    return;
                const value = Number(match[2]);
                if (match[1] === "Latitude") {
                    locate.latitude = value;
                } else if (!isNaN(locate.latitude)) {
                    saved.location = locate.latitude.toFixed(2) + "," + value.toFixed(2);
                    locate.running = false;
                }
            }
        }
        onRunningChanged: {
            if (running) {
                latitude = NaN;
                return;
            }
            root.fetchForecast();
        }
    }

    Process {
        id: fetch

        command: {
            const [latitude, longitude] = saved.location.split(",");
            return ["curl", "-fsS", "--max-time", "10",
                "https://api.open-meteo.com/v1/forecast?latitude=" + latitude + "&longitude=" + longitude
                + "&current=temperature_2m,weather_code,is_day"
                + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
                + "&timezone=auto&forecast_days=4"];
        }
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (!data.current || !data.daily)
                        throw new Error("missing current or daily data");
                    saved.forecast = JSON.stringify({ current: data.current, daily: data.daily });
                    saved.updated = Date.now();
                    root.stale = false;
                } catch (e) {
                    console.warn("Weather fetch failed:", e);
                }
            }
        }
    }
}
