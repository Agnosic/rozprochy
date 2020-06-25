enum Power {
  ON = 1,
  OFF = 2
}

service DeviceService {
  void turnOn(),
  void turnOff(),
  Power getPower()
}
