include "fridge.thrift"

service TopFreezer extends fridge.Fridge {
   void openFreezer(),
   void closeFreezer(),
   fridge.Status getFreezerStatus(),
   void setFreezerTemperature(double temperature) throws (1:fridge.BadTemperature ouch),
   double getFreezerTemperature()
}

