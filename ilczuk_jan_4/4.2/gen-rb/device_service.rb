#
# Autogenerated by Thrift Compiler (0.11.0)
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#

require 'thrift'
require 'device_types'

module DeviceService
  class Client
    include ::Thrift::Client

    def turnOn()
      send_turnOn()
      recv_turnOn()
    end

    def send_turnOn()
      send_message('turnOn', TurnOn_args)
    end

    def recv_turnOn()
      result = receive_message(TurnOn_result)
      return
    end

    def turnOff()
      send_turnOff()
      recv_turnOff()
    end

    def send_turnOff()
      send_message('turnOff', TurnOff_args)
    end

    def recv_turnOff()
      result = receive_message(TurnOff_result)
      return
    end

    def getPower()
      send_getPower()
      return recv_getPower()
    end

    def send_getPower()
      send_message('getPower', GetPower_args)
    end

    def recv_getPower()
      result = receive_message(GetPower_result)
      return result.success unless result.success.nil?
      raise ::Thrift::ApplicationException.new(::Thrift::ApplicationException::MISSING_RESULT, 'getPower failed: unknown result')
    end

  end

  class Processor
    include ::Thrift::Processor

    def process_turnOn(seqid, iprot, oprot)
      args = read_args(iprot, TurnOn_args)
      result = TurnOn_result.new()
      @handler.turnOn()
      write_result(result, oprot, 'turnOn', seqid)
    end

    def process_turnOff(seqid, iprot, oprot)
      args = read_args(iprot, TurnOff_args)
      result = TurnOff_result.new()
      @handler.turnOff()
      write_result(result, oprot, 'turnOff', seqid)
    end

    def process_getPower(seqid, iprot, oprot)
      args = read_args(iprot, GetPower_args)
      result = GetPower_result.new()
      result.success = @handler.getPower()
      write_result(result, oprot, 'getPower', seqid)
    end

  end

  # HELPER FUNCTIONS AND STRUCTURES

  class TurnOn_args
    include ::Thrift::Struct, ::Thrift::Struct_Union

    FIELDS = {

    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class TurnOn_result
    include ::Thrift::Struct, ::Thrift::Struct_Union

    FIELDS = {

    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class TurnOff_args
    include ::Thrift::Struct, ::Thrift::Struct_Union

    FIELDS = {

    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class TurnOff_result
    include ::Thrift::Struct, ::Thrift::Struct_Union

    FIELDS = {

    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class GetPower_args
    include ::Thrift::Struct, ::Thrift::Struct_Union

    FIELDS = {

    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class GetPower_result
    include ::Thrift::Struct, ::Thrift::Struct_Union
    SUCCESS = 0

    FIELDS = {
      SUCCESS => {:type => ::Thrift::Types::I32, :name => 'success', :enum_class => ::Power}
    }

    def struct_fields; FIELDS; end

    def validate
      unless @success.nil? || ::Power::VALID_VALUES.include?(@success)
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Invalid value of field success!')
      end
    end

    ::Thrift::Struct.generate_accessors self
  end

end

