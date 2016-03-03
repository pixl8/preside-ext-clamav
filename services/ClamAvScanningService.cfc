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

	public any function init() {
		return this;
	}

	public boolean function scan( required string filePath, required struct report ) {
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
            report.stdErr = "Message: [#e.message#]. Detail: [#e.detail#].";
        }

        return report.virusDetected;
	}

// PRIVATE HELPERS
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
}