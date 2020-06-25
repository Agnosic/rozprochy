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
"""The Python implementation of the GRPC helloworld.Greeter client."""

from __future__ import print_function
import logging

import grpc
import time

import sys
sys.path.insert(0,'../gen')

import weather_pb2
import weather_pb2_grpc
import threading


def run(channel, city):
    stub = weather_pb2_grpc.WeatherServiceStub(channel)
    while True:
        try:
            responses = stub.subscribe(weather_pb2.WeatherRequest(city=city))
            for response in responses:
                print(f'Received message: {response}')
        except KeyboardInterrupt:
            print("KeyboardInterrupt")
            channel.unsubscribe(close_callback)
            exit()
        except grpc._channel._MultiThreadedRendezvous as err:
            print(err)
            print("Server cannot be reached")
            time.sleep(1)

def close_callback(channel):
    channel.close()


if __name__ == '__main__':
    logging.basicConfig()
    channel = grpc.insecure_channel(target='localhost:50051')
    for city in sys.argv[1:]:
        threading.Thread(target=run, args=(channel, city)).start()
