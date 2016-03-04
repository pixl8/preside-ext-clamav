component extends="coldbox.system.Interceptor" {

	property name="clamAvProtectionService" inject="delayedInjector:clamAvProtectionService";

// PUBLIC
	public void function configure() {}

	public void function preProcess( event ) {
		clamAvProtectionService.protectRequest( event );
	}
}