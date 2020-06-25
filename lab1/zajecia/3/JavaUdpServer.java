import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class JavaUdpServer {
  public static void main(String[] args) {
    DatagramSocket socket = null;
    try {
      socket = new DatagramSocket(9876);
      byte[] receiveBuffer = new byte[1024];
      while (true) {
        DatagramPacket receivePacket = new DatagramPacket(receiveBuffer, receiveBuffer.length);
        socket.receive(receivePacket);
        int nb = ByteBuffer.wrap(receivePacket.getData()).order(ByteOrder.LITTLE_ENDIAN).getInt();
        InetAddress address = receivePacket.getAddress();
        int port = receivePacket.getPort();

        byte[] buf = ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(nb + 1).array();
        DatagramPacket packet = new DatagramPacket(buf, 0, buf.length, address, port);
        System.out.println("received msg from address " + address + ": " + nb);

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
