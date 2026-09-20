const overlayPinRecoveryThreshold = 5;

bool shouldOfferOverlayRecovery({
  required int failedAttempts,
  required bool appAuthentication,
}) {
  return !appAuthentication &&
      failedAttempts >= overlayPinRecoveryThreshold;
}
