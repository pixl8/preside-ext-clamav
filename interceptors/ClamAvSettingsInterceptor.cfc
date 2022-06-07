component extends="coldbox.system.Interceptor" {

	property name="clamAvScanningService" inject="delayedInjector:clamAvScanningService";
	property name="formsService"          inject="delayedInjector:formsService";

// PUBLIC
	public void function configure() {}

	public void function preRenderForm( event, interceptData ) {
		if ( interceptData.formName == "system-config.clamav" && clamAvScanningService.useExternalClamAv() ) {
			interceptData.formName = formsService.createForm(
				  basedOn   = interceptData.formName
				, formName  = "system-config.clamav.external"
				, generator = function( formDefinition ) {
					formDefinition.deleteField( name="daemon_path", fieldset="default", tab="default" );
				  }
			);
		}
	}

	public void function preSaveSystemConfig( event, interceptData ) {
		if ( ( interceptData.category ?: "" ) == "clamav" && !clamAvScanningService.useExternalClamAv() ) {
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