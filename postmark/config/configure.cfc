<cfcomponent extends="algid.inc.resource.plugin.configure" output="false">
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