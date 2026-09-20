enum RecoveryPinAction {
  unlockOnly,
  resetGraphicalPassword,
}

RecoveryPinAction recoveryPinActionFor({
  required bool appAuthentication,
}) {
  return appAuthentication
      ? RecoveryPinAction.resetGraphicalPassword
      : RecoveryPinAction.unlockOnly;
}
