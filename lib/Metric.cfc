component
	output = false
	hint = "I provide the base GraphiteD metric behavior."
	{

	// I initialize the base metric.
	public any function init( required string aName ) {

		testSetName( aName );

		name = aName;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I get the metric name.
	public string function getName() {

		return( name );

	}


	// I update the current metric value, as appropriate.
	public void function recordValue( required numeric newValue ) {

		throw( type = "GraphiteD.AbstractMethod" );

	}


	// I reset the metric value(s).
	public void function reset() {

		throw( type = "GraphiteD.AbstractMethod" );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	// I determine if the given name can be used for the metric name. I raise an exception if 
	// the given name is not valid.
	private void function testSetName( required string newName ) {

		if ( structKeyExists( variables, "name" ) ) {

			throw( type = "GraphiteD.AlreadyExists", message = "Name is already set." );

		}

		if ( ! len( newName ) ) {

			throw( type = "GraphiteD.Invalid", message = "Name must contain at least one alpha-numeric character." );

		}

		if ( reFind( "[^\w\.\-]", newName ) ) {

			throw( type = "GraphiteD.Invalid", message = "Name can only contain alpha-numeric characters, dashes, and periods." );

		}

	}

}