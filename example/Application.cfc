component
	output = false
	hint = "I define the application settings and event handlers."
	{

	// I define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 1, 0, 0 );
	this.sessionManagement = false;

	// Get the various directories needed for mapping.
	this.directory = getDirectoryFromPath( getCurrentTemplatePath() );
	this.projectDirectory = ( this.directory & "../" );

	// Map the library so we can instantiate components.
	this.mappings[ "/lib" ] = "#this.projectDirectory#lib/";


	// I initialize the application.
	public boolean function onApplicationStart() {

		// Load the HostedGraphite.com configuration data.
		// --
		// NOTE: This is not part of the Git repository. You have to create a file with the 
		// given structure.
		// { "key" : "YOUR_HOSTED_GRAPHITE_API_KEY" }
		var config = deserializeJson( fileRead( this.directory & "Application.ini" ) );

		// Initialize with a 10-second flush interval.
		application.graphite = new lib.GraphiteD( config.key, 10 );

		// Return true so the application can load.
		return( true );

	}


	// I initialize the request.
	public boolean function onRequestStart( required string scriptName ) {

		// Check to see if we need to reset the application.
		if ( structKeyExists( url, "init" ) ) {

			onApplicationStart();

		}

		// Return true so the request can load.
		return( true );

	}

}