component extends="coldbox.system.Interceptor" {

	property name="clamAvScanningService" inject="delayedInjector:clamAvScanningService";
	property name="formsService"          inject="delayedInjector:formsService";

// PUBLIC
	public void function configure() {}

	public void function preSaveSystemConfig( event, interceptData ) {
		if ( ( interceptData.category ?: "" ) == "clamav" && isFeatureEnabled( "clamAvLocalBinary" ) ) {
			var daemonPath = interceptData.configuration.daemon_path ?: "";
			var stdOut     = "";
			var stdErr     = "";

			try {
				execute name               = daemonPath
				        arguments          = "--version"
				        timeout            = "2"
				        terminateOnTimeout = true
				        variable           = "stdOut"
				        errorVariable      = "stdErr";
			} catch( any e ) {
				stdErr = e.message;
			}

			if ( Len( Trim( stdErr ) ) || !ReFindNoCase( "ClamAV", stdOut ) ) {
				if ( !IsSimpleValue( interceptData.validationResult ) ) {
					interceptData.validationResult.addError( "daemon_path", "clamav:validation.invalid.clamav.executable" );
				}
			}
		}
	}
}