import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;

public class JavaTcpServer {
  public static void main(String[] args) throws IOException {
    ServerSocket serverSocket = null;
    try {
      serverSocket = new ServerSocket(12345);
      while (true) {
        Socket clientSocket = serverSocket.accept();

        PrintWriter out = new PrintWriter(clientSocket.getOutputStream(), true);
        BufferedReader in = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));

        String msg = in.readLine();
        System.out.println("received msg: " + msg);
        out.println("Pong");
        clientSocket.close();
      }
    } catch (IOException e) {
      e.printStackTrace();
    } finally {
      if (serverSocket != null)
        serverSocket.close();
    }
  }
}
