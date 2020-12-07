/**
 * Provides logic for protect requests from malicious file uploads
 *
 *
 * @singleton
 * @presideservice
 *
 */
component {

	/**
	 * @scanningService.inject clamAvScanningService
	 *
	 */
	public any function init( required any scanningService ) {
		_setScanningService( arguments.scanningService );

		return this;
	}

// PUBLIC API
	public void function protectRequest( requestContext ) {
		if ( _isFileUploadRequest() && _scanningEnabledForRequest( requestContext ) ) {
			var fileUploadFields  = _getFileUploadFields();
			var fieldsWithThreats = [];

			for( var field in fileUploadFields ) {
				var tmpFilePath    = fileUploadFields[ field ];
				var report         = {};
				var threatDetected = _getScanningService().scan( tmpFilePath, report );

				if ( threatDetected ) {
					fieldsWithThreats.append( field );

					_cleanupFile( tmpFilePath, field, requestContext );
					_raiseNotification( report, field );
				}
			}

			if ( fieldsWithThreats.len() ) {
				_takeActionAgainstThreats( fieldsWithThreats, requestContext );
			}
		}
	}

// PRIVATE HELPERS
	private boolean function _isFileUploadRequest() {
		var requestData  = GetHttpRequestData( false );
		var contentType  = requestData.headers[ "Content-Type" ] ?: "";

		return Len( Trim( contentType ) ) && contentType.startsWith( "multipart/form-data" );
	}

	private boolean function _scanningEnabledForRequest( requestContext ) {
		var avSettings = $getPresideCategorySettings( "clamav" );
		var needToScan = false;

		if ( requestContext.isAdminRequest() || requestContext.isAdminUser() ) {
			return IsBoolean( avSettings.enable_for_admin ?: "" ) && avSettings.enable_for_admin;
		}

		return IsBoolean( avSettings.enable_for_web ?: "" ) && avSettings.enable_for_web;
	}

	private struct function _getFileUploadFields() {
		var fileUploadFields = {};

		for( var field in ListToArray( form.fieldNames ?: "" ) ) {
			if ( isSimpleValue( form[ field ] ) && !reFindNoCase('(http|https)://', form[ field ] ) && FileExists( form[ field ] ) ) {
				fileUploadFields[ field ] = form[ field ];
			}
		}

		return fileUploadFields;
	}

	private void function _cleanupFile( required string filePath, required string fileField, required any requestContext ) {
		var rc  = requestContext.getCollection();

		rc[ arguments.fileField ] = form[ arguments.fileField ] = "";
		FileDelete( arguments.filePath );
	}

	private void function _raiseNotification( required struct report, required string fileField ) {
		var env = Duplicate( cgi );
		env.append( request );

		$createNotification(
              topic = "clamAvThreatDetected"
            , type  = "ALERT"
            , data  = {
            	  report      = arguments.report
            	, fileField   = arguments.fileField
            	, environment = env
            	, adminUser   = $getAdminLoggedInUserId()
            	, webUser     = $getWebsiteLoggedInUserId()
              }
        );
	}

	private void function _takeActionAgainstThreats( required array fieldsWithThreats, required any requestContext ) {
		var actionToTake = $getPresideSetting( "clamav", "on_detect_behaviour", "raise" );
		var prc          = requestContext.getCollection( private=true );

		if ( actionToTake == "raise" ) {
			throw(
				  type    = "antivirus.threat.detected"
				, message = "Threat(s) were detected in file(s) uploaded in the following field(s): #SerializeJson( arguments.fieldsWithThreats )#"
			);
		}

		prc.clamAvDetectedThreatFields = arguments.fieldsWithThreats;
	}

// GETTERS AND SETTERS
	private any function _getScanningService() {
		return _scanningService;
	}
	private void function _setScanningService( required any scanningService ) {
		_scanningService = arguments.scanningService;
	}

}