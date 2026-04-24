command = ARGV[0]   
value   = ARGV[1]  
base    = ARGV[2]

if base.nil? || !base.match?(/^\/?data(\/[a-zA-Z]+)?$/) || (command == "-a" && !value.include?("/")) || (command == "-c" && !value.include?("/"))
  puts 'Invalid path! Enter: '
  puts "ruby weatherman.rb -e YEAR /data"
  puts "ruby weatherman.rb -a YEAR/MONTH /data"
  puts "ruby weatherman.rb -c YEAR/MONTH /data or /data/lahore"
  exit
end

months = {
  1=>"January",2=>"February",3=>"March",4=>"April",
  5=>"May",6=>"June",7=>"July",8=>"August",
  9=>"September",10=>"October",11=>"November",12=>"December"
}

def red(text)
  "\e[31m#{text}\e[0m"
end

def blue(text)
  "\e[34m#{text}\e[0m"
end

global = false
if base == "/data"
  global = true
end

valid_cities = ["lahore", "dubai", "murree"]

if !global
  city_name = base.split("/").last
  unless valid_cities.include?(city_name)
    puts "Invalid AREA! Areas: lahore, dubai, murree"
    exit
  end
else
  city_name=nil
end

data={}
folders = Dir.glob("data/*").select { |f| File.directory?(f) }

folders.each do |folder|
  city = File.basename(folder)
    data[city]={}
    files = Dir.glob("#{folder}/*.txt")

    files.each do |file|
        lines=File.readlines(file)

        lines.each do |line|
            next if line.strip.start_with?("PKT") or line.strip.start_with?("GST") or line.strip.empty?
            row=line.strip.split(",")
            next if row[1].nil? or row[1]==''
            date=row[0]
            data[city][date]={
                max_temp: row[1].to_i,
                min_temp:row[3].to_i,
                humidity:row[7].to_i
            }
        end
    end
end

year  = nil
month = nil

if value.include?("/")
  parts = value.split("/")
  year  = parts[0]
  month = parts[1].to_i.to_s
else
  year = value
end

if command=="-a" 
  key = "#{year}-#{month}" 
else 
    key=year  
end

def filter_data(key, data, city_name)
  filtered = []
  
  data.each do |city, records|
    next if city_name && city.downcase != city_name.downcase
    records.each do |date, values|
      if date.start_with?(key)
        filtered << [city, date, values]
      end
    end
  end

  return nil if filtered.empty?

  highest = filtered.max_by { |_, _, v| v[:max_temp] }
  lowest  = filtered.min_by { |_, _, v| v[:min_temp] }
  humid   = filtered.max_by { |_, _, v| v[:humidity] }

  {
    highest: highest,
    lowest: lowest,
    humid: humid
  }
end

def filter_chart_data(key, data, city_name)
  result = {}

  data.each do |city, records|
    next if city_name && city.downcase != city_name.downcase

    daily = {}

    records.each do |date, values|
      next unless date.start_with?(key)

      day = date.split("-")[2].rjust(2, "0")

      daily[day] ||= {
        max: -Float::INFINITY,
        min: Float::INFINITY
      }

      daily[day][:max] = values[:max_temp] if values[:max_temp] > daily[day][:max]
      daily[day][:min] = values[:min_temp] if values[:min_temp] < daily[day][:min]
    end

    result[city] = daily
  end
  result
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

if command=="-a" || command=="-e"
  result=filter_data(key,data,city_name)
  if result.nil?
    puts "No data found"
  else
    h_city, h_date, h_val = result[:highest]
    l_city, l_date, l_val = result[:lowest]
    hu_city, hu_date, hu_val = result[:humid]

    puts "Highest: #{h_val[:max_temp]}C on #{h_date} at #{h_city}"
    puts "Lowest: #{l_val[:min_temp]}C on #{l_date} at #{l_city}"
    puts "Humid: #{hu_val[:humidity]}% on #{hu_date} at #{hu_city}"
  end
elsif command == "-c" && !month.nil? && !global
  chart_data = filter_chart_data(key, data, city_name)
  if chart_data.empty? || chart_data[city_name.capitalize].empty?
    puts "No data found"
  else
    print_chart(chart_data, months[month.to_i], year)
  end
  
end
puts "Specify area" if global && command == "-c"

