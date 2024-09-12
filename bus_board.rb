require 'json'
require 'net/http'
require 'uri'

def display_bus(bus)
  time_until_arrival = bus["timeToStation"]/60 == 0 ? "due" : "#{(bus["timeToStation"]/60).to_s} minutes"
  puts "line number: #{bus["lineName"]} || destination: #{bus["destinationName"]} || time until arrival: #{time_until_arrival}"
end

def display_buses_by_station_code(bus_code)
  url = "https://api.tfl.gov.uk/StopPoint/" + bus_code + "/Arrivals"
  bus_departures = call_api(url)
  bus_departures = bus_departures.sort_by { |bus| bus["timeToStation"] }

  if bus_departures.empty?
    puts "No arrivals in the near future"
    return
  end

  max_index = [5, bus_departures.size].min
  (0..max_index-1).each { |i|
    bus = bus_departures[i]
    display_bus(bus)
  }
end

def call_api(url)
  result = Net::HTTP.get(URI.parse(url))
  JSON.parse(result)
end

def display_buses_by_postcode
  puts "Enter postcode:"
  post_code = gets.chomp.gsub(" ", "%20")
  postcode_url = "https://api.postcodes.io/postcodes/" + post_code
  post_code_information = call_api(postcode_url)["result"]
  if(!post_code_information)
    puts "incorrect postcode"
    return
  end
  puts "hello"

  stop_point_ids_by_postcode_url = "https://api.tfl.gov.uk/StopPoint/?lat=#{post_code_information["latitude"]}&lon=#{post_code_information["longitude"]}&stopTypes=NaptanPublicBusCoachTram"
  stop_points_information = call_api(stop_point_ids_by_postcode_url)["stopPoints"]
  for stop_point in stop_points_information
    if !stop_point["lines"].empty?
      puts "Arrivals for #{stop_point["commonName"]}#{stop_point["stopLetter"] ? " - Stop #{stop_point["stopLetter"]}" : "" }:"
      display_buses_by_station_code(stop_point["naptanId"])
      puts
    end
  end





end

def bus_board
  # puts "Enter bus stop code:"
  # bus_code = gets.chomp
  # display_buses_by_station_code(bus_code)
  display_buses_by_postcode

end

bus_board