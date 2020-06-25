defmodule Administrator do
  require Logger

  @spec wait_for_messages(AMQP.Channel.t()) :: any
  def wait_for_messages(%AMQP.Channel{} = channel) do
    receive do
      {:basic_deliver, payload, meta} ->
        Logger.info(" [x] Received [#{meta.routing_key}] #{payload}")

        wait_for_messages(channel)
    end
  end

  def read(%AMQP.Channel{} = channel) do
    case IO.read(:stdio, :line) do
      :eof ->
        :ok

      {:error, reason} ->
        Logger.error("Error: #{reason}")

      data ->
        handle_data(channel, data)
    end

    read(channel)
  end

  defp handle_data(%AMQP.Channel{} = channel, data)
       when is_binary(data) do
    data
    |> parse_data
    |> case do
      {:ok, [topic, message]} ->
        key = "#{topic}"

        AMQP.Basic.publish(channel, "galaxy_administration", key, message, persistant: true)
        Logger.info(" [x] Sent '[#{key}] #{message}'")

      {:error, reason} ->
        Logger.error(reason)
    end
  end

  defp parse_data(data) when is_binary(data) do
    data
    |> String.split(" ", trim: true)
    |> case do
      [topic | message_data] when length(message_data) >= 1 ->
        {:ok, [topic, message_data |> Enum.join(" ") |> String.replace("\n", "")]}

      _ ->
        {:error, "You must provide topic(all | agency | carrier)"}
    end
  end
end

{:ok, connection} = AMQP.Connection.open()
{:ok, channel} = AMQP.Channel.open(connection)

exchange = "galaxy"

AMQP.Exchange.declare(channel, exchange, :topic, durable: true)

AMQP.Queue.declare(channel, "administrator")

AMQP.Queue.bind(channel, "administrator", exchange, routing_key: "#")
AMQP.Basic.consume(channel, "administrator", nil, no_ack: true)

{:ok, admin_channel} = AMQP.Channel.open(connection)

exchange = "galaxy_administration"

AMQP.Exchange.declare(admin_channel, exchange, :direct, durable: true)

AMQP.Queue.declare(admin_channel, "administrator")

IO.puts(" [*] Waiting for messages. To exit press CTRL+C, CTRL+C")


t = Task.async(Administrator, :read, [admin_channel])

Administrator.wait_for_messages(channel)
Task.await(t, :infinity)
