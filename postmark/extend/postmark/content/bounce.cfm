<cfset servBounce = services.get('postmark', 'bounce') />

<cfif transport.theCgi.request_method eq 'post'>
	<cfset bounce = servBounce.getBounce('') />
	
	<cfset submission = deserializeJson(getHTTPRequestData().content) />
	
	<cfif not isDate(submission.bouncedAt)>
		<cfset submission.bouncedAt = now() />
	</cfif>
	
	<!--- Process the form submission --->
	<cfset modelSerial.deserialize(submission, bounce) />
	<cfset bounce.setPostmarkID(submission.id) />
	
	<cfset servBounce.setBounce(bounce) />
</cfif>
