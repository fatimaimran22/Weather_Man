# frozen_string_literal: true

# Load the data in the hash and returns it
module DataLoader
  def self.load
    data = {}
    folders.each do |folder|
      city = File.basename(folder)
      data[city] = parse_city(folder)
    end

    data
  end

  def self.folders
    Dir.glob('data/*').select { |f| File.directory?(f) }
  end

  def self.parse_city(folder)
    city_data = {}

    Dir.glob("#{folder}/*.txt").each do |file|
      parse_file(file, city_data)
    end

    city_data
  end

  def self.parse_file(file, city_data)
    File.readlines(file).each do |line|
      process_line(line, city_data)
    end
  end

  def self.process_line(line, city_data)
    return if skip_line?(line)

    row = line.strip.split(',')
    return if row[1].nil? || row[1] == ''

    date = row[0]

    city_data[date] = {
      max_temp: row[1].to_i,
      min_temp: row[3].to_i,
      humidity: row[7].to_i
    }
  end

  def self.skip_line?(line)
    line.strip.start_with?('PKT', 'GST') || line.strip.empty?
  end
end
