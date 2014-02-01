
# GraphiteD - An Exploration of HostedGraphite.com Using ColdFusion

by [Ben Nadel][bennadel] (on [Google+][googleplus])

GraphiteD is a dumbed-down exploration of the Graphite SaaS, [HostedGraphite.com][hostedgraphite],
written in ColdFusion. The root component, GraphiteD.cfc, buffers metrics (somewhat similar to
the way that [StatsD][statsd] would) before flushing them to HostedGraphite.com over UDP (with a
fallback to HTTP). Since there is no external service running, GraphiteD.cfc depends on continuous
use in order to flush the buffered metrics.

To instantiate the GraphiteD component, all you need to do is pass it your HostedGraphite.com API
key:

* GraphiteD( apiKey [, interval [, maxUdpPayloadSize ] ] );

... then, to start logging metrics, you can use one of the three recording methods:

* recordCounterMetric( name, value );
* recordGaugeMetric( name, value );
* recordTimerMetric( name, value );

### Why This Is Not As Good As StatsD

This was intended as an exploration of the Graphite SaaS [HostedGraphite.com][hostedgraphite]; it
was not intended to replace the use of the [StatsD][statsd] Node.js daemon (by Etsy). This 
ColdFusion component has a number of inherit limitations:

1. Due to the use of shared memory space, it has to implement locking. Granted, the locking is
extremely light-weight; but, it is locking nonetheless. It would be better to defer locking to a
Node.js daemon outside of the ColdFusion workflow.
2. Since the metrics cache is inside of a ColdFusion component instance, it cannot aggregate stats
across different instances of ColdFusion on different machines in the same application.

That said, I guess the benefit of GraphiteD is that you don't have to have Node.js installed in
order to run StatsD.


[bennadel]: http://www.bennadel.com
[googleplus]: https://plus.google.com/108976367067760160494?rel=author
[hostedgraphite]: https://www.hostedgraphite.com
[statsd]: https://github.com/etsy/statsd
