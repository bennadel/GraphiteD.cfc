component
	output = false 
	hint = "I provide the container for stats collected within a given flush interval."
	{

	// Note from the HostedGraphite support:
	// --
	// > .... the 180s resolution limiting isn't applied yet, it's mostly a marketing thing
	// > for now. You have access to all the resolutions, all the way down to 5s. We'll be 
	// > limiting this in future to at least 30s, but we probably won't go beyond that. Not
	// > sure yet, those plans aren't firm.
	// > 
	// > For ease of use, it might be worth setting your flushinterval to 30s, but it's 
	// > not a big deal and almost all our users use 10s.



	// I initialize the interval.
	public any function init( required numeric aFlushInterval ) {

		// I am the duration of the interval in seconds. This is the amount of time that the 
		// metrics will buffer until they are flushed to HostedGraphite (roughly - depends on 
		// cotinuous usage).
		flushInterval = aFlushInterval;

		// I contain the time-delimiters for the interval.
		startedAtUtcSeconds = fix( getTickCount() / 1000 );
		endedAt = dateAdd( "s", flushInterval, now() );

		// These hold the various metrics, indexed by metric name.
		counters = {};
		timers = {};
		gauges = {};

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I get all the metrics for the current interval (recorded up until the invocation).
	public array function getMetrics() {

		var metrics = [];

		// NOTE: When gathering metrics and creating "off-shoots" of the given metric, we cannot 
		// mix "containers" and "items". Meaning, that you cannot use these two metric names at
		// the same time:
		// --
		// foo.bar
		// foo.bar.per_second
		// --
		// If you do this the "foo.bar" name will only show up as a "container" in the
		// HostedGraphite Composer and you will not be able to access any metrics stored under 
		// said value. As such, make sure to use unique paths in the metric names.	

		// Collect counter metrics.
		for ( var metricName in counters ) {

			var counter = counters[ metricName ];

			arrayAppend(
				metrics,
				{
					name = ( counter.getName() & ".total" ),
					value = counter.getValue(),
					timestamp = startedAtUtcSeconds
				}
			);

			arrayAppend(
				metrics,
				{
					name = ( counter.getName() & ".per_second" ),
					value = ( counter.getValue() / flushInterval ),
					timestamp = startedAtUtcSeconds
				}
			);

		}

		// Collect timer metrics.
		for ( var metricName in timers ) {

			var timer = timers[ metricName ];

			arrayAppend(
				metrics,
				{
					name = ( timer.getName() & ".count" ),
					value = timer.getCount(),
					timestamp = startedAtUtcSeconds
				}
			);

			arrayAppend(
				metrics,
				{
					name = ( timer.getName() & ".total" ),
					value = timer.getTotalValue(),
					timestamp = startedAtUtcSeconds
				}
			);

			arrayAppend(
				metrics,
				{
					name = ( timer.getName() & ".min" ),
					value = timer.getMinValue(),
					timestamp = startedAtUtcSeconds
				}
			);

			arrayAppend(
				metrics,
				{
					name = ( timer.getName() & ".max" ),
					value = timer.getMaxValue(),
					timestamp = startedAtUtcSeconds
				}
			);

			arrayAppend(
				metrics,
				{
					name = ( timer.getName() & ".average" ),
					value = timer.getAverageValue(),
					timestamp = startedAtUtcSeconds
				}
			);

		}

		// Collect gauge metrics.
		for ( var metricName in gauges ) {

			var gauge = gauges[ metricName ];

			arrayAppend(
				metrics,
				{
					name = gauge.getName(),
					value = gauge.getValue(),
					timestamp = startedAtUtcSeconds
				}
			);

		}

		return( metrics );

	}


	// I determine if the interval is currently active (and can/should receive more metrics).
	public boolean function isActive() {

		return( endedAt > now() );

	}


	// I determine if the interval has past it's end date (and should not receive more metrics).
	public boolean function isOver() {

		return( ! isActive() );

	}


	// I record the given counter value. If no counter exists (with the given name) one is 
	// automatically created.
	public void function recordCounterMetric(
		required string metricName,
		required numeric value
		) {

		if ( ! structKeyExists( counters, metricName ) ) {

			counters[ metricName ] = new Counter( metricName );

		}

		counters[ metricName ].recordValue( value );

	}


	// I record the given gauge value. If no gauge exists (with the given name) one is 
	// automatically created.
	public void function recordGaugeMetric(
		required string metricName,
		required numeric value
		) {

		if ( ! structKeyExists( gauges, metricName ) ) {

			gauges[ metricName ] = new Gauge( metricName );

		}

		gauges[ metricName ].recordValue( value );

	}


	// I record the given timer value. If no timer exists (with the given name) one is 
	// automatically created.
	public void function recordTimerMetric(
		required string metricName,
		required numeric value
		) {

		if ( ! structKeyExists( timers, metricName ) ) {

			timers[ metricName ] = new Timer( metricName );

		}

		timers[ metricName ].recordValue( value );

	}


	// I restart the interval, resetting each metric on record. The metrics from the previous
	// interval are returned.
	public array function restart() {

		var previousMetrics = getMetrics();

		// Reset the start/end time for the interval.
		startedAtUtcSeconds = fix( getTickCount() / 1000 );
		endedAt = dateAdd( "s", flushInterval, now() );

		// Reset counters.
		for ( var metricName in counters ) {

			counters[ metricName ].reset();

		}

		// Reset timers.
		for ( var metricName in timers ) {

			timers[ metricName ].reset();

		}

		// Reset gauges.
		for ( var metricName in gauges ) {

			gauges[ metricName ].reset();

		}

		return( previousMetrics );

	}

}