require 'net/http'
require 'json'

POSTCODE_BASE_API = "https://api.postcodes.io/postcodes/"
TFL_BASE_API = "https://api.tfl.gov.uk/StopPoint/"



class PagesController < ApplicationController
  def index
  end

  def postcode
    lat,lon = get_coords_by_postcode
    if lat == nil && lon == nil
      flash[:error] = "Invalid postcode. Please try again."
      redirect_to root_path
    else
      stop_points_information = get_stop_points_by_lat_lon(lat, lon)
      if stop_points_information == nil
        flash[:error] = "No bus stations nearby"
        redirect_to root_path
      else
        @stops = []
        @length = []
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
  end

  private

  def fetch_arrivals(stop_point)
    url = "#{TFL_BASE_API}#{stop_point["naptanId"]}/Arrivals"
    result = Net::HTTP.get(URI.parse(url))
    JSON.parse(result)
        .sort_by { |bus| bus["timeToStation"] }
        .first(5)
  end

  def get_stop_points_by_lat_lon(lat, lon)
    stop_point_ids_by_postcode_url = "#{TFL_BASE_API}?lat=#{lat}&lon=#{lon}&stopTypes=NaptanPublicBusCoachTram"
    tfl_result = Net::HTTP.get(URI.parse(stop_point_ids_by_postcode_url))
    JSON.parse(tfl_result)["stopPoints"]
  end


  def get_coords_by_postcode
    postcode_url = POSTCODE_BASE_API + params[:postcode].gsub(" ", "%20")
    result = Net::HTTP.get(URI.parse(postcode_url))
    postcode_information = JSON.parse(result)["result"]
    if postcode_information == nil
      return [nil,nil]
    end
    [postcode_information["latitude"], postcode_information["longitude"]]
  end

end
