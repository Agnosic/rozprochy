package org.example;

import org.apache.zookeeper.*;
import org.apache.zookeeper.server.admin.JsonOutputter;

import javax.xml.crypto.Data;
import java.io.*;
import java.sql.Statement;

/**
 * Hello world!
 *
 */
public class App implements Watcher
{
    Monitor monitor;
    ZooKeeper zooKeeper;
    String filename;

    public App(String hostPort, String znode, String filename) throws IOException {
        this.filename = filename;
        this.zooKeeper = new ZooKeeper(hostPort, 3000, this);
        this.monitor = new Monitor(this.zooKeeper, znode, filename);
    }

    public static void main(String[] args ) throws IOException, KeeperException, InterruptedException {
        String hostPort = "127.0.0.1:2181";
        String znode = "/z";
        String filename = args[0];

        App app = new App(hostPort, znode, filename);

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        String line;
        while(true) {
            line = br.readLine();
            if(line.startsWith("tree")) {
                app.printTree();
            }
        }
    }

    public void process(WatchedEvent event) {
        monitor.process(event);
    }

    public void printTree() throws KeeperException, InterruptedException {
        monitor.printTree();
    }




}
