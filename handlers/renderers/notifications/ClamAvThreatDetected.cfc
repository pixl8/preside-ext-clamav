component {

	private string function datatable( event, rc, prc, args={} ) {
		return translateResource( uri="clamav:notification.datatable.message", data=[ args.fileField ?: "" ] );
	}

	private string function full( event, rc, prc, args={} ) {
		return renderView( view="/renderers/notifications/clamAvThreatDetected/full", args=args );
	}
}