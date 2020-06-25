include "camera.thrift"

exception ZoomException {
  1: string why
}

exception RotateException {
  1: string why
}

enum Rotate {
  LEFT = 1,
  RIGHT = 2,
  UP = 3,
  DOWN = 4
}

enum Zoom {
  IN = 1,
  OUT = 2
}



service SecurityCamera extends camera.Camera {
  string rotate(Rotate rotate) throws (1:RotateException ouch),
  string zoom(Zoom zoom) throws (1:ZoomException ouch)
}

