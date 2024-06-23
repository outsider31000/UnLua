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

  public ApplyAsyncOutput(Output: unknown): void;

  // Apply momentum caused by damage.
  public ApplyDamageMomentum(
    DamageTaken: number,
    DamageEvent: unknown,
    PawnInstigator: APawn,
    DamageCauser: AActor,
  ): void;

  // Apply momentum caused by damage.
  protected BaseChange(): void;

  /*
Event called after actor's base changes (if SetBase was requested to notify us with bNotifyPawn).
Public function Virtual	void	
CacheInitialMeshOffset ( FVector MeshRelativeLocation,
FRotator MeshRelativeRotation
)

Cache mesh offset from capsule.
Public function Virtual Const	bool	
CanCrouch ()

 
Public function Const	bool	
CanJump ()

Check if the character can jump in the current state.
Protected function Const	bool	
CanJumpInternal ()

Customizable event to check if the character can jump in the current state.
Protected function Virtual Const	bool	
CanJumpInternal_Implementation ()

Customizable event to check if the character can jump in the current state.
Public function Const	bool	
CanUseRootMotionRepMove ( const FSimulatedRootMotionReplicatedMove& RootMotionRepMove,
const FAnimMontageInstance& ClientMontageInstance
)

True if buffered move is usable to teleport client back to.
Public function Virtual	void	
CheckJumpInput ( float DeltaTime
)

Trigger jump if jump button has been pressed.
Public function Virtual	void	
ClearJumpInput ( float DeltaTime
)

Update jump input state after having checked input.
Public function	void	
ClientAckGoodMove ( float TimeStamp
)

If no client adjustment is needed after processing received ServerMove(), ack the good move so client can remove it from SavedMoves
Public function	void	
ClientAckGoodMove_Implementation ( float TimeStamp
)

If no client adjustment is needed after processing received ServerMove(), ack the good move so client can remove it from SavedMoves
Public function	void	
ClientAdjustPosition ( float TimeStamp,
FVector NewLoc,
FVector NewVel,
UPrimitiveComponent* NewBase,
FName NewBaseBoneName,
bool bHasBase,
bool bBaseRelativePosition,
uint8 ServerMovementMode
)

Replicate position correction to client, associated with a timestamped servermove.
Public function	void	
ClientAdjustPosition_Implementation ( float TimeStamp,
FVector NewLoc,
FVector NewVel,
UPrimitiveComponent* NewBase,
FName NewBaseBoneName,
bool bHasBase,
bool bBaseRelativePosition,
uint8 ServerMovementMode
)

Replicate position correction to client, associated with a timestamped servermove.
Public function	void	
ClientAdjustRootMotionPosition ( float TimeStamp,
float ServerMontageTrackPosition,
FVector ServerLoc,
FVector_NetQuantizeNormal ServerRotation,
float ServerVelZ,
UPrimitiveComponent* ServerBase,
FName ServerBoneName,
bool bHasBase,
bool bBaseRelativePosition,
uint8 ServerMovementMode
)

Replicate position correction to client when using root motion for movement.
Public function	void	
ClientAdjustRootMotionPosition_Implementation ( float TimeStamp,
float ServerMontageTrackPosition,
FVector ServerLoc,
FVector_NetQuantizeNormal ServerRotation,
float ServerVelZ,
UPrimitiveComponent* ServerBase,
FName ServerBoneName,
bool bHasBase,
bool bBaseRelativePosition,
uint8 ServerMovementMode
)

Replicate position correction to client when using root motion for movement.
Public function	void	
ClientAdjustRootMotionSourcePosition ( float TimeStamp,
FRootMotionSourceGroup ServerRootMotion,
bool bHasAnimRootMotion,
float ServerMontageTrackPosition,
FVector ServerLoc,
FVector_NetQuantizeNormal ServerRotation,
float ServerVelZ,
UPrimitiveComponent* ServerBase,
FName ServerBoneName,
bool bHasBase,
bool bBaseRelativePosition,
uint8 ServerMovementMode
)

Replicate root motion source correction to client when using root motion for movement.
Public function	void	
ClientAdjustRootMotionSourcePosition_Implementation ( float TimeStamp,
FRootMotionSourceGroup ServerRootMotion,
bool bHasAnimRootMotion,
float ServerMontageTrackPosition,
FVector ServerLoc,
FVector_NetQuantizeNormal ServerRotation,
float ServerVelZ,
UPrimitiveComponent* ServerBase,
FName ServerBoneName,
bool bHasBase,
bool bBaseRelativePosition,
uint8 ServerMovementMode
)

Replicate root motion source correction to client when using root motion for movement.
Public function	void	
ClientCheatFly ()

 
Public function Virtual	void	
ClientCheatFly_Implementation ()

 
Public function	void	
ClientCheatGhost ()

 
Public function Virtual	void	
ClientCheatGhost_Implementation ()

 
Public function	void	
ClientCheatWalk ()

 
Public function Virtual	void	
ClientCheatWalk_Implementation ()

 
Public function	void	
ClientMoveResponsePacked ( const FCharacterMoveResponsePackedBits& PackedBits
)

Client RPC that passes through to CharacterMovement (avoids RPC overhead for components).
Public function	void	
ClientMoveResponsePacked_Implementation ( const FCharacterMoveResponsePackedBits& PackedBits
)

Client RPC that passes through to CharacterMovement (avoids RPC overhead for components).
Public function	bool	
ClientMoveResponsePacked_Validate ( const FCharacterMoveResponsePackedBits& PackedBits
)

Client RPC that passes through to CharacterMovement (avoids RPC overhead for components).
Public function	void	
ClientVeryShortAdjustPosition ( float TimeStamp,
FVector NewLoc,
UPrimitiveComponent* NewBase,
FName NewBaseBoneName,
bool bHasBase,
bool bBaseRelativePosition,
uint8 ServerMovementMode
)

Bandwidth saving version, when velocity is zeroed
Public function	void	
ClientVeryShortAdjustPosition_Implementation ( float TimeStamp,
FVector NewLoc,
UPrimitiveComponent* NewBase,
FName NewBaseBoneName,
bool bHasBase,
bool bBaseRelativePosition,
uint8 ServerMovementMode
)

Bandwidth saving version, when velocity is zeroed
Public function Virtual	void	
Crouch ( bool bClientSimulation
)

Request the character to start crouching.
Public function Virtual	void	
Falling ()

Called when the character's movement enters falling
Public function Const	void	
FillAsyncInput ( FCharacterAsyncInput& Input
)

Async simulation API
Public function Const	T *	
FindComponentByClass ()

 
Public function Const	int32	
FindRootMotionRepMove ( const FAnimMontageInstance& ClientMontageInstance
)

Find usable root motion replicated move from our buffer.
Public function Const	float	
GetAnimRootMotionTranslationScale ()

Returns current value of AnimRootMotionScale
Public function Const	UArrowComponent *	
GetArrowComponent ()

Returns ArrowComponent subobject
Public function Const	const FBasedMovementInfo &	
GetBasedMovement ()

Accessor for BasedMovement
Public function Virtual Const	FQuat	
GetBaseRotationOffset ()

Get the saved rotation offset of mesh.
Public function Const	FRotator	
GetBaseRotationOffsetRotator ()

Get the saved rotation offset of mesh.
Public function Const	FVector	
GetBaseTranslationOffset ()

Get the saved translation offset of mesh.
Public function Const	UCapsuleComponent *	
GetCapsuleComponent ()

Returns CapsuleComponent subobject
Public function Const	T *	
GetCharacterMovement ()

Returns CharacterMovement subobject
Public function Const	UCharacterMovementComponent *	
GetCharacterMovement ()

 
Public function Const	UAnimMontage *	
GetCurrentMontage ()

Return current playing Montage
Public function Virtual Const	float	
GetJumpMaxHoldTime ()

Get the maximum jump time for the character.
Public function Const	USkeletalMeshComponent *	
GetMesh ()

END DEPRECATED RPCs.
Public function Const	const FBasedMovementInfo &	
GetReplicatedBasedMovement ()

Accessor for ReplicatedBasedMovement
Public function Virtual Const	FVector	
GetReplicatedGravityDirection ()

Returns replicated gravity direction for simulated proxies
Public function Const	uint8	
GetReplicatedMovementMode ()

Returns ReplicatedMovementMode
Public function Const	float	
GetReplicatedServerLastTransformUpdateTimeStamp ()

Accessor for ReplicatedServerLastTransformUpdateTimeStamp.
Public function Const	FAnimMontageInstance *	
GetRootMotionAnimMontageInstance ()

Get FAnimMontageInstance playing RootMotion
Public function Const	bool	
HasAnyRootMotion ()

True if we are playing root motion from any source right now (anim root motion, root motion source)
Public function Const	void	
InitializeAsyncOutput ( FCharacterAsyncOutput& Output
)

 
Public function Virtual Const	bool	
IsJumpProvidingForce ()

True if jump is actively providing a force, such as when the jump key is held and the time it has been held is less than JumpMaxHoldTime.
Public function Const	bool	
IsPlayingNetworkedRootMotionMontage ()

True if we are playing Root Motion right now, through a Montage with RootMotionMode == ERootMotionMode::RootMotionFromMontagesOnly.
Public function Const	bool	
IsPlayingRootMotion ()

True if we are playing Anim root motion right now
Public function Virtual	void	
Jump ()

Make the character jump on the next update.
Protected function Const	bool	
JumpIsAllowedInternal ()

 
Public function	void	
K2_OnEndCrouch ( float HalfHeightAdjust,
float ScaledHalfHeightAdjust
)

Event when Character stops crouching.
Public function	void	
K2_OnMovementModeChanged ( EMovementMode PrevMovementMode,
EMovementMode NewMovementMode,
uint8 PrevCustomMode,
uint8 NewCustomMode
)

Called from CharacterMovementComponent to notify the character that the movement mode has changed.
Public function	void	
K2_OnStartCrouch ( float HalfHeightAdjust,
float ScaledHalfHeightAdjust
)

Event when Character crouches.
Public function	void	
K2_UpdateCustomMovement ( float DeltaTime
)

Event for implementing custom character movement mode.
Public function Virtual	void	
Landed ( const FHitResult& Hit
)

Called upon landing when falling, to perform actions based on the Hit result.
Public function Virtual	void	
LaunchCharacter ( FVector LaunchVelocity,
bool bXYOverride,
bool bZOverride
)

Set a pending launch velocity on the Character.
Public function Virtual	void	
MoveBlockedBy ( const FHitResult& Impact
)

Called when pawn's movement is blocked
Public function Virtual	void	
NotifyJumpApex ()

Called when character's jump reaches Apex. Needs CharacterMovement->bNotifyApex = true
Public function Virtual	void	
OnEndCrouch ( float HalfHeightAdjust,
float ScaledHalfHeightAdjust
)

Called when Character stops crouching.
Public function	void	
OnJumped ()

Event fired when the character has just started jumping
Public function Virtual	void	
OnJumped_Implementation ()

Event fired when the character has just started jumping
Public function	void	
OnLanded ( const FHitResult& Hit
)

Called upon landing when falling, to perform actions based on the Hit result.
Public function	void	
OnLaunched ( FVector LaunchVelocity,
bool bXYOverride,
bool bZOverride
)

Let blueprint know that we were launched
Public function Virtual	void	
OnMovementModeChanged ( EMovementMode PrevMovementMode,
uint8 PreviousCustomMode
)

Called from CharacterMovementComponent to notify the character that the movement mode has changed.
Public function Virtual	void	
OnRep_IsCrouched ()

Handle Crouching replicated from server
Public function	void	
OnRep_ReplayLastTransformUpdateTimeStamp ()

 
Public function Virtual	void	
OnRep_ReplicatedBasedMovement ()

Rep notify for ReplicatedBasedMovement
Public function	void	
OnRep_RootMotion ()

Handles replicated root motion properties on simulated proxies and position correction.
Public function Virtual	void	
OnStartCrouch ( float HalfHeightAdjust,
float ScaledHalfHeightAdjust
)

Called when Character crouches. Called on non-owned Characters through bIsCrouched replication.
Public function Virtual	void	
OnUpdateSimulatedPosition ( const FVector& OldLocation,
const FQuat& OldRotation
)

Called on client after position update is received to respond to the new location and rotation.
Public function	void	
OnWalkingOffLedge ( const FVector& PreviousFloorImpactNormal,
const FVector& PreviousFloorContactNormal,
const FVector& PreviousLocation,
float TimeDelta
)

Event fired when the Character is walking off a surface and is about to fall because CharacterMovement->CurrentFloor became unwalkable.
Public function Virtual	void	
OnWalkingOffLedge_Implementation ( const FVector& PreviousFloorImpactNormal,
const FVector& PreviousFloorContactNormal,
const FVector& PreviousLocation,
float TimeDelta
)

Event fired when the Character is walking off a surface and is about to fall because CharacterMovement->CurrentFloor became unwalkable.
Public function Virtual	float	
PlayAnimMontage ( UAnimMontage* AnimMontage,
float InPlayRate,
FName StartSectionName
)

Play Animation Montage on the character mesh.
Public function	void	
RecalculateCrouchedEyeHeight ()

Calculates the crouched eye height based on movement component settings
Public function Virtual	void	
ResetJumpState ()

Marks character as not trying to jump
Public function	bool	
RestoreReplicatedMove ( const FSimulatedRootMotionReplicatedMove& RootMotionRepMove
)

Restore actor to an old buffered move.
Public function	void	
RootMotionDebugClientPrintOnScreen ( const FString& InString
)

 
Public function Virtual	void	
RootMotionDebugClientPrintOnScreen_Implementation ( const FString& InString
)

 
Public function	void	
SaveRelativeBasedMovement ( const FVector& NewRelativeLocation,
const FRotator& NewRotation,
bool bRelativeRotation
)

Save a new relative location in BasedMovement and a new rotation with is either relative or absolute.
Public function	void	
ServerMove ( float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 CompressedMoveFlags,
uint8 ClientRoll,
uint32 View,
UPrimitiveComponent* ClientMovementBase,
FName ClientBaseBoneName,
uint8 ClientMovementMode
)

BEGIN DEPRECATED RPCs that don't use variable sized payloads. Use ServerMovePacked and ClientMoveResponsePacked instead.
Public function	void	
ServerMove_Implementation ( float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 CompressedMoveFlags,
uint8 ClientRoll,
uint32 View,
UPrimitiveComponent* ClientMovementBase,
FName ClientBaseBoneName,
uint8 ClientMovementMode
)

BEGIN DEPRECATED RPCs that don't use variable sized payloads. Use ServerMovePacked and ClientMoveResponsePacked instead.
Public function	bool	
ServerMove_Validate ( float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 CompressedMoveFlags,
uint8 ClientRoll,
uint32 View,
UPrimitiveComponent* ClientMovementBase,
FName ClientBaseBoneName,
uint8 ClientMovementMode
)

BEGIN DEPRECATED RPCs that don't use variable sized payloads. Use ServerMovePacked and ClientMoveResponsePacked instead.
Public function	void	
ServerMoveDual ( float TimeStamp0,
FVector_NetQuantize10 InAccel0,
uint8 PendingFlags,
uint32 View0,
float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 NewFlags,
uint8 ClientRoll,
uint32 View,
UPrimitiveComponent* ClientMovementBase,
FName ClientBaseBoneName,
uint8 ClientMovementMode
)

Replicated function sent by client to server - contains client movement and view info for two moves.
Public function	void	
ServerMoveDual_Implementation ( float TimeStamp0,
FVector_NetQuantize10 InAccel0,
uint8 PendingFlags,
uint32 View0,
float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 NewFlags,
uint8 ClientRoll,
uint32 View,
UPrimitiveComponent* ClientMovementBase,
FName ClientBaseBoneName,
uint8 ClientMovementMode
)

Replicated function sent by client to server - contains client movement and view info for two moves.
Public function	bool	
ServerMoveDual_Validate ( float TimeStamp0,
FVector_NetQuantize10 InAccel0,
uint8 PendingFlags,
uint32 View0,
float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 NewFlags,
uint8 ClientRoll,
uint32 View,
UPrimitiveComponent* ClientMovementBase,
FName ClientBaseBoneName,
uint8 ClientMovementMode
)

Replicated function sent by client to server - contains client movement and view info for two moves.
Public function	void	
ServerMoveDualHybridRootMotion ( float TimeStamp0,
FVector_NetQuantize10 InAccel0,
uint8 PendingFlags,
uint32 View0,
float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 NewFlags,
uint8 ClientRoll,
uint32 View,
UPrimitiveComponent* ClientMovementBase,
FName ClientBaseBoneName,
uint8 ClientMovementMode
)

Replicated function sent by client to server - contains client movement and view info for two moves.
Public function	void	
ServerMoveDualHybridRootMotion_Implementation ( float TimeStamp0,
FVector_NetQuantize10 InAccel0,
uint8 PendingFlags,
uint32 View0,
float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 NewFlags,
uint8 ClientRoll,
uint32 View,
UPrimitiveComponent* ClientMovementBase,
FName ClientBaseBoneName,
uint8 ClientMovementMode
)

Replicated function sent by client to server - contains client movement and view info for two moves.
Public function	bool	
ServerMoveDualHybridRootMotion_Validate ( float TimeStamp0,
FVector_NetQuantize10 InAccel0,
uint8 PendingFlags,
uint32 View0,
float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 NewFlags,
uint8 ClientRoll,
uint32 View,
UPrimitiveComponent* ClientMovementBase,
FName ClientBaseBoneName,
uint8 ClientMovementMode
)

Replicated function sent by client to server - contains client movement and view info for two moves.
Public function	void	
ServerMoveDualNoBase ( float TimeStamp0,
FVector_NetQuantize10 InAccel0,
uint8 PendingFlags,
uint32 View0,
float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 NewFlags,
uint8 ClientRoll,
uint32 View,
uint8 ClientMovementMode
)

Replicated function sent by client to server - contains client movement and view info for two moves.
Public function	void	
ServerMoveDualNoBase_Implementation ( float TimeStamp0,
FVector_NetQuantize10 InAccel0,
uint8 PendingFlags,
uint32 View0,
float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 NewFlags,
uint8 ClientRoll,
uint32 View,
uint8 ClientMovementMode
)

Replicated function sent by client to server - contains client movement and view info for two moves.
Public function	bool	
ServerMoveDualNoBase_Validate ( float TimeStamp0,
FVector_NetQuantize10 InAccel0,
uint8 PendingFlags,
uint32 View0,
float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 NewFlags,
uint8 ClientRoll,
uint32 View,
uint8 ClientMovementMode
)

Replicated function sent by client to server - contains client movement and view info for two moves.
Public function	void	
ServerMoveNoBase ( float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 CompressedMoveFlags,
uint8 ClientRoll,
uint32 View,
uint8 ClientMovementMode
)

Replicated function sent by client to server.
Public function	void	
ServerMoveNoBase_Implementation ( float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 CompressedMoveFlags,
uint8 ClientRoll,
uint32 View,
uint8 ClientMovementMode
)

Replicated function sent by client to server.
Public function	bool	
ServerMoveNoBase_Validate ( float TimeStamp,
FVector_NetQuantize10 InAccel,
FVector_NetQuantize100 ClientLoc,
uint8 CompressedMoveFlags,
uint8 ClientRoll,
uint32 View,
uint8 ClientMovementMode
)

Replicated function sent by client to server.
Public function	void	
ServerMoveOld ( float OldTimeStamp,
FVector_NetQuantize10 OldAccel,
uint8 OldMoveFlags
)

Resending an (important) old move. Process it if not already processed.
Public function	void	
ServerMoveOld_Implementation ( float OldTimeStamp,
FVector_NetQuantize10 OldAccel,
uint8 OldMoveFlags
)

Resending an (important) old move. Process it if not already processed.
Public function	bool	
ServerMoveOld_Validate ( float OldTimeStamp,
FVector_NetQuantize10 OldAccel,
uint8 OldMoveFlags
)

Resending an (important) old move. Process it if not already processed.
Public function	void	
ServerMovePacked ( const FCharacterServerMovePackedBits& PackedBits
)

Server RPC that passes through to CharacterMovement (avoids RPC overhead for components).
Public function	void	
ServerMovePacked_Implementation ( const FCharacterServerMovePackedBits& PackedBits
)

Server RPC that passes through to CharacterMovement (avoids RPC overhead for components).
Public function	bool	
ServerMovePacked_Validate ( const FCharacterServerMovePackedBits& PackedBits
)

Server RPC that passes through to CharacterMovement (avoids RPC overhead for components).
Public function	void	
SetAnimRootMotionTranslationScale ( float InAnimRootMotionTranslationScale
)

Sets scale to apply to root motion translation on this Character
Public function Virtual	void	
SetBase ( UPrimitiveComponent* NewBase,
const FName BoneName,
bool bNotifyActor
)

Sets the component the Character is walking on, used by CharacterMovement walking movement to be able to follow dynamic objects.
Public function Virtual	bool	
ShouldNotifyLanded ( const FHitResult& Hit
)

Returns true if the Landed() event should be called.
Public function	void	
SimulatedRootMotionPositionFixup ( float DeltaSeconds
)

Position fix up for Simulated Proxies playing Root Motion
Public function Virtual	void	
StopAnimMontage ( UAnimMontage* AnimMontage
)

Stop Animation Montage.
Public function Virtual	void	
StopJumping ()

Stop the character from jumping on the next update.
Public function Virtual	void	
UnCrouch ( bool bClientSimulation
)

Request the character to stop crouching.
*/
}
