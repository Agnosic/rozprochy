include "camera.thrift"

enum NightvisionStatus {
  ON = 1,
  OFF = 2
}

service NightCamera extends camera.Camera {
  NightvisionStatus getNightvisionStatus(),
  void turnOnNighvision(),
  void turnOffNightvision()
}
