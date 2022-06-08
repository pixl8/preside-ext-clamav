component {
	property name="clamAvScanningService" inject="clamAvScanningService";

	private boolean function check() {
		return clamAvScanningService.pingServer();
	}
}