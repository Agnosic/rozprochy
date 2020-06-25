include "device.thrift"

service Camera extends device.DeviceService {
  binary getPicture()
}

