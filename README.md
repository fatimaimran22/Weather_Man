# 🌤️ Weather Man

A command-line Ruby application that parses weather data files and generates temperature and humidity reports with colorized console output.

---

## Prerequisites

- Ruby (2.0+)
- Weather data files organized under a `data/` directory (see [Data Format](#data-format))

---

## Usage

```bash
ruby weatherman.rb [COMMAND] [VALUE] [PATH]
```

### Commands

| Command | Description |
|---------|-------------|
| `-e`    | Yearly extremes report |
| `-a`    | Monthly averages report |
| `-c`    | Monthly temperature bar chart |

---

## Reports

### 1. Yearly Extremes (`-e`)

Displays the highest temperature, lowest temperature, and most humid day for a given year.

```bash
ruby weatherman.rb -e 2002 /data
ruby weatherman.rb -e 2002 /data/lahore
```

**Output:**
```
Highest: 45C on 2002-06-23 at lahore
Lowest: 01C on 2002-12-22 at murree
Humid: 95% on 2002-08-14 at dubai
```

---

### 2. Monthly Averages (`-a`)

Displays the average highest temperature, average lowest temperature, and average humidity for a given month.

```bash
ruby weatherman.rb -a 2005/6 /data/lahore
```

**Output:**
```
Highest: 39C on 2005-06-10 at lahore
Lowest: 18C on 2005-06-01 at lahore
Humid: 71% on 2005-06-22 at lahore
```

> **Note:** The `-a` command requires a specific city path (e.g. `/data/lahore`), not the global `/data` path.

---

### 3. Monthly Temperature Bar Chart (`-c`)

Draws a horizontal bar chart for each day of the given month. Highest temperatures are shown in **red**, lowest in **blue**, displayed as a single merged bar per day.

```bash
ruby weatherman.rb -c 2011/03 /data/lahore
```

**Output:**
```
March 2011
City: lahore
01 🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴 11C-25C
02 🔵🔵🔵🔵🔵🔵🔵🔵🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴 08C-22C
...
```

> **Note:** The `-c` command requires a specific city path (e.g. `/data/lahore`). It does not work with the global `/data` path.

---

## Supported Cities

| City     | Folder Name |
|----------|-------------|
| Lahore   | `lahore`    |
| Dubai    | `dubai`     |
| Murree   | `murree`    |

---

## Path Options

| Path            | Description                          |
|-----------------|--------------------------------------|
| `/data`         | Global — includes all cities         |
| `/data/lahore`  | City-specific — filters to Lahore    |
| `/data/dubai`   | City-specific — filters to Dubai     |
| `/data/murree`  | City-specific — filters to Murree    |

---

## Data Format

Weather files should be placed inside `data/<city>/` directories as `.txt` files. Each file should contain comma-separated rows with the following column structure:

```
PKT,Max TemperatureC,Mean TemperatureC,Min TemperatureC,...,Max Humidity,...,Mean Humidity,...
2002-6-1,38,31,24,...,57,...,44,...
```

- Column 0 — Date (`YYYY-M-D`)
- Column 1 — Max Temperature (°C)
- Column 3 — Min Temperature (°C)
- Column 7 — Max Humidity (%)

Lines beginning with `PKT`, `GST`, or empty lines are automatically skipped.

**Example directory structure:**
```
data/
├── lahore/
│   ├── lahore_weather_2002.txt
│   └── lahore_weather_2003.txt
├── dubai/
│   └── dubai_weather_2002.txt
└── murree/
    └── murree_weather_2002.txt
```

---

## Error Handling

The application will exit with a usage message if:

- The path is missing or invalid
- An unrecognized city name is provided
- The `-a` or `-c` commands are used without a `YEAR/MONTH` value
- No matching data is found for the given filters

---

## Examples

```bash
# Yearly extremes across all cities
ruby weatherman.rb -e 2002 /data

# Yearly extremes for Lahore only
ruby weatherman.rb -e 2002 /data/lahore

# Monthly extremes for June 2005 in Dubai
ruby weatherman.rb -a 2005/6 /data/dubai

# Bar chart for March 2011 in Murree
ruby weatherman.rb -c 2011/03 /data/murree
```