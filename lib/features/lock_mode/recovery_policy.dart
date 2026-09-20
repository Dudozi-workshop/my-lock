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

bool shouldCommitRecoveredPassword({
  required RecoveryPinAction action,
  required bool completedSetup,
}) {
  return action == RecoveryPinAction.resetGraphicalPassword &&
      completedSetup;
}
