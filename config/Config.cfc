component {

	/**
	 * This extension Config.cfc has been scaffolded by the PresideCMS
	 * Scaffolding service.
	 *
	 * Override or append to core PresideCMS/Coldbox settings here.
	 *
	 */
	public void function configure( required struct config ) {
		var settings     = arguments.config.settings     ?: {}
		var interceptors = arguments.config.interceptors ?: [];

		settings.notificationTopics.append( "clamAvThreatDetected" );

		settings.clamav.externalHostname = settings.env.CLAMAV_EXTERNAL_HOSTNAME ?: "";
		settings.clamav.externalPort     = settings.env.CLAMAV_EXTERNAL_PORT     ?: 3310;

		interceptors.append( { class="app.extensions.preside-ext-clamav.interceptors.ClamAvFileUploadInterceptor"   , properties={} } );
		interceptors.append( { class="app.extensions.preside-ext-clamav.interceptors.ClamAvSystemStartupInterceptor", properties={} } );
		interceptors.append( { class="app.extensions.preside-ext-clamav.interceptors.ClamAvSettingsInterceptor"     , properties={} } );
	}
}