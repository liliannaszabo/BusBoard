require 'net/http'
require 'json'

class PagesController < ApplicationController
  def index
  end

  def postcode
    lat,lon = get_coords_by_postcode
    stop_points_information = get_stop_points_by_lat_lon(lat, lon)
    @stops = []
    @length = []

    if stop_points_information == nil
      @errors = "No stops to show"
    else
      stop_points_information.each { |stop_point|
        unless stop_point["lines"].empty?
          bus_departures = fetch_arrivals(stop_point)
          stop_name = stop_point["commonName"]
          stop_letter = stop_point["stopLetter"]
          name = "#{stop_name}#{stop_letter ? " - Stop #{stop_letter}" : "" }:"
          @stops << {
            "name" => name,
            "buses" => bus_departures
          }
        end

      }
    end
  end

  private

  def fetch_arrivals(stop_point)
    url = "https://api.tfl.gov.uk/StopPoint/#{stop_point["naptanId"]}/Arrivals"
    result = Net::HTTP.get(URI.parse(url))
    JSON.parse(result)
        .sort_by { |bus| bus["timeToStation"] }
        .first(5)
  end

  def get_stop_points_by_lat_lon(lat, lon)
    stop_point_ids_by_postcode_url = "https://api.tfl.gov.uk/StopPoint/?lat=#{lat}&lon=#{lon}&stopTypes=NaptanPublicBusCoachTram"
    tfl_result = Net::HTTP.get(URI.parse(stop_point_ids_by_postcode_url))
    JSON.parse(tfl_result)["stopPoints"]
  end

  def get_coords_by_postcode
    postcode_url = "https://api.postcodes.io/postcodes/" + params[:postcode].gsub(" ", "%20")
    result = Net::HTTP.get(URI.parse(postcode_url))
    postcode_information = JSON.parse(result)["result"]
    [postcode_information["latitude"], postcode_information["longitude"]]
  end

end
