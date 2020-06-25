defmodule Server do
  use GenServer

  def start_link(port \\ 9008) do
    GenServer.start_link(__MODULE__, port)
  end

  def init(port) do
    :gen_udp.open(port, [:binary, active: true])
  end
end
