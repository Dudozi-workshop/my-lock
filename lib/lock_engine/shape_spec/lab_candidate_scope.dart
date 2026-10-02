/// Only the mounted workbench may opt into candidate rendering.
/// Existing Lab tabs and default production keep their original renderer.
class LabCandidateScope {
  static bool enabled = false;
}
