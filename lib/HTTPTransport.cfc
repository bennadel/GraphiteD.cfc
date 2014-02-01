component
	output = false
	hint = "I send the metrics to HostedGraphite using HTTP."
	{

	// I initialize the transporter.
	public any function init(
		required string aApiKey,
		required string aRemoteResource
		) {

		apiKey = aApiKey;
		remoteResource = aRemoteResource;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I send the metrics over HTTP, with a 1-second timeout (ie, the HTTP request will not 
	// wait more than 1-second before moving on). This is my best attempt to make the method
	// non-blocking without dipping into the Java layer.
	public void function sendMetrics( required array metrics ) {

		var requestPayload = buildPayload( metrics );

		var apiRequest = new Http(
			url = remoteResource,
			method = "post",
			username = apiKey,
			password = "",
			timeout = 1
		);

		apiRequest.addParam(
			type = "body",
			value = requestPayload
		);

		var result = apiRequest.send();
		// .getPrefix() -- get the CFHttp response.
		// .getResult() -- get the file content.			

	}


	// ---
	// PRIVATE METHODS.
	// ---


	// I flatten the metrics for use in an HTTP post.
	private string function buildPayload( required array metrics ) {

		var messages = [];

		for ( var metric in metrics ) {

			arrayAppend( messages, "#metric.name# #metric.value# #metric.timestamp#" );

		}

		return( arrayToList( messages, chr( 10 ) ) );

	}

}