enum RecoveryPinAction {
  unlockOnly,
}

RecoveryPinAction recoveryPinActionFor({
  required bool appAuthentication,
}) {
  return RecoveryPinAction.unlockOnly;
}

bool shouldCommitRecoveredPassword({
  required RecoveryPinAction action,
  required bool completedSetup,
}) {
  return false;
}
