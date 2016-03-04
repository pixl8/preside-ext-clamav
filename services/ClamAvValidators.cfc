/**
 * @singleton
 * @presideService
 * @validationProvider
 *
 */
component {

	public any function init() {
		return this;
	}

	/**
	 * Validation rule that states that uploaded
	 * files are not identified as threats by ClamAV
	 *
	 * @validatorMessage clamav:validation.clamAvCleanFile.default
	 */
	public boolean function clamAvCleanFile( required string fieldName ) {
		var prc = $getColdbox().getRequestService().getContext().getCollection( private=true );
		var fieldsWithThreats = prc.clamAvDetectedThreatFields ?: [];

		return !IsArray( fieldsWithThreats ) || !fieldsWithThreats.findNoCase( arguments.fieldName );
	}
	public string function clamAvCleanFile_js() {
		return "function( value, el, params ) { return true; }";
	}
}