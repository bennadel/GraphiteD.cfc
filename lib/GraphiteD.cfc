component
	output = false
	hint = "I attempt to combine a dumbed-down version of the features of StatsD and the hosted Graphite SaaS, Hosted Graphite (https://www.hostedgraphite.com)."
	{

	// I initialize the Hosted Graphite service.
	public any function init( 
		required string aApiKey,
		numeric aFlushInterval = 10,
		numeric aMaxUdpPayloadSize = 8932
		) {

		// I provide a globally-unique ID that allows us to create server-wide locking on this
		// instance of the Graphite component. This way, two instances don't step on each other's 
		// named locks.
		instanceID = createUUID();

		// I am the HostedGraphite.com API key.
		apiKey = aApiKey;

		// I hold the metrics being recorded in a given window of time.
		interval = new Interval( aFlushInterval );

		// I am the different modes of transportation on which we will send data. By default, 
		// we'll try to send messages over UDP.
		udpTransport = new UDPTransport( apiKey, "carbon.hostedgraphite.com", 2003, aMaxUdpPayloadSize );
		httpTransport = new HTTPTransport( apiKey, "https://hostedgraphite.com/api/v1/sink" );

		return( this );

	}

	
	// ---
	// PUBLIC METHODS.
	// ---


	// I record the given counter value.
	public void function recordCounterMetric(
		required string name,
		required numeric value
		) {

		// Synchronize interval access.
		lock
			name = "GraphiteD.Interval.#instanceID#"
			type = "exclusive"
			timeout = 3
			throwOnTimeout = false
			{

			processCurrentInterval();

			interval.recordCounterMetric( name, value );

		} // END: Lock.

	}


	// I record the given gauge value.
	public void function recordGaugeMetric(
		required string name,
		required numeric value
		) {

		// Synchronize interval access.
		lock
			name = "GraphiteD.Interval.#instanceID#"
			type = "exclusive"
			timeout = 3
			throwOnTimeout = false
			{

			processCurrentInterval();

			interval.recordGaugeMetric( name, value );

		} // END: Lock.

	}


	// I record the given timer value.
	public void function recordTimerMetric(
		required string name,
		required numeric value
		) {

		// Synchronize interval access.
		lock
			name = "GraphiteD.Interval.#instanceID#"
			type = "exclusive"
			timeout = 3
			throwOnTimeout = false
			{

			processCurrentInterval();

			interval.recordTimerMetric( name, value );

		} // END: Lock.

	}


	// ---
	// PRIVATE METHODS.
	// ---


	// I flush and reset the current interval, if necessary.
	private void function processCurrentInterval() {

		if ( interval.isActive() ) {

			return;

		}

		var metrics = interval.restart();

		if ( ! arrayLen( metrics ) ) {

			return;

		}

		// We will try to send the metrics in an asynchronous thread; however, if the calling
		// code was running inside of a thread, we'll get an error. In that case, we'll fall 
		// back to sending the metrics synchronously.
		try {

			sendMetricsAsync( metrics );

		} catch ( any error ) {

			sendMetricsSync( metrics );

		}

	}


	// I send the metrics synchronously.
	private void function sendMetricsSync( metrics ) {

		// Try to send over UDP. If that fails, fallback to HTTP.
		try {

			udpTransport.sendMetrics( metrics );
			
		} catch ( any error ) {

			httpTransport.sendMetrics( metrics );

		}

	}


	// I send the metrics asynchronously inside of a thread.
	private void function sendMetricsAsync( metrics ) {

		thread
			action = "run"
			name = "GraphiteD.thread.#instanceID#.#getTickCount()#"
			metrics = metrics 
			{

			sendMetricsSync( metrics );

		}

	}

}