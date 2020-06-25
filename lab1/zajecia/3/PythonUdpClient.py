import socket
serverIP = "127.0.0.1"
serverPort = 9876
msg = (300).to_bytes(4, byteorder='little')
client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client.sendto(msg, (serverIP, serverPort))
d = client.recvfrom(1024)
reply = d[0]
addr = d[1]
value = int.from_bytes(reply, byteorder='little')
print('Server reply : {value}'.format(value=value))
