include "device.thrift"

exception BadTemperature {
  1: string why
}

enum Status {
  OPEN = 1,
  CLOSE = 2
}

service Fridge extends device.DeviceService {

   void setTemperature(double temperature) throws (1:BadTemperature ouch),
   double getTemperature(),
   void open(),
   void close(),
   Status getStatus()
}

