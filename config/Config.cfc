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

		settings.healthcheckServices.clamav = { interval = CreateTimeSpan( 0, 0, 0, 10 ) };

		settings.clamav = settings.clamav ?: {};
		settings.clamav.remoteHostname = settings.clamav.remoteHostname ?: ( settings.env.CLAMAV_REMOTE_HOSTNAME ?: ""   );
		settings.clamav.remotePort     = settings.clamav.remotePort     ?: ( settings.env.CLAMAV_REMOTE_PORT     ?: 3310 );

		interceptors.append( { class="app.extensions.preside-ext-clamav.interceptors.ClamAvFileUploadInterceptor"   , properties={} } );
		interceptors.append( { class="app.extensions.preside-ext-clamav.interceptors.ClamAvSystemStartupInterceptor", properties={} } );
		interceptors.append( { class="app.extensions.preside-ext-clamav.interceptors.ClamAvSettingsInterceptor"     , properties={} } );
	}
}