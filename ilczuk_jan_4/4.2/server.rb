# frozen_string_literal: true

$LOAD_PATH.push('gen-rb')

require 'thrift'
require 'thrift/multiplexer'

require 'top_freezer'
require 'compact_fridge'
require 'security_camera'
require 'night_camera'
require 'device_types'
require 'fridge_types'
require 'list_devices'

require 'compact_fridge_types'
require 'security_camera_types'
require 'night_camera_types'

class DeviceHandler
  attr_reader :name
  def initialize(name)
    @name = name
    @power = Power::ON
  end

  def turnOn
    puts 'turnOn()'
    @power = Power::ON
  end

  def turnOff
    puts 'turnOff()'
    @power = Power::OFF
  end

  def getPower
    puts 'getPower'
    @power
  end
end

class FridgeHandler < DeviceHandler
  def initialize(name)
    super
    @temperature = 4.0
    @status = Status::CLOSE
  end

  def getTemperature
    puts 'getTemperature()'
    @temperature
  end

  def setTemperature(temperature)
    puts "setTemperature(#{temperature})"
    if temperature <= 8.0 && temperature >= 0
      @temperature = temperature
    else
      x = BadTemperature.new
      x.why = 'temperature must be between 0 and 8'
      raise x
    end
  end

  def open
    puts 'open'
    @status = Status::OPEN
  end

  def close
    puts 'close'
    @status = Status::CLOSE
  end

  def getStatus
    puts 'getStatus'
    @status
  end
end

class TopFreezerHandler < FridgeHandler
  def initialize(name)
    super
    @freezer_status = Status::CLOSE
    @freezer_temperature = -10.5
  end

  def openFreezer
    puts 'openFreezer()'
    @freezer_status = Status::OPEN
  end

  def closeFreezer
    puts 'closeFreezer()'
    @freezer_status = Status::CLOSE
  end

  def getFreezerStatus
    puts 'getFreezerStatus'
    @freezer_status
  end

  def setFreezerTemperature(temperature)
    puts "setFreezerTemperature(#{temperature})"
    if temperature <= 0.0 && temperature >= -20.0
      @freezer_temperature = temperature
    else
      x = BadTemperature.new
      x.why = 'temperature must be between -20 and 0'
      raise x
    end
  end

  def getFreezerTemperature
    puts 'getFreezerTemperature'
    @freezer_temperature
  end
end

class CompactFridgeHandler < FridgeHandler
  def initialize(name)
    super
    @color = Color::BLUE
  end

  def setColor(color)
    puts 'setColor'
    if [Color::GREEN, Color::BLUE, Color::RED].include? color
      @color = color
    else
      x = BadColor.new
      x.why = 'Color must be red, green or blue'
      raise x
    end
  end

  def getColor
    puts 'getColor'
    @color
  end
end

class CameraHandler < DeviceHandler
  def initialize(name)
    super
    path = 'wow.jpg'
    File.open(path, 'rb') { |file| @image = file.read }
  end

  def getPicture
    puts 'getPicture()'
    @image
  end
end

class SecurityCameraHandler < CameraHandler
  def initialize(name)
    super
    @zoom = 1.0
    @horizontal = 0.0
    @vertical = 0.0
  end

  def zoom(zoom)
    puts 'zoom'
    if zoom == Zoom::IN
      if @zoom + 0.1 > 4.0
        x = ZoomException.new
        x.why = 'Cannot zoom in more'
        raise x
      else
        @zoom += 0.1
      end
    elsif zoom == Zoom::OUT
      if @zoom - 0.1 < 1.0
        x = ZoomException.new
        x.why = 'Cannot zoom out more'
        raise x
      else
        @zoom -= 0.1
      end
    end
    "Current zoom is #{@zoom - 1.0 / 3.0 * 100}%"
  end

  def rotate(rotate)
    puts 'rotate'
    if rotate == Rotate::LEFT
      if @horizontal - 0.1 < -1.0
        x = RotateException.new
        x.why = 'Cannot rotate left more'
        raise x
      else
        @horizontal -= 0.1
      end
    elsif rotate == Rotate::RIGHT
      if @horizontal + 0.1 > 1.0
        x = RotateException.new
        x.why = 'Cannot rotate right more'
        raise x
      else
        @horizontal += 0.1
      end
    elsif rotate == Rotate::UP
      if @vertical + 0.1 > 1.0
        x = RotateException.new
        x.why = 'Cannot rotate up more'
        raise x
      else
        @vertical += 0.1
      end
    elsif rotate == Rotate::DOWN
      if @vertical - 0.1 < -1.0
        x = RotateException.new
        x.why = 'Cannot rotate down more'
        raise x
      else
        @vertical -= 0.1
      end
    end
    "Current rotation is vertical: #{@vertical}, horizontal: #{@horizontal}"
  end
end

class NightCameraHandler < CameraHandler
  def initialize(name)
    super
    @nightvision_status = NightvisionStatus::OFF
  end

  def turnOnNightvision
    puts 'turnNightvisionOn()'
    @nightvision_status = NightvisionStatus::ON
  end

  def turnOffNightvision
    puts 'turnNightvisionOff()'
    @power = NightvisionStatus::OFF
  end

  def getNightvisionStatus
    puts 'getNightvisionStatus'
    @power
  end
end

class ListDevicesHandler
  def initialize(devices)
    @devices = devices
  end

  def getDevices
    puts 'turnNightvisionOn()'
    @devices
  end
end

top_freezer_handler = TopFreezerHandler.new('topFreezer')
compact_fridge_handler = CompactFridgeHandler.new('compactFridge')
security_camera_handler = SecurityCameraHandler.new('securityCamera')
security_camera_handler2 = SecurityCameraHandler.new('securityCamera2')
night_camera_handler = NightCameraHandler.new('nightCamera')
night_camera_handler2 = NightCameraHandler.new('nightCamera2')
list_devices_handler = ListDevicesHandler.new([top_freezer_handler.name, compact_fridge_handler.name, security_camera_handler.name, security_camera_handler2.name, night_camera_handler.name, night_camera_handler2.name])
processor = Thrift::MultiplexedProcessor.new()
processor.register_processor('topFreezer', TopFreezer::Processor.new(top_freezer_handler))
processor.register_processor('compactFridge', CompactFridge::Processor.new(compact_fridge_handler))
processor.register_processor('securityCamera', SecurityCamera::Processor.new(security_camera_handler))
processor.register_processor('nightCamera', NightCamera::Processor.new(night_camera_handler))
processor.register_processor('securityCamera2', SecurityCamera::Processor.new(security_camera_handler2))
processor.register_processor('nightCamera2', NightCamera::Processor.new(night_camera_handler2))
processor.register_processor('listDevices', ListDevices::Processor.new(list_devices_handler))
transport = Thrift::ServerSocket.new(9090)
transportFactory = Thrift::BufferedTransportFactory.new
server = Thrift::SimpleServer.new(processor, transport, transportFactory)

puts 'Starting the server...'
server.serve
puts 'done.'
