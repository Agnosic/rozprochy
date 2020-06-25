package com.company;

import akka.actor.*;
import akka.event.Logging;
import akka.event.LoggingAdapter;
import akka.japi.pf.DeciderBuilder;
import akka.util.Timeout;
import com.company.model.Item;
import scala.concurrent.Await;

import static akka.actor.SupervisorStrategy.restart;
import static akka.actor.SupervisorStrategy.resume;
import static akka.pattern.Patterns.ask;
import static akka.pattern.Patterns.pipe;

import java.sql.*;
import java.time.Duration;
import java.util.concurrent.TimeoutException;

import scala.concurrent.Future;

public class PriceWorker extends AbstractActor {
    private final LoggingAdapter log = Logging.getLogger(getContext().getSystem(), this);

    private boolean resultFound;
    private ActorRef sender;
    private ActorRef shop1;
    private ActorRef shop2;
    Timeout t = Timeout.create(Duration.ofMillis(300));

    public static final String DRIVER = "org.sqlite.JDBC";
    public static final String DB_URL = "jdbc:sqlite:shop.db";
    private Connection conn;
    private Statement stat;

    @Override
    public AbstractActor.Receive createReceive() {
        return receiveBuilder()
                .match(String.class, s -> {
                        resultFound = false;
                        sender = getSender();
                        int count = upsertItem(s);

                        Future<Object> future1 =
                                ask(shop1, s, t);

                        Future<Object> future2 = ask(shop2, s, t);
                        int price1;
                        int price2;
                        try {
                            price1 = (int) Await.result(future1, t.duration());
                        } catch (TimeoutException e) {
                            price1 = -1;
                        }

                        try {
                            price2 = (int) Await.result(future2, t.duration());
                        } catch (TimeoutException e) {
                            price2 = -1;
                        }
                        if(price1 == -1 && price2 == -1){
                            sender.tell("response no price for that product"  + " and count is " + count, getSelf());
                        } else if(price1 == -1){
                            sender.tell("response price is " + price2 + " and count is " + count, getSelf());
                        } else if(price2 == -1){
                            sender.tell("response price is " + price1 + " and count is " + count, getSelf());
                        } else if(price1 > price2){
                            sender.tell("response price is " + price2 + " and count is " + count, getSelf());
                        } else if(price1 <= price2){
                            sender.tell("response price is " + price1 + " and count is " + count, getSelf());
                        }
                        context().stop(getSelf());

                })
                .matchAny(o -> log.info("received unknown message"))
                .build();
    }

    // optional
    @Override
    public void preStart() throws Exception {
        shop1 = context().actorOf(Props.create(ShopWorker.class));
        shop2 = context().actorOf(Props.create(ShopWorker.class));
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            System.err.println("Brak sterownika JDBC");
            e.printStackTrace();
        }

        try {
            conn = DriverManager.getConnection(DB_URL);
            stat = conn.createStatement();
        } catch (SQLException e) {
            System.err.println("Problem z otwarciem polaczenia");
            e.printStackTrace();
        }
        createTables();
    }

    public boolean createTables()  {
        String createShop = "CREATE TABLE IF NOT EXISTS item (name varchar(255) PRIMARY KEY, count int)";
        try {
            stat.execute(createShop);
        } catch (SQLException e) {
            System.err.println("Blad przy tworzeniu tabeli");
            e.printStackTrace();
            return false;
        }
        return true;
    }

    public int upsertItem(String name) {
        try {
            PreparedStatement upsert = conn.prepareStatement("INSERT INTO item(name, count) VALUES(?, 1) ON CONFLICT(name) DO UPDATE SET count=item.count+1;");
            upsert.setString(1, name);
            upsert.execute();
            ResultSet result = stat.executeQuery("SELECT count FROM item WHERE item.name = \"" + name +"\";");
            return result.getInt("count");

        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }
        return -1;
    }

    @Override
    public void postStop() {
        try {
            conn.close();
        } catch (SQLException throwables) {
            throwables.printStackTrace();
        }
    }

    private static SupervisorStrategy strategy
            = new OneForOneStrategy(1, scala.concurrent.duration.Duration.create("1 minute"), DeciderBuilder.
            match(ArithmeticException.class, x -> resume()).
            // todo: match arithmetic exception
                    matchAny(o -> restart()).
                    build());

    @Override
    public SupervisorStrategy supervisorStrategy() {
        return strategy;
    }
}
