# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: weather.proto

require 'google/protobuf'

require 'google/protobuf/timestamp_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("weather.proto", :syntax => :proto3) do
    add_message "weather.WeatherRequest" do
      optional :city, :string, 1
    end
    add_message "weather.WeatherReply" do
      optional :date, :message, 1, "google.protobuf.Timestamp"
      optional :city, :string, 2
      repeated :weather, :message, 3, "weather.Weather"
    end
    add_message "weather.Weather" do
      optional :temperature, :float, 1
      optional :description, :enum, 2, "weather.Description"
      optional :wind, :message, 3, "weather.Wind"
      optional :district, :string, 4
    end
    add_message "weather.Wind" do
      optional :speed, :float, 1
      optional :deg, :float, 2
    end
    add_enum "weather.Description" do
      value :SUNNY, 0
      value :CLOUDY, 1
      value :RAINY, 2
      value :SNOWY, 3
      value :STORMY, 4
    end
  end
end

module Weather
  WeatherRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("weather.WeatherRequest").msgclass
  WeatherReply = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("weather.WeatherReply").msgclass
  Weather = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("weather.Weather").msgclass
  Wind = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("weather.Wind").msgclass
  Description = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("weather.Description").enummodule
end
