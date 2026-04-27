# frozen_string_literal: true

require 'colorize'
# Different filters' definitions specific to commands
module PrintData
  MONTHS = {
    1 => 'January',
    2 => 'February',
    3 => 'March',
    4 => 'April',
    5 => 'May',
    6 => 'June',
    7 => 'July',
    8 => 'August',
    9 => 'September',
    10 => 'October',
    11 => 'November',
    12 => 'December'
  }.freeze
  def self.print_metrics(result)
    return puts 'No data found' if result.nil?

    h_city, h_date, h_val = result[:highest]
    l_city, l_date, l_val = result[:lowest]
    hu_city, hu_date, hu_val = result[:humid]

    puts "Highest: #{h_val[:max_temp]}C on #{h_date} at #{h_city}"
    puts "Lowest: #{l_val[:min_temp]}C on #{l_date} at #{l_city}"
    puts "Humid: #{hu_val[:humidity]}% on #{hu_date} at #{hu_city}"
  end

  def self.print_chart_data(chart_data, city_name, month_name, year)
    if chart_data.empty? || city_name.empty? || chart_data[city_name].empty?
      puts 'No data found'
    else
      month_name = MONTHS[month_name.to_i]
      puts "#{month_name} #{year}"

      chart_data.each do |city, daily|
        print_city(city, daily)
      end
    end
  end

  def self.print_city(city, daily)
    puts "City: #{city}"

    daily.each do |day, temps|
      print_day(day, temps)
    end
  end

  def self.print_day(day, temps)
    low_bar  = ('+' * temps[:min].to_i.abs).blue
    high_bar = ('+' * temps[:max].to_i.abs).red

    puts "#{day} #{low_bar}#{high_bar} #{temps[:min]}C-#{temps[:max]}C"
  end
end
