component
	extends = "Metric"
	output = false 
	hint = "I count a given metric within the current interval."
	{

	// I initialize the counter.
	public any function init( required string aName ) {

		super.init( aName );

		value = 0;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I get the current counter value.
	public numeric function getValue() {

		return( value );

	}


	// I update the counter value with the given delta.
	public void function recordValue( required numeric newValue ) {

		value += newValue;

	}
	

	// I reset the counter.
	public void function reset() {

		value = 0;

	}

}