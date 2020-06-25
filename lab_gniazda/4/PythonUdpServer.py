import socket;

serverPort = 9009
serverSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
serverSocket.bind(('', serverPort))
buff = []

print('PYTHON UDP SERVER')

while True:

    buff, address = serverSocket.recvfrom(1024)
    msg = str(buff, 'utf-8')
    if msg[0] == '0':
        serverSocket.sendto(bytes("PONG JAVA", 'utf-8'), address)
    elif msg[0] == "1":
        serverSocket.sendto(bytes("PONG PYTHON", "utf-8"), address)



