component {
	public component function init( required string apiKey, numeric threshold = 500 ) {
		variables.apiKey = arguments.apiKey;
		variables.threshold = arguments.threshold;
		
		variables.messages = [];
		variables.results = [];
		
		return this;
	}
	
	public void function addMessage(required struct message) {
		arrayAppend(variables.messages, arguments.message);
	}
	
	public array function send() {
		__sendMessages();
		
		local.currentResults = variables.results;
		
		// Reset the results
		variables.results = [];
		
		return local.currentResults;
	}
	
	/**
	 * Sends any batched messages
	 **/
	private void function __sendMessages() {
		if( !arrayLen(variables.messages) ) {
			return;
		}
		
		while( arrayLen(variables.messages) ) {
			local.batch = [];
			
			// Create a batch from any that are waiting
			for( local.i = min(arrayLen(variables.messages), variables.threshold); local.i > 0; local.i-- ) {
				arrayAppend(local.batch, variables.messages[local.i]);
				
				// Remove from queue
				arrayDeleteAt(variables.messages, local.i);
			}
			
			// Send the batch
			http url="https://api.postmarkapp.com/email/batch" method="post" result="local.apiResults" {
				httpparam type="header" name="Accept" value="application/json";
				httpparam type="header" name="Content-type" value="application/json";
				httpparam type="header" name="X-Postmark-Server-Token" value="#variables.apiKey#";
				httpparam type="body" encoded="no" value="#serializeJson(local.batch)#";
			}
			
			if(local.apiResults.status_code != 200) {
				local.apiError = deserializeJson(local.apiResults.fileContent);
				
				throw(message="Failed to send emails", detail="#local.apiError.message#", errorcode="#local.apiError.errorcode#");
			}
			
			local.apiResultMessages = deserializeJson(local.apiResults.filecontent);
			
			for( local.i = 1; local.i <= arrayLen(local.apiResultMessages); local.i++ ) {
				arrayAppend(variables.results, local.apiResultMessages[local.i]);
			}
		}
	}
}
