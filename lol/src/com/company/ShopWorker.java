package com.company;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.Props;
import akka.event.Logging;
import akka.event.LoggingAdapter;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class ShopWorker extends AbstractActor {
    private final LoggingAdapter log = Logging.getLogger(getContext().getSystem(), this);

    @Override
    public AbstractActor.Receive createReceive() {
        return receiveBuilder()
                .match(String.class, s -> {
                    Thread.sleep((long)(Math.random() * 400 + 100));
                    getSender().tell((int)(Math.random() * 9 + 1), getSelf());
                })
                .matchAny(o -> log.info("received unknown message"))
                .build();
    }
}
