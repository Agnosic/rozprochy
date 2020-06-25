require "socket"
require "json"

class Client
  MULTICAST_ADDR = "224.6.8.11"
  BIND_ADDR = "0.0.0.0"
  PORT = 6811

  def initialize(ip, port)
    @tcp_server =  Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    @udp_server =  Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM)
    address = Socket.pack_sockaddr_in(port, ip)
    @tcp_server.connect address
    @udp_server.bind(@tcp_server.local_address)
    @udp_server.connect address
    @ip = ip
    @port = port
    
    @multicast = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM)
    @multicast.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, bind_address)
    # @multicast.setsockopt(:IPPROTO_IP, :IP_MULTICAST_TTL, 1)
    @multicast.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1) # Socket::INADDR_ANY == "0.0.0.0"
    @multicast.bind(Socket.pack_sockaddr_in(PORT, BIND_ADDR))
  end

  def run
    @id = @tcp_server.gets.chomp
    puts "Succesfully connected to server, you id is #{@id}"
    listen
    send
  end


  def listen
    Thread.new do
      loop do
        handle_msg(@tcp_server.gets)
      end
    end
    Thread.new do
      loop do
        data, addr = @udp_server.recvfrom(1024)
        handle_msg(data)
      end
    end
    Thread.new do
      loop do
        data, _ = @multicast.recvfrom(1024)
        msg = JSON.parse(data)
        puts(msg["data"]) if msg["id"] != @id
      end
    end
  end

  def send
    Thread.new do
      loop do
        msg = $stdin.gets
        if msg[0] == "U"
          data = File.read(msg[2..-1].chomp)
          @udp_server.puts(data)
        elsif msg[0] == "M"
          data = File.read(msg[2..-1].chomp)
          data = {id: @id, data: "#{@id}>\n#{data}"}
          @multicast.send(data.to_json, 0, Socket.pack_sockaddr_in(PORT, MULTICAST_ADDR))
        else 
          @tcp_server.puts(msg) unless msg.empty?
        end
      end
    end.join
  end

  private

  def handle_msg(msg)
    if msg.nil?
      puts "Server stopped working"
      exit
    else
      puts(msg.chomp)
    end
  end

  def bind_address
    IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR).hton
  end
end

client = Client.new('127.0.0.1', 9010)
client.run


