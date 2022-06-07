/**
 * Provides API for AV scanning files on demand
 * using ClamAV
 *
 * @singleton
 * @presideservice
 *
 */
component {

	variables.VIRUS_DETECTED = 1;

	// CONSTRUCTOR
	/**
	 * @remoteHostname.inject coldbox:setting:clamav.remoteHostname
	 * @remotePort.inject     coldbox:setting:clamav.remotePort
	 */
	public any function init( required any remoteHostname, required any remotePort ) {
		_setRemoteHostname( arguments.remoteHostname );
		_setRemotePort( arguments.remotePort );

		return this;
	}

	public boolean function scan( required string filePath, required struct report ) {
		if ( $isFeatureEnabled( "clamAvRemoteService" ) ) {
			return _scanRemote( argumentCollection=arguments );
		} else {
			return _scanLocal( argumentCollection=arguments );
		}
	}


// PRIVATE HELPERS
	private boolean function _scanLocal( required string filePath, required struct report ) {
		var clamavPath = $getPresideSetting( "clamav", "daemon_path" );
		var command    = [ clamavPath, "--fdpass", arguments.filePath ];

		try {
			var process = CreateObject( "java", "java.lang.Runtime" ).getRuntime().exec( command );

			report.exitValue     =  process.waitFor();
			report.stdErr        = _processStream( process.getErrorStream() );
			report.stdOut        = _processStream( process.getInputStream() );
			report.virusDetected = ( report.exitValue == VIRUS_DETECTED );
		} catch( any e ) {
			$raiseError( e );
			report.virusDetected = false;
			report.stdErr        = "Message: [#e.message#]. Detail: [#e.detail#].";
		}

		return report.virusDetected;
	}

	private boolean function _scanRemote( required string filePath, required struct report ) {
		try {
			var ClamAvClient     = _getClamAvClient();
			var inputStream      = CreateObject( "java", "java.io.FileInputStream" ).init( arguments.filePath );
			var scanResult       = ClamAvClient.scan( inputStream );

			report.stdOut        = _processRemoteResponse( scanResult );
			report.virusDetected = !ClamAvClient.isCleanReply( scanResult );
		} catch( any e ) {
			$raiseError( e );
			report.virusDetected = false;
			report.stdErr        = "Message: [#e.message#]. Detail: [#e.detail#].";
		}

		return report.virusDetected;
	}

	private string function _processStream( required any streamInput ) {
		var streamReader    = CreateObject("java", "java.io.InputStreamReader").init( arguments.streamInput );
		var buffererdReader = CreateObject("java", "java.io.BufferedReader").init( streamReader );
		var line            = buffererdReader.readLine();
		var result          = "";

		while( !IsNull( line ) ) {
			result = result & line & Chr( 10 );
			line = buffererdReader.readLine();
		}

		return result;
	}

	private string function _processRemoteResponse( required any scanResult ) {
		var resultString = toString( arguments.scanResult );
		return ReReplaceNoCase( resultString, "^stream:\s", "" );
	}

	private any function _getClamAvClient() {
		var javaLib   = DirectoryList( ExpandPath( "/app/extensions/preside-ext-clamav/services/lib" ), false, "path" );
		_clamAvClient = _clamAvClient ?: CreateObject( "java", "fi.solita.clamav.ClamAVClient", javaLib ).init( _getRemoteHostname(), _getRemotePort() );

		return _clamAvClient;
	}

	private string function _getRemoteHostname() {
		return _remoteHostname;
	}
	private void function _setRemoteHostname( required string remoteHostname ) {
		_remoteHostname = arguments.remoteHostname;
	}

	private numeric function _getRemotePort() {
		return _remotePort;
	}
	private void function _setRemotePort( required numeric remotePort ) {
		_remotePort = arguments.remotePort;
	}

}