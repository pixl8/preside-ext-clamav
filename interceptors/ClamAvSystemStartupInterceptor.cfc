component extends="coldbox.system.Interceptor" {

	property name="clamAvValidators" inject="delayedInjector:clamAvValidators";
	property name="validationEngine" inject="delayedInjector:validationEngine";

// PUBLIC
	public void function configure() {}

	public void function onApplicationStart() {
		validationEngine.newProvider( clamAvValidators.get() );
	}
}