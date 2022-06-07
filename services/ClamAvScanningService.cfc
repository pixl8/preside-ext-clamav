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
	 * @externalHostname.inject coldbox:setting:clamav.externalHostname
	 * @externalPort.inject     coldbox:setting:clamav.externalPort
	 */
	public any function init( required any externalHostname, required any externalPort ) {
		_setExternalHostname( arguments.externalHostname );
		_setExternalPort( arguments.externalPort );

		return this;
	}

	public boolean function scan( required string filePath, required struct report ) {
		if ( useExternalClamAv() ) {
			return _scanExternal( argumentCollection=arguments );
		} else {
			return _scanLocal( argumentCollection=arguments );
		}
	}

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

	private boolean function _scanExternal( required string filePath, required struct report ) {
		try {
			var ClamAvClient     = _getClamAvClient();
			var inputStream      = CreateObject( "java", "java.io.FileInputStream" ).init( arguments.filePath );
			var scanResult       = ClamAvClient.scan( inputStream );

			report.stdOut        = _processExternalResponse( scanResult );
			report.virusDetected = !ClamAvClient.isCleanReply( scanResult );
		} catch( any e ) {
			$raiseError( e );
			report.virusDetected = false;
			report.stdErr        = "Message: [#e.message#]. Detail: [#e.detail#].";
		}

		return report.virusDetected;
	}

	public boolean function useExternalClamAv() {
		return Len( _getExternalHostname() ) > 0;
	}

// PRIVATE HELPERS
	private any function _getClamAvClient() {
		return CreateObject( "java", "fi.solita.clamav.ClamAVClient", _getLib() ).init( _getExternalHostname(), _getExternalPort() );
	}

	private array function _getLib() {
		_lib = _lib ?: DirectoryList( ExpandPath( GetDirectoryFromPath( GetCurrentTemplatePath() ) & "lib" ), false, "path" );
		return _lib;
	}

	private string function _processExternalResponse( required any scanResult ) {
		var resultString = toString( arguments.scanResult );
		return ReReplaceNoCase( resultString, "^stream:\s", "" );
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


	private string function _getExternalHostname() {
		return _externalHostname;
	}
	private void function _setExternalHostname( required string externalHostname ) {
		_externalHostname = arguments.externalHostname;
	}

	private numeric function _getExternalPort() {
		return _externalPort;
	}
	private void function _setExternalPort( required numeric externalPort ) {
		_externalPort = arguments.externalPort;
	}

}