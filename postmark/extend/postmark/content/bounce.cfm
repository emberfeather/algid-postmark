<cfset servBounce = services.get('postmark', 'bounce') />

<cfif transport.theCgi.request_method eq 'post'>
	<cfset bounce = servBounce.getBounce('') />
	
	<!--- Process the form submission --->
	<cfset modelSerial.deserialize(form, bounce) />
	<cfset bounce.setPostmarkID(form.id) />
	
	<cfset servBounce.setBounce(bounce) />
</cfif>
