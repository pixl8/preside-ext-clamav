component extends="coldbox.system.Interceptor" {

	property name="clamAvValidators" inject="delayedInjector:clamAvValidators";
	property name="validationEngine" inject="delayedInjector:validationEngine";

// PUBLIC
	public void function configure() {}

	public void function onApplicationStart() {
		validationEngine.newProvider( clamAvValidators.get() );
	}

	public void function afterConfigurationLoad( event, interceptData ) {
		var features       = controller.getSetting( "features" );
		var remoteHostname = controller.getSetting( "clamav.remoteHostname" );
		var remotePort     = controller.getSetting( "clamav.remotePort" );

		// These features should never be set manually! This logic will enable the correct features based on the remote server settings...
		if ( Len( Trim( remoteHostname ) ) && isNumeric( remotePort ) ) {
			features.clamAvLocalBinary   = { enabled=false };
			features.clamAvRemoteService = { enabled=true };
		} else {
			features.clamAvLocalBinary   = { enabled=true };
			features.clamAvRemoteService = { enabled=false };
		}
	}

}