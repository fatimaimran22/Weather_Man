# frozen_string_literal: true

require_relative 'data_loader'
require_relative 'print_data'
require_relative 'cli_helper'
require_relative 'filter_data'
# Filters data specific to the commands
class WeatherMan
  attr_accessor :data

  def initialize
    @data = DataLoader.load
  end

  def run(command, area, year, month)
    key = calc_key(year, month, command)
    case command
    when '-e', '-a'
      filtered = DataFilter.extract_metrics(key, @data, area)
      PrintData.print_metrics(filtered)
    when '-c'
      filtered = DataFilter.extract_chart_metric(key, data, area)
      PrintData.print_chart_data(filtered, area, month, year)
    end
  end

  def calc_key(year, month, command)
    ['-a', '-c'].include?(command) ? "#{year}-#{month}" : year
  end
end

commands = CommandLineData.new
weather = WeatherMan.new
# puts commands.command = '-c'
# puts commands.area = 'lahore'
# puts commands.year = '2004'
# puts commands.month = '7'
weather.run(commands.command, commands.area, commands.year, commands.month)
# weather.run('-c', 'murree', '2004', '7')
