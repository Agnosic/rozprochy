defmodule Carrier do
  require Logger

  @spec wait_for_messages(AMQP.Channel.t()) :: any
  def wait_for_messages(%{carrier_name: carrier_name, channel: channel, admin_channel: admin_channel} = params) do
    receive do
      {:basic_deliver, payload, meta} ->
        Logger.info(" [x] Received [#{meta.routing_key}] #{payload}")

        unless meta.routing_key in ["all", "carrier"] do
          AMQP.Basic.ack(channel, meta.delivery_tag)
          key = meta.routing_key |> String.split(".") |> Enum.at(0)
          AMQP.Basic.publish(channel, "galaxy", key, "#{meta.routing_key} by #{carrier_name} has been delivered", persistant: true)
        end

        wait_for_messages(params)
    end
  end

  def configure(exchange, %AMQP.Channel{} = channel) do
    if length(System.argv()) in 0..2 do
      IO.puts("Usage: mix run carrier.exs carrier_name [passangers | cargo | satellite]{2,}")
      System.halt(1)
    end

    [_ | topics] = System.argv()
    for topic <- topics do
      AMQP.Queue.bind(channel, topic, exchange, routing_key: "*.#{topic}.*")
      AMQP.Basic.consume(channel, topic, nil, no_ack: false)
    end
  end
end

{:ok, connection} = AMQP.Connection.open()
{:ok, channel} = AMQP.Channel.open(connection)

exchange = "galaxy"

carrier_name = System.argv() |> Enum.at(0)

AMQP.Exchange.declare(channel, exchange, :topic, durable: true)
AMQP.Basic.qos(channel, prefetch_count: 1)

AMQP.Queue.declare(channel, "passangers")
AMQP.Queue.declare(channel, "cargo")
AMQP.Queue.declare(channel, "satellite")

Carrier.configure(exchange, channel)

{:ok, admin_channel} = AMQP.Channel.open(connection)

exchange = "galaxy_administration"

AMQP.Exchange.declare(admin_channel, exchange, :direct, durable: true)



AMQP.Queue.declare(admin_channel, "administrator")

AMQP.Queue.declare(admin_channel, carrier_name)

for topic <- ["carrier", "all"] do
  AMQP.Queue.bind(admin_channel, carrier_name, exchange, routing_key: "#{topic}")
  AMQP.Basic.consume(admin_channel, carrier_name, nil, no_ack: true)
end

IO.puts(" [*] Waiting for messages. To exit press CTRL+C, CTRL+C")

Carrier.wait_for_messages(%{carrier_name: carrier_name, channel: channel, admin_channel: admin_channel})
