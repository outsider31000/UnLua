// https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/GameFramework/APawn
declare class APawn extends AActor {
  AIControllerClass: unknown; //	Default class to use when pawn is controlled by AI.
  AllowedYawError: number; //	Max difference between pawn's Rotation.Yaw and GetDesiredRotation().Yaw for pawn to be considered as having reached its desired rotation
  AutoPossessAI: unknown; //	Determines when the Pawn creates and is possessed by an AI Controller (on level start, when spawned, etc).
  AutoPossessPlayer: unknown; //	Determines which PlayerController, if any, should automatically possess the pawn when the level starts or when the pawn is spawned.
  BaseEyeHeight: number; //	Base eye height above collision center.
  bCanAffectNavigationGeneration: boolean; //	If set to false (default) given pawn instance will never affect navigation generation (but components could).
  bIsLocalViewTarget: boolean;
  BlendedReplayViewPitch: number; //	Playback of replays writes blended pitch to this, rather than the RemoteViewPitch.
  bUseControllerRotationPitch: boolean; //	If true, this Pawn's pitch will be updated to match the Controller's ControlRotation pitch, if controlled by a PlayerController.
  bUseControllerRotationRoll: boolean; //	If true, this Pawn's roll will be updated to match the Controller's ControlRotation roll, if controlled by a PlayerController.
  bUseControllerRotationYaw: boolean; //	If true, this Pawn's yaw will be updated to match the Controller's ControlRotation yaw, if controlled by a PlayerController.
  ControlInputVector: FVector; //	Accumulated control input vector, stored in world space.
  Controller: unknown; //	Controller currently possessing this Actor
  LastControlInputVector: FVector; //	The last control input vector that was processed by ConsumeMovementInputVector().
  LastHitBy: unknown; //	Controller of the last Actor that caused us damage.
  OverrideInputComponentClass: unknown; //	If set, then this InputComponent class will be used instead of the Input Settings' DefaultInputComponentClass
  PreviousController: unknown; //	Previous controller that was controlling this pawn since the last controller change notification
  ReceiveControllerChangedDelegate: unknown; //	Event called after a pawn's controller has changed, on the server and owning client.
  ReceiveRestartedDelegate: unknown; //	Event called after a pawn has been restarted, usually by a possession change.
  RemoteViewPitch: number; //	Replicated so we can see where remote clients are looking.

  ///
  IsDead: boolean;
  BodyDuration: number;
  BoneName: string | null;
  Health: number;
  MaxHealth: number;
  Weapon: Weapon;
  Mesh: Mesh;

  WeaponPoint: FVector;

  CapsuleComponent: CapsuleComponent;

  StartFire(): void;
  StopFire(): void;
  GetController(): Controller;
  StartFire_Multicast(): void;
  StopFire_Multicast(): void;
  Died_Multicast(DamageType: unknown): void;
  /*
  StartFire_Server_RPC(): void; // unused
  StopFire_Server_RPC(): void; // unused

  StartFire_Multicast_RPC(): void; // unused
  StopFire_Multicast_RPC(): void; // unused

  Died_Multicast_RPC(DamageType: unknown): void; //  unused

  ChangeToRagdoll(): void;

  SpawnWeapon(): Weapon | null;
  
  */
}
