# frozen_string_literal: true

# Different filters' definitions specific to commands
module DataFilter
  def self.extract_metrics(key, data, city_name)
    filtered = filter_data(key, data, city_name)
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

  def self.filter_data(key, data, city_name)
    filtered = []
    data.each do |city, records|
      next if city_name && city.downcase != city_name.downcase

      records.each do |date, values|
        filtered << [city, date, values] if date.start_with?(key)
      end
    end

    filtered
  end

  def self.extract_chart_metric(key, data, city_name)
    result = {}

    data.each do |city, records|
      next if city_name && city.downcase != city_name.downcase

      result[city] = filter_chart_data(records, key)
    end
    result
  end

  def self.filter_chart_data(records, key)
    daily = {}

    records.each do |date, values|
      next unless date.start_with?(key)

      day = extract_day(date)
      update_daily(daily, day, values)
    end

    daily
  end

  def self.extract_day(date)
    date.split('-')[2]
  end

  def self.update_daily(daily, day, values)
    daily[day] ||= {
      max: -Float::INFINITY,
      min: Float::INFINITY
    }

    daily[day][:max] = values[:max_temp] if values[:max_temp] > daily[day][:max]
    daily[day][:min] = values[:min_temp] if values[:min_temp] < daily[day][:min]
  end
end
