<cfcomponent extends="algid.inc.resource.plugin.configure" output="false">
<cfscript>
	public boolean function inPostmark(required struct theApplication, required string targetPage) {
		var path = '';
		
		// Get the path to the base
		path = arguments.theApplication.managers.singleton.getApplication().getPath();
		path &= arguments.theApplication.managers.plugin.getPostmark().getPath();
		
		// Only pages in the root of path qualify
		return reFind('^' & path & '[a-zA-Z0-9-\.]*.cfm$', arguments.targetPage) GT 0;
	}
	
	public void function onApplicationStart(required struct theApplication) {
		// Get the plugin
		local.plugin = arguments.theApplication.managers.plugin.getPostmark();
		
		// Check for control of the main application index
		local.pluginHandlerDir = '/root/' & local.plugin.getPath();
		
		if(!directoryExists(local.pluginHandlerDir)) {
			directoryCreate(local.pluginHandlerDir);
		}
		
		if(!fileExists(local.pluginHandlerDir & 'index.cfm')) {
			fileWrite(local.pluginHandlerDir & 'index.cfm', '<!--- Controlled by the postmark plugin --->' & chr(10) & '<cfinclude template="/plugins/postmark/inc/wrapper.cfm" />' & chr(10));
		}
	}
	
	public void function onRequestStart(required struct theApplication, required struct theSession, required struct theRequest, required string targetPage) {
		var app = '';
		var filter = '';
		var options = '';
		var plugin = '';
		var rewrite = '';
		var temp = '';
		var theUrl = '';
		
		// Only do the following if in the instrument area
		if (inPostmark( arguments.theApplication, arguments.targetPage )) {
			// Default base
			if ( !structKeyExists(url, '_base') ) {
				url['_base'] = '/index';
			}
			
			// Create the URL object for all the content requests
			app = arguments.theApplication.managers.singleton.getApplication();
			plugin = arguments.theApplication.managers.plugin.getInstrument();
			
			arguments.theRequest.webRoot =  app.getPath();
			arguments.theRequest.requestRoot =  plugin.getPath();
			
			options = { start = arguments.theRequest.webRoot & arguments.theRequest.requestRoot };
			
			rewrite = plugin.getRewrite();
			
			if(rewrite.isEnabled) {
				options.rewriteBase = rewrite.base;
				
				theUrl = arguments.theApplication.factories.transient.getUrlRewrite(arguments.theUrl, options);
			} else {
				theUrl = arguments.theApplication.factories.transient.getUrl(arguments.theUrl, options);
			}
			
			arguments.theRequest.managers.singleton.setUrl( theUrl );
		}
	}
</cfscript>
	<!---
		Configures the database for v0.1.0
	--->
	<cffunction name="postgreSQL0_1_0" access="public" returntype="void" output="false">
		<!---
			SCHEMA
		--->
		
		<!--- Postmark Schema --->
		<cfquery datasource="#variables.datasource.name#">
			CREATE SCHEMA "#variables.datasource.prefix#postmark"
				AUTHORIZATION #variables.datasource.owner#;
		</cfquery>
		
		<!---
			TABLES
		--->
		
		<!--- Bounce Table --->
		<cfquery datasource="#variables.datasource.name#">
			CREATE TABLE "#variables.datasource.prefix#postmark"."bounce"
			(
				"bounceID" uuid NOT NULL,
				"postmarkID" bigint NOT NULL,
				"type" character varying(100) NOT NULL,
				email character varying(300) NOT NULL,
				"bouncedAt" timestamp without time zone,
				details character varying(2000),
				"dumpAvailable" boolean DEFAULT false,
				inactive boolean DEFAULT false,
				"canActivate" boolean DEFAULT false,
				CONSTRAINT bounce_pkey PRIMARY KEY ("bounceID")
			)
			WITH (OIDS=FALSE);
		</cfquery>
		
		<cfquery datasource="#variables.datasource.name#">
			ALTER TABLE "#variables.datasource.prefix#postmark"."bounce" OWNER TO #variables.datasource.owner#;
		</cfquery>
		
		<cfquery datasource="#variables.datasource.name#">
			COMMENT ON TABLE "#variables.datasource.prefix#postmark"."bounce" IS 'Postmark bounces.';
		</cfquery>
	</cffunction>
<cfscript>
	public void function update( required struct plugin, string installedVersion = '' ) {
		var versions = createObject('component', 'algid.inc.resource.utility.version').init();
		
		// fresh => 0.1.0
		if (versions.compareVersions(arguments.installedVersion, '0.1.0') lt 0) {
			switch (variables.datasource.type) {
			case 'PostgreSQL':
				postgreSQL0_1_0();
				
				break;
			default:
				throw(message="Database Type Not Supported", detail="The #variables.datasource.type# database type is not currently supported");
			}
		}
	}
</cfscript>
</cfcomponent>