<cfsilent>
	<cfscript>
		profiler = request.managers.singleton.getProfiler();
		
		profiler.start('startup');
		
		// Setup a transport object to transport scopes
		transport = {
			theApplication = application,
			theCGI = cgi,
			theCookie = cookie,
			theForm = form,
			theRequest = request,
			theServer = server,
			theSession = session,
			theUrl = url
		};
		
		i18n = transport.theApplication.managers.singleton.getI18N();
		locale = transport.theSession.managers.singleton.getSession().getLocale();
		theUrl = transport.theRequest.managers.singleton.getURL();
		modelSerial = transport.theApplication.factories.transient.getModelSerial(transport);
		
		// Create and store the services manager
		services = transport.theApplication.factories.transient.getManagerService(transport);
		transport.theRequest.managers.singleton.setManagerService(services);
		
		// Create and store the views manager
		views = transport.theApplication.factories.transient.getManagerView(transport);
		transport.theRequest.managers.singleton.setManagerView(views);
		
		// Create and store the model manager
		models = transport.theApplication.factories.transient.getManagerModel(transport, i18n, locale);
		transport.theRequest.managers.singleton.setManagerModel(models);
		
		profiler.stop('startup');
	</cfscript>
</cfsilent>

<cfset destination = '/plugins/postmark/extend/postmark/content' & theUrl.search('_base') & '.cfm' />

<cfif fileExists(destination)>
	<cfinclude template="#destination#" />
<cfelse>
	<cfthrow message="Unable to find postmark handler" detail="Could not find the handler in #destination#" />
</cfif>
