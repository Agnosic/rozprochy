package com.company;

import akka.actor.AbstractActor;
import akka.event.Logging;
import akka.event.LoggingAdapter;

public class Z2_LocalActor extends AbstractActor {

    private final LoggingAdapter log = Logging.getLogger(getContext().getSystem(), this);

    @Override
    public AbstractActor.Receive createReceive() {

        return receiveBuilder()
                .match(String.class, str -> getContext().actorSelection("akka://remote_system@127.0.0.1:2552/user/remote").tell(str, getSelf()))
                .match(Response.class, response -> System.out.println("Result: " + response.result))
                .matchAny(o -> log.info("received unknown message"))
                .build();
    }
}
