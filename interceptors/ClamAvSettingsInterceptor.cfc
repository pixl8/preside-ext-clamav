component extends="coldbox.system.Interceptor" {


// PUBLIC
	public void function configure() {}

	public void function preSaveSystemConfig( event, interceptData ) {
		if ( ( interceptData.category ?: "" ) == "clamav" ) {
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