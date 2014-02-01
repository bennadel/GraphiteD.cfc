component
	extends = "Metric"
	output = false 
	hint = "I record a given metric within the current interval."
	{

	// I initialize the gauge.
	public any function init( required string aName ) {

		super.init( aName );

		value = 0;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I get the current gauge value.
	public numeric function getValue() {

		return( value );

	}


	// I update the gauge value with a direct assignment.
	public void function recordValue( required numeric newValue ) {

		value = newValue;

	}

	
	// I reset the metric value(s).
	public void function reset() {

		// With a gauge, there is nothing to reset - the value will carry over to the next interval.

	}

}