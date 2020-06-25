#!/usr/bin/env ruby

# Copyright 2015 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Sample gRPC server that implements the Greeter::Helloworld service.
#
# Usage: $ path/to/greeter_server.rb


this_dir = File.expand_path(File.dirname(__FILE__))
lib_dir = File.join(this_dir, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'grpc'
require '../gen/weather_services_pb'
require 'time'
require 'multi_json'

class CityEnum
  # @param [Hash] feature_db
  # @param [Rectangle] bounds
  def initialize(feature_db, city)
    @feature_db = feature_db
    @city = city
  end

  # in? determines if location lies within the bounds of this instances
  # Rectangle.
  def in?(record)
    record['city'] == @city
  end

  # each yields the features in the instances feature_db that lie within the
  # instance rectangle.
  def each
    return enum_for(:each) unless block_given?
    loop do
      @feature_db.each do |record|
        next unless in?(record)
        yield Weather::WeatherReply.new(date: Time.now, city: @city, weather: record["weather"])
      end
      sleep 1
    end
  end
end

class Server < Weather::WeatherService::Service
  def initialize(feature_db)
    @feature_db = feature_db
    @city_enums = Hash.new
    ['Warsaw', 'Cracow'].each do |city|
      @city_enums[city] = CityEnum.new(@feature_db, city)
    end
  end

  def subscribe(weather_req, _unused_call)
    @city_enums[weather_req.city].each
  end
end

def main
    raw_data = []
    File.open("route_guide_db.json") do |f|
      raw_data = MultiJson.load(f.read)
    end
    feature_db = raw_data
    p raw_data
    s = GRPC::RpcServer.new
    s.add_http2_port('0.0.0.0:50051', :this_port_is_insecure)
    s.handle(Server.new(feature_db))
    # Runs the server with SIGHUP, SIGINT and SIGQUIT signal handlers to 
    #   gracefully shutdown.
    # User could also choose to run server via call to run_till_terminated
    s.run_till_terminated_or_interrupted([1, 'int', 'SIGQUIT'])
end

main
