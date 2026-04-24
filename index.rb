command = ARGV[0]
value   = ARGV[1]
base    = ARGV[2]

MONTHS = {
  1=>"January",  2=>"February", 3=>"March",    4=>"April",
  5=>"May",      6=>"June",     7=>"July",      8=>"August",
  9=>"September",10=>"October", 11=>"November", 12=>"December"
}

VALID_CITIES = ["lahore", "dubai", "murree"].freeze

# ── Colour helpers ────────────────────────────────────────────────────────────

def red(text)  = "\e[31m#{text}\e[0m"
def blue(text) = "\e[34m#{text}\e[0m"

# ── Validation ────────────────────────────────────────────────────────────────

def valid_base?(base)
  base&.match?(/^\/?data(\/[a-zA-Z]+)?$/)
end

def valid_command_value?(command, value)
  return value.include?("/") if ["-a", "-c"].include?(command)
  true
end

def validate!(command, value, base)
  return if valid_base?(base) && valid_command_value?(command, value)

  puts "Invalid path! Enter: "
  puts "ruby weatherman.rb -e YEAR /data"
  puts "ruby weatherman.rb -a YEAR/MONTH /data"
  puts "ruby weatherman.rb -c YEAR/MONTH /data or /data/lahore"
  exit
end

def resolve_city(base)
  return nil if base == "/data"

  city = base.split("/").last
  unless VALID_CITIES.include?(city)
    puts "Invalid AREA! Areas: #{VALID_CITIES.join(', ')}"
    exit
  end
  city
end


# ── Data loading ──────────────────────────────────────────────────────────────

def parse_line(line)
  return nil if line.strip.start_with?("PKT", "GST") || line.strip.empty?

  row = line.strip.split(",")
  return nil if row[1].nil? || row[1] == ""

  {
    date:      row[0],
    max_temp:  row[1].to_i,
    min_temp:  row[3].to_i,
    humidity:  row[7].to_i
  }
end

def load_city_data(folder)
  Dir.glob("#{folder}/*.txt").each_with_object({}) do |file, records|
    File.readlines(file).each do |line|
      entry = parse_line(line)
      next unless entry

      records[entry[:date]] = {
        max_temp: entry[:max_temp],
        min_temp: entry[:min_temp],
        humidity: entry[:humidity]
      }
    end
  end
end

def load_all_data
  Dir.glob("data/*").select { |f| File.directory?(f) }.each_with_object({}) do |folder, data|
    city = File.basename(folder)
    data[city] = load_city_data(folder)
  end
end

# ── Key building ──────────────────────────────────────────────────────────────

def parse_value(value)
  parts = value.include?("/") ? value.split("/") : [value, nil]
  year  = parts[0]
  month = parts[1]&.to_i
  [year, month]
end

def build_key(command, year, month)
  command == "-a" ? "#{year}-#{month}" : year
end

# ── Filtering ─────────────────────────────────────────────────────────────────

def collect_records(key, data, city_name)
  data.each_with_object([]) do |(city, records), arr|
    next if city_name && city.downcase != city_name.downcase
    records.each do |date, values|
      arr << [city, date, values] if date.start_with?(key)
    end
  end
end

def filter_data(key, data, city_name)
  filtered = collect_records(key, data, city_name)
  return nil if filtered.empty?

  {
    highest: filtered.max_by { |_, _, v| v[:max_temp] },
    lowest:  filtered.min_by { |_, _, v| v[:min_temp] },
    humid:   filtered.max_by { |_, _, v| v[:humidity] }
  }
end

def filter_chart_data(key, data, city_name)
  data.each_with_object({}) do |(city, records), result|
    next if city_name && city.downcase != city_name.downcase

    result[city] = records.each_with_object({}) do |(date, values), daily|
      next unless date.start_with?(key)

      day = date.split("-")[2].rjust(2, "0")
      daily[day] ||= { max: -Float::INFINITY, min: Float::INFINITY }
      daily[day][:max] = values[:max_temp] if values[:max_temp] > daily[day][:max]
      daily[day][:min] = values[:min_temp] if values[:min_temp] < daily[day][:min]
    end
  end
end

# ── Output ────────────────────────────────────────────────────────────────────

def print_extremes(result)
  h_city, h_date, h_val = result[:highest]
  l_city, l_date, l_val = result[:lowest]
  hu_city, hu_date, hu_val = result[:humid]

  puts "Highest: #{h_val[:max_temp]}C on #{h_date} at #{h_city}"
  puts "Lowest:  #{l_val[:min_temp]}C on #{l_date} at #{l_city}"
  puts "Humid:   #{hu_val[:humidity]}% on #{hu_date} at #{hu_city}"
end

def print_chart(data, month_name, year)
  puts "#{month_name} #{year}"

  data.each do |city, daily|
    puts "City: #{city}"
    daily.sort.each do |day, temps|
      low_bar  = blue("+" * temps[:min].to_i.abs)
      high_bar = red("+" * temps[:max].to_i.abs)
      puts "#{day} #{low_bar}#{high_bar} #{temps[:min]}C-#{temps[:max]}C"
    end
  end
end

# ── Command handlers ──────────────────────────────────────────────────────────

def run_extremes(key, data, city_name, **)
  result = filter_data(key, data, city_name)
  return puts("No data found") unless result

  print_extremes(result)
end

def run_chart(key, data, city_name, month:, year:, global:, **)
  return puts("Specify area") if global

  chart_data = filter_chart_data(key, data, city_name)
  return puts("No data found") if chart_data.empty?

  print_chart(chart_data, MONTHS[month], year)
end

COMMAND_HANDLERS = {
  "-e" => method(:run_extremes),
  "-a" => method(:run_extremes),
  "-c" => method(:run_chart)
}.freeze

# ── Entry point ───────────────────────────────────────────────────────────────

validate!(command, value, base)

city_name = resolve_city(base)
global    = base == "/data"
data      = load_all_data
year, month = parse_value(value)
key       = build_key(command, year, month)

handler = COMMAND_HANDLERS[command]
unless handler
  puts "Unknown command: #{command}"
  exit
end

handler.call(key, data, city_name, month: month, year: year, global: global)