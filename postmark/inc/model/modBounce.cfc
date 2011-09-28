<cfcomponent extends="algid.inc.resource.base.model" output="false">
	<cffunction name="init" access="public" returntype="component" output="false">
		<cfargument name="i18n" type="component" required="true" />
		<cfargument name="locale" type="string" default="en_US" />
		
		<cfset super.init(arguments.i18n, arguments.locale) />
		
		<cfset add__bundle('plugins/postmark/i18n/inc/model', 'modBounce') />
		
		<!--- Bounce ID --->
		<cfset add__attribute(
			attribute = 'bounceID'
		) />
		
		<!--- Postmark ID --->
		<cfset add__attribute(
			attribute = 'postmarkID'
		) />
		
		<!--- Type --->
		<cfset add__attribute(
			attribute = 'type'
		) />
		
		<!--- Email --->
		<cfset add__attribute(
			attribute = 'email'
		) />
		
		<!--- Bounced At --->
		<cfset add__attribute(
			attribute = 'bouncedAt'
		) />
		
		<!--- Details --->
		<cfset add__attribute(
			attribute = 'details'
		) />
		
		<!--- Dump Available? --->
		<cfset add__attribute(
			attribute = 'dumpAvailable',
			defaultValue = false
		) />
		
		<!--- Inactive? --->
		<cfset add__attribute(
			attribute = 'inactive',
			defaultValue = false
		) />
		
		<!--- Can Activate? --->
		<cfset add__attribute(
			attribute = 'canActivate',
			defaultValue = false
		) />
		
		<cfreturn this />
	</cffunction>
</cfcomponent>
