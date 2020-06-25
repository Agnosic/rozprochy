import socket;

serverIP = "127.0.0.1"
serverPort = 9008
msg =  (300).to_bytes(4, byteorder='little')

print('PYTHON UDP CLIENT')
client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client.sendto(msg, (serverIP, serverPort))

reply, addr = client.recvfrom(1024)
value = int.from_bytes(reply, byteorder='little')
print('Server reply : {value}'.format(value=value))



