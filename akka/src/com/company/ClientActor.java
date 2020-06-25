package com.company;

import akka.actor.AbstractActor;
import akka.actor.OneForOneStrategy;
import akka.actor.Props;
import akka.actor.SupervisorStrategy;
import akka.event.Logging;
import akka.event.LoggingAdapter;
import akka.japi.pf.DeciderBuilder;
import scala.concurrent.duration.Duration;

import static akka.actor.SupervisorStrategy.restart;
import static akka.actor.SupervisorStrategy.resume;

public class ClientActor extends AbstractActor {
    // for logging
    private final LoggingAdapter log = Logging.getLogger(getContext().getSystem(), this);

    // must be implemented -> creates initial behaviour
    @Override
    public AbstractActor.Receive createReceive() {
        return receiveBuilder()
                .match(String.class, s -> {
                    if (s.startsWith("f")) {
                        context().actorOf(Props.create(PriceWorker.class)).tell(s.substring(2, s.length()), getSelf()); // send task to child
                    } else if (s.startsWith("response")) {
                        System.out.println(s);              // result from child
                    }
                })
                .matchAny(o -> log.info("received unknown message"))
                .build();
    }

    private static SupervisorStrategy strategy
            = new OneForOneStrategy(10, Duration.create("1 minute"), DeciderBuilder.
            match(ArithmeticException.class, x -> resume()).
            // todo: match arithmetic exception
                    matchAny(o -> restart()).
                    build());

    @Override
    public SupervisorStrategy supervisorStrategy() {
        return strategy;
    }
}
