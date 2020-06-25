defmodule Agency do
  require Logger

  def wait_for_messages(params) do
    receive do
      {:basic_deliver, payload, meta} ->
        Logger.info(" [x] Received [#{meta.routing_key}] #{payload}")

        wait_for_messages(params)
    end
  end

  def read(%AMQP.Channel{} = channel, agency_name, order_number \\ 1) do
    case IO.read(:stdio, :line) do
      :eof ->
        :ok

      {:error, reason} ->
        IO.puts("Error: #{reason}")

      data ->
        handle_data(channel, agency_name, data, order_number)
    end

    read(channel, agency_name, order_number + 1)
  end

  defp handle_data(%AMQP.Channel{} = channel, agency_name, data, order_number)
       when is_binary(data) do
    data
    |> parse_data
    |> case do
      {:ok, [topic, message]} ->
        key = "#{agency_name}.#{topic}.#{order_number}"

        AMQP.Basic.publish(channel, "galaxy", key, message, persistant: true)
        Logger.info(" [x] Sent '[#{key}] #{message}'")

      {:error, reason} ->
        IO.puts(reason)
    end
  end

  defp parse_data(data) when is_binary(data) do
    data
    |> String.split(" ", trim: true)
    |> case do
      [topic | message_data] when length(message_data) >= 1 ->
        {:ok, [topic, message_data |> Enum.join(" ") |> String.replace("\n", "")]}

      _ ->
        {:error, "You must provide topic(passangers | cargo | satellite)"}
    end
  end
end
require Logger
{:ok, connection} = AMQP.Connection.open()
{:ok, channel} = AMQP.Channel.open(connection)

agency_name =
  System.argv()
  |> case do
    [agency_name] ->
      agency_name

    _ ->
      IO.puts("Usage: mix run lib/agency.exs agency_name")
      System.halt(1)
  end

AMQP.Exchange.declare(channel, "galaxy", :topic, durable: true)

AMQP.Queue.declare(channel, agency_name)

AMQP.Queue.bind(channel, agency_name, "galaxy", routing_key: "#{agency_name}")
AMQP.Basic.consume(channel, agency_name, nil, no_ack: true)

{:ok, admin_channel} = AMQP.Channel.open(connection)

exchange = "galaxy_administration"

AMQP.Exchange.declare(admin_channel, exchange, :direct, durable: true)

AMQP.Queue.declare(admin_channel, "administrator")

AMQP.Queue.declare(admin_channel, agency_name)

for topic <- ["agency", "all"] do
  AMQP.Queue.bind(admin_channel, agency_name, exchange, routing_key: "#{topic}")
  AMQP.Basic.consume(admin_channel, agency_name, nil, no_ack: true)
end

t = Task.async(Agency, :read, [channel, agency_name])

Agency.wait_for_messages(%{channel: channel, admin_channel: admin_channel})
Task.await(t, :infinity)

