// https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/GameFramework/ACharacter
declare class ACharacter extends APawn {
  AnimRootMotionTranslationScale: number; //	Scale to apply to root motion translation on this Character
  BasedMovement: unknown; //	Info about our current movement base (object we are standing on).
  BaseRotationOffset: FQuat; //	Saved rotation offset of mesh.
  BaseTranslationOffset: FVector; //	Saved translation offset of mesh.
  bClientCheckEncroachmentOnNetUpdate: boolean;
  bClientResimulateRootMotion: boolean; //	If server disagrees with root motion track position, client has to resimulate root motion from last AckedMove.
  bClientResimulateRootMotionSources: boolean; //	If server disagrees with root motion state, client has to resimulate root motion from last AckedMove.
  bClientUpdating: boolean; //	When true, applying updates to network client (replaying saved moves for a locally controlled character)
  bClientWasFalling: boolean; //	True if Pawn was initially falling when started to replay network moves.
  bInBaseReplication: boolean; //	Flag that we are receiving replication of the based movement.
  bIsCrouched: boolean; //	Set by character movement to specify that this Character is currently crouched.
  bPressedJump: boolean; //	When true, player wants to jump
  bProxyIsJumpForceApplied: boolean; //	Set to indicate that this Character is currently under the force of a jump (if JumpMaxHoldTime is non-zero).
  bServerMoveIgnoreRootMotion: boolean; //	Disable root motion on the server.
  bSimGravityDisabled: boolean; //	Disable simulated gravity (set when character encroaches geometry on client, to keep it from falling through floors)
  bWasJumping: boolean; //Tracks whether or not the character was already jumping last frame.
  ClientRootMotionParams: unknown; //	For LocallyControlled Autonomous clients. Saved root motion data to be used by SavedMoves.
  CrouchedEyeHeight: number; //	Default crouched eye height
  JumpCurrentCount: number; //	Tracks the current number of jumps performed.
  JumpCurrentCountPreJump: number; //	Represents the current number of jumps performed before CheckJumpInput modifies JumpCurrentCount.
  JumpForceTimeRemaining: number; //Amount of jump force time remaining, if JumpMaxHoldTime > 0.
  JumpKeyHoldTime: number; //	Jump key Held Time. This is the time that the player has held the jump key, in seconds.
  JumpMaxCount: number; //	The max number of jumps the character can perform.
  JumpMaxHoldTime: number; //	The max time the jump key can be held.
  LandedDelegate: unknown; //	Called upon landing when falling, to perform actions based on the Hit result.
  MovementModeChangedDelegate: unknown; //	Multicast delegate for MovementMode changing.
  NumActorOverlapEventsCounter: number; //	Incremented every time there is an Actor overlap event (start or stop) on this actor.
  OnCharacterMovementUpdated: unknown; //	Event triggered at the end of a CharacterMovementComponent movement update.
  OnReachedJumpApex: unknown; //	Broadcast when Character's jump reaches its apex. Needs CharacterMovement->bNotifyApex = true
  PreNetReceivedGravityDirection: unknown; //	Cached version of the replicated gravity direction before replication.
  ProxyJumpForceStartedTime: number; //	Track last time a jump force started for a proxy.
  ReplayLastTransformUpdateTimeStamp: number;
  ReplicatedBasedMovement: unknown; //	Replicated version of relative movement. Read-only on simulated proxies!
  ReplicatedGravityDirection: unknown; //	CharacterMovement Custom gravity direction replicated for simulated proxies.
  ReplicatedMovementMode: number; //	CharacterMovement MovementMode (and custom mode) replicated for simulated proxies.
  ReplicatedServerLastTransformUpdateTimeStamp: unknown; //	CharacterMovement ServerLastTransformUpdateTimeStamp value, replicated to simulated proxies.
  RepRootMotion: unknown; //	Replicated Root Motion montage
  RootMotionRepMoves: unknown; //	Array of previously received root motion moves from the server.
  SavedRootMotion: unknown; //	For LocallyControlled Autonomous clients.
}
