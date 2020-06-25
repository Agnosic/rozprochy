import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;

/**
 * JavaUdpClient
 */
public class JavaUdpClient {
  public static void main(String[] args) {
    DatagramSocket socket = null;
    try {
      socket = new DatagramSocket();

      InetAddress address = InetAddress.getByName("localhost");
      byte[] sendBuffer = "JAVA".getBytes();
      DatagramPacket sendPacket = new DatagramPacket(sendBuffer, sendBuffer.length, address, 9009);
      socket.send(sendPacket);
      byte[] buf = new byte[1024];
      DatagramPacket packet = new DatagramPacket(buf, buf.length);
      socket.receive(packet);
      String received = new String(packet.getData(), 0, packet.getLength());
      System.out.println("received msg: " + received);

    } catch (Exception e) {
      e.printStackTrace();
    } finally {
      if (socket != null)
        socket.close();
    }
  }
}
