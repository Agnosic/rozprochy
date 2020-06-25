import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;

public class JavaUdpServer {
  public static void main(String[] args) {
    DatagramSocket socket = null;
    try {
      socket = new DatagramSocket(9876);
      byte[] receiveBuffer = new byte[1024];
      while (true) {
        DatagramPacket receivePacket = new DatagramPacket(receiveBuffer, receiveBuffer.length);
        socket.receive(receivePacket);
        InetAddress address = receivePacket.getAddress();
        int port = receivePacket.getPort();

        String msg = new String(receivePacket.getData());
        byte[] buf = "Pong".getBytes();
        DatagramPacket packet = new DatagramPacket(buf, 0, buf.length, address, port);
        System.out.println("received msg from address " + address + ": " + msg);

        socket.send(packet);
      }
    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      if (socket != null)
        socket.close();
    }
  }
}
