component
	output = false
	hint = "I send the metrics to HostedGraphite using UDP."
	{

	// I initialize the transporter.
	public any function init(
		required string aApiKey,
		required string aRemoteHost,
		required numeric aRemotePort,
		required numeric aMaxPayloadSize
		) {

		apiKey = aApiKey;
		remoteHost = aRemoteHost;
		remotePort = aRemotePort;

		// I am the Datagram socket over which messages will be sent.
		socket = createDatagramSocket();

		// I am the maximum number of bytes that we will attempt to send over UPD.
		maxPayloadSize = min( aMaxPayloadSize, 65000 );

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I send the metrics over UTP. If the payload it too big for a UDP packet (as defined
	// by the maxPayloadSize), I will raise an exception.
	public void function sendMetrics( required array metrics ) {

		var requestPayload = buildPayload( metrics );

		// UDP packets can only hold about 65,000 bytes; if the payload is too big, we'll risk
		// truncating the data. In this case, we are using the max size tweaked for the current
		// environment.
		if ( isPayloadTooLarge( requestPayload ) ) {

			throw( type = "GraphiteD.TooLargeForUDP" );

		}

		var packet = createDatagramPacket( requestPayload );

		socket.send( packet );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	// I flatten the metrics for use in an UDP post.
	private string function buildPayload( required array metrics ) {

		var messages = [];

		for ( var metric in metrics ) {

			arrayAppend( messages, "#apiKey#.#metric.name# #metric.value# #metric.timestamp#" );

		}

		return( arrayToList( messages, chr( 10 ) ) );

	}


	// I create the Java DatagramPacket representation of the message.
	private any function createDatagramPacket( required string payload ) {

		var address = createObject( "java", "java.net.InetAddress" ).getByName( javaCast( "string", remoteHost ) );

		var port = javaCast( "int", remotePort );

		var packet = createObject( "java", "java.net.DatagramPacket" ).init(
			charsetDecode( payload, "utf-8" ),
			javaCast( "int", len( payload ) ),
			address,
			port
		);

		return( packet );

	}


	// I create the Java DatagramSocket over which the messages will be sent.
	private any function createDatagramSocket() {

		// NOTE: By using "null" as our constructor argument, we are not binding to any
		// particular inbound port (since we don't need to).
		var socket = createObject( "java", "java.net.DatagramSocket" ).init( javaCast( "null", "" ) );

		return( socket );

	}


	// I determine if the given payload it too large to send over UDP.
	private boolean function isPayloadTooLarge( required string payload ) {

		return( len( payload ) > maxPayloadSize );

	}

}