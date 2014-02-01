<cfscript>
	
	// The page ID will influence how long the page is slept.
	param name="url.pageID" type="numeric" default="1";


	// Track the page request (counter).
	application.graphite.recordCounterMetric( "com.bennadel.graphited.page_requests.home", 1 );

	// Set the day of the week as the gauge.
	application.graphite.recordGaugeMetric( "com.bennadel.graphited.day_of_week", dayOfWeek( now() ) );	


	// Keep track of the time the page was initiated.
	startLoadAt = getTickCount();

	// Sleep the page for a weighted-random time period.
	sleepTimeout = randRange( ( url.pageID * 10 ), ( url.pageID * 50 ) );

	sleep( sleepTimeout );

</cfscript>


<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<cfoutput>

	<!doctype html>
	<html>
	<head>
		<meta charset="utf-8" />
		<title>Using HostedGraphite.com With ColdFusion</title>
	</head>
	<body>

		<h1>
			Using HostedGraphite.com With ColdFusion
		</h1>

		<p>
			In this example, we're simply going to post a the page request count and the 
			page load time to HostedGraphite.com based on the pageID query param selected.
		</p>

		<ul>
			<li>
				<a href="#cgi.script_name#?pageID=1">Page ID &mdash; 1</a>
			</li>
			<li>
				<a href="#cgi.script_name#?pageID=2">Page ID &mdash; 2</a>
			</li>
			<li>
				<a href="#cgi.script_name#?pageID=3">Page ID &mdash; 3</a>
			</li>
			<li>
				<a href="#cgi.script_name#?pageID=4">Page ID &mdash; 4</a>
			</li>
		</ul>

		<p>
			Sleeping for: #sleepTimeout#ms.
		</p>

	</body>
	</html>

</cfoutput>


<cfscript>

	// Record the time it took the page to load.
	application.graphite.recordTimerMetric( "com.bennadel.graphited.page_times.home", ( getTickCount() - startLoadAt ) );

</cfscript>