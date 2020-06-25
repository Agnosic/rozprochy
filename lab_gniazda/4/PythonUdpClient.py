import socket;

serverIP = "127.0.0.1"
serverPort = 9009
msg = "1Ping Python Udp!"

print('PYTHON UDP CLIENT')
client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client.sendto(bytes(msg, 'cp1250'), (serverIP, serverPort))
buff, address = client.recvfrom(1024)
print(str(buff, 'utf-8'))





