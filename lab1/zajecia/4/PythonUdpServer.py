import socket
serverPort = 9009

serverSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
serverSocket.bind(('', serverPort))
buff = []
while True:
  buff, address = serverSocket.recvfrom(1024)
  msg = str(buff, 'utf-8')
  if msg == "JAVA":
    serverSocket.sendto(bytes("PONG JAVA", 'utf-8'), address)
  elif msg == "PYTHON":
    serverSocket.sendto(bytes("PONG PYTHON", "utf-8"), address)
