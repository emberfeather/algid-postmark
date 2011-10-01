<cfcomponent extends="algid.inc.resource.base.service" output="false">
	<cffunction name="getBounce" access="public" returntype="component" output="false">
		<cfargument name="bounceID" type="string" required="true" />
		
		<cfset local.bounce = getModel('postmark', 'bounce') />
		
		<cfif not len(arguments.bounceID)>
			<cfreturn local.bounce />
		</cfif>
		
		<cfquery name="local.results" datasource="#variables.datasource.name#">
			SELECT "bounceID", "postmarkID", "type", "email", "bouncedAt", details, "dumpAvailable", inactive, "canActivate"
			FROM "#variables.datasource.prefix#postmark"."bounce"
			WHERE "bounceID" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounceID#" null="#arguments.bounceID eq ''#" />::uuid
		</cfquery>
		
		<cfif local.results.recordCount>
			<cfset local.modelSerial = variables.transport.theApplication.factories.transient.getModelSerial(variables.transport) />
			
			<cfset local.modelSerial.deserialize(local.results, local.bounce) />
		</cfif>
		
		<cfreturn local.bounce />
	</cffunction>
	
	<cffunction name="getBounces" access="public" returntype="query" output="false">
		<cfargument name="filter" type="struct" default="#{}#" />
		
		<!--- Expand the with defaults --->
		<cfset arguments.filter = extend({
			orderBy = 'bouncedAt',
			orderSort = 'asc'
		}, arguments.filter) />
		
		<cfquery name="local.results" datasource="#variables.datasource.name#">
			SELECT "bounceID", "postmarkID", "type", "email", "bouncedAt", details, "dumpAvailable", inactive, "canActivate"
			FROM "#variables.datasource.prefix#postmark"."bounce"
			WHERE 1=1
			
			<cfif structKeyExists(arguments.filter, 'postmarkID')>
				AND "postmarkID" = <cfqueryparam cfsqltype="cf_sql_bigint" value="#arguments.filter.postmarkID#" />
			</cfif>
			
			<cfif structKeyExists(arguments.filter, 'email')>
				AND "email" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.filter.email#" />
			</cfif>
			
			ORDER BY
			<cfswitch expression="#arguments.filter.orderBy#">
				<cfdefaultcase>
					"bouncedAt" #arguments.filter.orderSort#,
					"email" #arguments.filter.orderSort#
				</cfdefaultcase>
			</cfswitch>
			
			<cfif structKeyExists(arguments.filter, 'limit')>
				LIMIT <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filter.limit#" />
			</cfif>
			
			<cfif structKeyExists(arguments.filter, 'offset')>
				OFFSET <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.filter.offset#" />
			</cfif>
		</cfquery>
		
		<cfreturn local.results />
	</cffunction>
	
	<cffunction name="setBounce" access="public" returntype="void" output="false">
		<cfargument name="bounce" type="component" required="true" />
		
		<cfset local.observer = getPluginObserver('postmark', 'bounce') />
		
		<cfset scrub__model(arguments.bounce) />
		<cfset validate__model(arguments.bounce) />
		
		<cfset local.observer.beforeSave(variables.transport, arguments.bounce) />
		
		<cfif arguments.bounce.getBounceID() eq ''>
			<!--- Insert as a new bounce --->
			<!--- Create the new ID --->
			<cfset arguments.bounce.setBounceID( createUUID() ) />
			
			<cfset local.observer.beforeCreate(variables.transport, arguments.bounce) />
			
			<cftransaction>
				<cfquery result="local.results" datasource="#variables.datasource.name#">
					INSERT INTO "#variables.datasource.prefix#postmark"."bounce"
					(
						"bounceID",
						"postmarkID",
						"type",
						"email",
						"bouncedAt",
						details,
						"dumpAvailable",
						inactive,
						"canActivate"
					) VALUES (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounce.getBounceID()#" />::uuid,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounce.getPostmarkID()#" />::bigint,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounce.getType()#" />,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounce.getEmail()#" />,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.bounce.getBouncedAt()#" />,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounce.getDetails()#" />,
						<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.bounce.getDumpAvailable()#" />,
						<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.bounce.getInactive()#" />,
						<cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.bounce.getCanActivate()#" />
					)
				</cfquery>
			</cftransaction>
			
			<cfset local.observer.afterCreate(variables.transport, arguments.bounce) />
		<cfelse>
			<cfset local.observer.beforeUpdate(variables.transport, arguments.bounce) />
			
			<cftransaction>
				<cfquery result="local.results" datasource="#variables.datasource.name#">
					UPDATE "#variables.datasource.prefix#postmark"."bounce"
					SET
						"postmarkID" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounce.getPostmarkID()#" />::bigint,
						"type" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounce.getType()#" />,
						"email" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounce.getEmail()#" />,
						"bouncedAt" = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.bounce.getBouncedAt()#" />,
						details = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounce.getDetails()#" />,
						"dumpAvailable" = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.bounce.getDumpAvailable()#" />,
						inactive = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.bounce.getInactive()#" />,
						"canActivate" = <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.bounce.getCanActivate()#" />
					WHERE
						"bounceID" = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.bounce.getBounceID()#" />::uuid
				</cfquery>
			</cftransaction>
			
			<cfset local.observer.afterUpdate(variables.transport, arguments.bounce) />
		</cfif>
		
		<cfset local.observer.afterSave(variables.transport, arguments.bounce) />
	</cffunction>
</cfcomponent>
