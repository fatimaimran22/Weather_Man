# frozen_string_literal: true

require_relative 'data_loader'
# Filters data specific to the commands
class WeatherMan
  attr_accessor :data

  def initialize
    @data = DataLoader.load
  end
end

w = WeatherMan.new
data = w.data

data.each_key do |city|
  puts city
end
