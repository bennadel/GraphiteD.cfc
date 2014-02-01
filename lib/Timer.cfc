component
	extends = "Metric"
	output = false 
	hint = "I aggregate time(ish) statistics for a given metric within the current interval."
	{

	// I initialize the timer.
	public any function init( required string aName ) {

		super.init( aName );

		count = 0;
		minValue = 0;
		maxValue = 0;
		totalValue = 0;
		averageValue = 0;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	// I get the number of times the timer was updated.
	public numeric function getCount() {

		return( count );

	}


	// I get the average value across the recorded values.
	public numeric function getAverageValue() {

		return( averageValue );

	}


	// I get the maximum value recorded.
	public numeric function getMaxValue() {

		return( maxValue );

	}


	// I get the minimum value recorded.
	public numeric function getMinValue() {

		return( minValue );

	}


	// I get the total value recorded.
	public numeric function getTotalValue() {

		return( totalValue );

	}


	// I update the metric with the given value. The units of measurements here are not 
	// important as long as they are consistent across updates.
	public void function recordValue( required numeric newValue ) {

		count++;
		totalValue += newValue;
		averageValue = ( totalValue / count );

		// Use the first recording as the min/max. That way, the zero doesn't alway win.
		if ( count == 1 ) {

			minValue = maxValue = newValue;

		} else {

			minValue = min( minValue, newValue );
			maxValue = max( maxValue, newValue );
			
		}

	}


	// I reset the timer.
	public void function reset() {

		count = 0;
		minValue = 0;
		maxValue = 0;
		totalValue = 0;
		averageValue = 0;

	}

}