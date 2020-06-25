include "fridge.thrift"

exception BadColor {
  1: string why
}

enum Color {
   BLUE = 1,
   RED = 2,
   GREEN = 3
}

service CompactFridge extends fridge.Fridge {
   void setColor(Color color) throws (1:BadColor ouch),
   Color getColor()
}

