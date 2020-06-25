# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
import grpc

import weather_pb2 as weather__pb2


class WeatherServiceStub(object):
    """The greeting service definition.
    """

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.subscribe = channel.unary_stream(
                '/weather.WeatherService/subscribe',
                request_serializer=weather__pb2.WeatherRequest.SerializeToString,
                response_deserializer=weather__pb2.WeatherReply.FromString,
                )


class WeatherServiceServicer(object):
    """The greeting service definition.
    """

    def subscribe(self, request, context):
        """Sends a greeting
        """
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_WeatherServiceServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'subscribe': grpc.unary_stream_rpc_method_handler(
                    servicer.subscribe,
                    request_deserializer=weather__pb2.WeatherRequest.FromString,
                    response_serializer=weather__pb2.WeatherReply.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'weather.WeatherService', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))


 # This class is part of an EXPERIMENTAL API.
class WeatherService(object):
    """The greeting service definition.
    """

    @staticmethod
    def subscribe(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_stream(request, target, '/weather.WeatherService/subscribe',
            weather__pb2.WeatherRequest.SerializeToString,
            weather__pb2.WeatherReply.FromString,
            options, channel_credentials,
            call_credentials, compression, wait_for_ready, timeout, metadata)
