component extends="coldbox.system.Interceptor" {

	property name="notificationService"        inject="delayedInjector:NotificationService";
	property name="clamAvScanningService"      inject="delayedInjector:clamAvScanningService";
	property name="websiteLoginService"        inject="delayedInjector:websiteLoginService";
	property name="systemConfigurationService" inject="delayedInjector:systemConfigurationService";

// PUBLIC
	public void function configure() {}

	public void function preProcess( event, interceptData ) {
		var requestData  = GetHttpRequestData();
		var contentType  = requestData.headers[ "Content-Type" ] ?: "";
		var isFileUpload = Len( Trim( contentType ) ) && contentType.startsWith( "multipart/form-data" );

		if ( isFileUpload ) {
			var avSettings = systemConfigurationService.getCategorySettings( "clamav" );
			var needToScan = false;

			if ( event.isAdminRequest() || event.isAdminUser() ) {
				needToScan = IsBoolean( avSettings.enable_for_admin ?: "" ) && avSettings.enable_for_admin;
			} else {
				needToScan = IsBoolean( avSettings.enable_for_web ?: "" ) && avSettings.enable_for_web;
			}

			if ( needToScan ) {
				var tmpDir          = getTempDirectory();
				var threatBehaviour = avSettings.on_detect_behaviour ?: "raise";

				for( var field in ListToArray( form.fieldNames ?: "" ) ) {
					if ( form[ field ].startsWith( tmpDir ) && FileExists( form[ field ] ) ) {
						var tmpFile       = form[ field ];
						var report        = {};
						var virusDetected = clamAvScanningService.scan( tmpFile, report );

						if ( virusDetected ) {
							FileDelete( tmpFile );
							form[ field ] = "";

							var env = Duplicate( cgi );
							env.append( request );
							env.append( requestData.headers );

							notificationService.createNotification(
					              topic = "clamAvThreatDetected"
					            , type  = "ALERT"
					            , data  = {
					            	  report      = report
					            	, fileField   = field
					            	, environment = env
					            	, adminUser   = event.getAdminUserId()
					            	, webUser     = websiteLoginService.getLoggedInUserId()
					              }
					        );

							if ( threatBehaviour == "raise" ) {
								throw(
									  type    = "antivirus.threat.detected"
									, message = "A threat was detected in a file uploaded in the [#field#] form field."
									, detail  = "ClamAV Report: [#SerializeJson( report )#]. Request details: [#SerializeJson( cgi )#]"
								);
							}
						}
					}
				}
			}

		}
	}
}