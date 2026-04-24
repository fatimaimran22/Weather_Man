# frozen_string_literal: true

# Reads command line arguments, checks and parses them into correct states
class CommandLineData
  attr_accessor :command, :year, :month, :area

  VALID_CITIES = %w[lahore dubai murree].freeze
  def initialize
    @command = ARGV[0]
    @date = ARGV[1]
    @path = ARGV[2]
    validate!(@command, @date, @path)
    @year = extract_year(@date)
    @month = extract_month(@date)
    @area = extract_area(@path)
  end

  def valid_path?(path)
    path&.match?(%r{^/?data(/[a-zA-Z]+)?$})
  end

  def valid_command_and_date?(command, date)
    return date.include?('/') if ['-a', '-c'].include?(command)

    true
  end

  def valid_area?(path)
    area = path.split('/').last
    return true if area == 'data'

    VALID_CITIES.include?(area)
  end

  def validate!(command, date, path)
    return if valid_path?(path) && valid_command_and_date?(command, date) && valid_area?(path)

    puts 'Invalid path! Enter: '
    puts 'ruby weatherman.rb -e YEAR /data'
    puts 'ruby weatherman.rb -a YEAR/MONTH /data'
    puts 'ruby weatherman.rb -c YEAR/MONTH /data or /data/lahore'
    exit
  end

  def extract_year(date)
    date.split('/').first
  end

  def extract_month(date)
    parts = date.split('/')
    return nil unless parts[1]

    parts[1].to_i.to_s
  end

  def extract_area(path)
    path.split('/').last
  end
end

commands = CommandLineData.new
puts commands.month
puts commands.year
puts commands.command
puts commands.area
