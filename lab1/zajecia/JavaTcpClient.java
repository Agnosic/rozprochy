import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;

public class JavaTcpClient {
  public static void main(String[] args) throws IOException {
    Socket socket = null;
    try {
      socket = new Socket("localhost", 12345);

      PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
      BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));

      out.println("Ping");
      String response = in.readLine();
      System.out.println("received msg: " + response);
    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      if (socket != null)
        socket.close();
    }
  }
}
