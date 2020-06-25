require 'socket'
require 'securerandom'

class Server
  def initialize(ip, port)
    @tcp_server = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
    @udp_server = Socket.new(Socket::AF_INET, Socket::SOCK_DGRAM)
    @address = Socket.pack_sockaddr_in(port, ip)
    @tcp_server.bind(@address)
    @udp_server.bind(@address)
    @max_users = Socket::SOMAXCONN
    @tcp_server.listen(@max_users)
    @users = Hash.new
  end

  def run
    Thread.new do
      loop do
        data, addr = @udp_server.recvfrom(1024)
        id = get_id_by_addr(addr)
        @users.each do |_, value|
          puts("#{id}>\n#{data}")
          @udp_server.send("#{id}>\n#{data}", 0, value[1]) if value[1].to_sockaddr != addr.to_sockaddr
        end
      end
    end
    loop do
      Thread.start(@tcp_server.accept) do |connection, addr_info|
        user_id = generate_id
        connection.puts(user_id)
        @users[user_id] = [connection, addr_info]
        puts("#{user_id} has joined")
        @users.each do |id, value|
          value[0].puts("#{user_id} has joined") if id != user_id
        end
        loop do
          handle_tcp(connection, user_id)
        end
      end 
    end
  end

  private

  def handle_tcp(connection, user_id)
    request = connection.gets
    if request.nil?
      puts("#{user_id} has disconnected")
      @users.each do |id, value|
        value[0].puts("#{user_id} has disconnected") if id != user_id
      end
      @users.delete(user_id)
      Thread.kill(Thread.current)
    end
    @users.each do |id, value|
      next if value[0].closed?
      puts("#{user_id}> #{request.chomp}")
      value[0].puts("#{user_id}> #{request.chomp}") if id != user_id
    end
  end

  def generate_id
    id = (0...8).map { (65 + rand(26)).chr }.join
    if @users.values.include? id
      generate_id
    else
      id
    end
  end

  def get_id_by_addr(address) 
    user_id = nil
    @users.each do |id, value|
      user_id = id if value[1].to_sockaddr == address.to_sockaddr
    end
    user_id
  end
end

server = Server.new('127.0.0.1', 9010)
server.run

