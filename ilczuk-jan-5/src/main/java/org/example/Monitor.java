package org.example;

import org.apache.zookeeper.*;
import org.apache.zookeeper.data.Stat;

import java.io.IOException;
import java.util.List;

import static org.apache.zookeeper.KeeperException.*;

public class Monitor implements Watcher, AsyncCallback.StatCallback {
    ZooKeeper zk;
    String znode;
    String filename;
    Process program = null;



    public Monitor(ZooKeeper zk, String znode, String filename) {
        this.zk = zk;
        this.znode = znode;
        this.filename = filename;
        zk.exists(znode, true, this, null);
        try {
            zk.getChildren(znode, true);
        } catch (KeeperException e) {
        } catch (InterruptedException e) {
        }
    }

    public void process(WatchedEvent event) {
        String path = event.getPath();
        if (event.getType() == Event.EventType.None) {
            System.out.println("nothing");
        } else {
            System.out.println(event);
            if (path != null && path.equals(znode)) {
                if(event.getType() == Event.EventType.NodeDeleted){
                    if(this.program != null) {
                        program.destroy();
                        program = null;
                    }
                }
                if(event.getType() == Event.EventType.NodeCreated){
                    try {
                        program = new ProcessBuilder(filename).start();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
                if(event.getType() == Event.EventType.NodeChildrenChanged){
                    try {
                        System.out.println("There are " + zk.getChildren(znode, true).size() + " /z children");
                    } catch (KeeperException e) {
                    } catch (InterruptedException e) {
                    }
                }

                zk.exists(znode, true, this, null);
            }
        }
    }

    public void processResult(int rc, String path, Object ctx, Stat stat) {
        boolean exists;
        switch (rc) {
            case Code.Ok:
                exists = true;
                break;
            default:
                exists = false;
                zk.exists(znode, true, this, null);
                return;
        }

        byte b[] = null;
        if (exists) {
            try {
                b = zk.getData(znode, false, null);
                if(b != null) {
                    System.out.println(b);
                }
            } catch (KeeperException e) {

            } catch (InterruptedException e) {
                return;
            }
        }
        zk.exists(znode, true, this, null);
    }

    public void printTree() {
        List<String> zkNodes = null;
        try {
            zkNodes = zk.getChildren(this.znode, true);
            for (String node : zkNodes) {
                System.out.println(node);
                printTreeUtil(this.znode + "/" + node, 1);
            }
        } catch (KeeperException e) {
        } catch (InterruptedException e) {
        }
    }

    public void printTreeUtil(String znode, int indent) {
        List<String> zkNodes = null;
        try {
            zkNodes = zk.getChildren(znode, true);
            for (String node : zkNodes) {
                System.out.println("|   ".repeat(indent) + node);
                printTreeUtil(znode + "/" + node, indent + 1);
            }
        } catch (KeeperException e) {
        } catch (InterruptedException e) {
        }

    }
}
