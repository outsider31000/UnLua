// https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/GameFramework/AActor

declare class AActor extends UObject {
  ActorGuid: unknown; //	The GUID for this actor; this guid will be the same for actors from instanced streaming levels.
  ActorInstanceGuid: unknown; //	The instance GUID for this actor; this guid will be unique for actors from instanced streaming levels.
  AttachmentReplication: unknown; //	Used for replicating attachment of this actor's RootComponent to another actor.
  AutoReceiveInput: unknown; //	Automatically registers this actor to receive input from a player.
  bActorLabelEditable: boolean; //	Is the actor label editable by the user?
  bActorSeamlessTraveled: boolean; //	Indicates the actor was pulled through a seamless travel.
  bAllowReceiveTickEventOnDedicatedServer: boolean; //	If false, the Blueprint ReceiveTick() event will be disabled on dedicated servers.
  bAllowTickBeforeBeginPlay: boolean; //	Whether we allow this Actor to tick before it receives the BeginPlay event.
  bAlwaysRelevant: boolean; //	Always relevant for network (overrides bOnlyRelevantToOwner).
  bAsyncPhysicsTickEnabled: boolean; // Whether to use use the async physics tick with this actor.
  bBlockInput: boolean; //	If true, all input on the stack below this actor will not be considered
  bCanBeInCluster: boolean; //	If true, this actor can be put inside of a GC Cluster to improve Garbage Collection performance
  bCanPlayFromHere: boolean; //	Whether the actor can be used as a PlayFromHere origin (OnPlayFromHere() will be called on that actor)
  bCollideWhenPlacing: boolean; //	This actor collides with the world when placing in the editor, even if RootComponent collision is disabled.
  bDefaultOutlinerExpansionState: boolean; //	Default expansion state for this actor.
  bEditable: boolean; //	Whether the actor can be manipulated by editor operations.
  bEnableAutoLODGeneration: boolean; //	Whether this actor should be considered or not during HLOD generation.
  bExchangedRoles: boolean; //	Whether we have already exchanged Role/RemoteRole on the client, as when removing then re-adding a streaming level.
  bFindCameraComponentWhenViewTarget: boolean; //	If true, this actor should search for an owned camera component to view through when used as a view target.
  bGenerateOverlapEventsDuringLevelStreaming: boolean; //	If true, this actor will generate overlap Begin/End events when spawned as part of level streaming, which includes initial level load.
  bHiddenEd: boolean; //	Whether this actor is hidden within the editor viewport.
  bHiddenEdLayer: boolean; //	Whether this actor is hidden by the layer browser.
  bHiddenEdLevel: boolean; //	Whether this actor is hidden by the level browser.
  bIgnoresOriginShifting: boolean; //	Whether this actor should not be affected by world origin shifting.
  bIsEditorOnlyActor: boolean; //Whether this actor is editor-only.
  bIsEditorPreviewActor: boolean; //	True if this actor is the preview actor dragged out of the content browser
  bIsMainWorldOnly: boolean;
  bIsSpatiallyLoaded: boolean; //	Determine if this actor is spatially loaded when placed in a partitioned world.
  bListedInSceneOutliner: boolean; //	Whether this actor should be listed in the scene outliner.
  bLockLocation: boolean; //	If true, prevents the actor from being moved in the editor viewport.
  BlueprintCreatedComponents: unknown; //	Array of ActorComponents that are created by blueprints and serialized per-instance.
  bNetCheckedInitialPhysicsState: boolean; //	Flag indicating we have checked initial simulating physics state to sync networked proxies to the server.
  bNetLoadOnClient: boolean; //	This actor will be loaded on network clients during map load
  bNetStartup: boolean; //	If true, this actor was loaded directly from the map, and for networking purposes can be addressed by its full path name
  bNetTemporary: boolean; //	If true, when the actor is spawned it will be sent to the client but receive no further replication updates from the server afterwards.
  bNetUseOwnerRelevancy: boolean; //	If actor has valid Owner, call Owner's IsNetRelevantFor and GetNetPriority
  bOnlyRelevantToOwner: boolean; //	If true, this actor is only relevant to its owner.
  bOptimizeBPComponentData: boolean; //	Whether to cook additional data to speed up spawn events at runtime for any Blueprint classes based on this Actor.
  bRelevantForLevelBounds: boolean; //	If true, this actor's component's bounds will be included in the level's bounding box unless the Actor's class has overridden IsLevelBoundsRelevant
  bRelevantForNetworkReplays: boolean; //	If true, this actor will be replicated to network replays (default is true)
  bReplayRewindable: boolean; //	If true, this actor will only be destroyed during scrubbing if the replay is set to a time before the actor existed.
  bReplicates: boolean; //	If true, this actor will replicate to remote machines
  bReplicateUsingRegisteredSubObjectList: boolean; //	When true the replication system will only replicate the registered subobjects and the replicated actor components list When false the replication system will instead call the virtual ReplicateSubobjects() function where the subobjects and actor components need to be manually replicated.
  bRunConstructionScriptOnDrag: boolean; //	If true during PostEditMove the construction script will be run every time.
  Children: unknown; //	Array of all Actors whose Owner is this actor, these are not necessarily spawned by UChildActorComponent
  ContentBundleGuid: unknown; //	The GUID for this actor's content bundle.
  CopyPasteId: number; //	The copy/paste id used to remap actors during copy operations
  CreationTime: number; //	The time this actor was created, relative to World->GetTimeSeconds().
  CurrentTransactionAnnotation: unknown; //	Cached pointer to the transaction annotation data from PostEditUndo to be used in the next RerunConstructionScript
  CustomTimeDilation: number; //	Allow each actor to run at a different time speed.
  DataLayerAssets: unknown;
  DataLayers: unknown;
  GroupActor: AActor; //	The editor-only group this actor is a part of.
  HiddenEditorViews: bigint; //	Bitflag to represent which views this actor is hidden in, via per-view layer visibility.
  InitialLifeSpan: number; //	How long this Actor lives before dying, 0=forever.
  InputComponent: unknown; //	Component that handles input for this actor, if input is enabled.
  InputPriority: number; //	The priority of this input component when pushed in to the stack.
  IntermediateOwner: unknown; //	Used to track changes to Owner during Undo events.
  Layers: unknown; //	Layers the actor belongs to.
  MinNetUpdateFrequency: number; //	Used to determine what rate to throttle down to when replicated properties are changing infrequently
  NetCullDistanceSquared: number; //	Square of the max distance from the client's viewpoint that this actor is relevant and will be replicated.
  NetDormancy: unknown; //	Dormancy setting for actor to take itself off of the replication list without being destroyed on clients.
  NetDriverName: string; //	Used to specify the net driver to replicate on (NAME_None	 	NAME_GameNetDriver is the default net driver)
  NetPriority: number; //	Priority for this actor when checking for replication in a low bandwidth or saturated situation, higher priority means it is more likely to replicate
  NetTag: number; //	Internal - used by UNetDriver
  NetUpdateFrequency: number; //	How often (per second) this actor will be considered for replication, used to determine NetUpdateTime
  OnActorBeginOverlap: unknown; //	Called when another actor begins to overlap this actor, for example a player walking into a trigger.
  OnActorEndOverlap: unknown; //	Called when another actor stops overlapping this actor.
  OnActorHit: unknown; //	Called when this Actor hits (or is hit by) something solid.
  OnBeginCursorOver: unknown; //	Called when the mouse cursor is moved over this actor if mouse over events are enabled in the player controller.
  OnClicked: unknown; //	Called when the left mouse button is clicked while the mouse is over this actor and click events are enabled in the player controller.
  OnDestroyed: unknown; //	Event triggered when the actor has been explicitly destroyed.
  OnEndCursorOver: unknown; //	Called when the mouse cursor is moved off this actor if mouse over events are enabled in the player controller.
  OnEndPlay: unknown; //	Event triggered when the actor is being deleted or removed from a level.
  OnInputTouchBegin: unknown; //	Called when a touch input is received over this actor when touch events are enabled in the player controller.
  OnInputTouchEnd: unknown; //	Called when a touch input is received over this component when touch events are enabled in the player controller.
  OnInputTouchEnter: unknown; //	Called when a finger is moved over this actor when touch over events are enabled in the player controller.
  OnInputTouchLeave: unknown; //	Called when a finger is moved off this actor when touch over events are enabled in the player controller.
  OnPackagingModeChanged: unknown;
  OnReleased: unknown; //	Called when the left mouse button is released while the mouse is over this actor and click events are enabled in the player controller.
  OnTakeAnyDamage: unknown; //	Called when the actor is damaged in any way.
  OnTakePointDamage: unknown; //	Called when the actor is damaged by point damage.
  OnTakeRadialDamage: unknown; //	Called when the actor is damaged by radial damage.
  Owner: AActor; //	Owner of this Actor, used primarily for replication (bNetUseOwnerRelevancy & bOnlyRelevantToOwner) and visibility (PrimitiveComponent bOwnerNoSee and bOnlyOwnerSee)
  PivotOffset: FVector; //	Local space pivot offset for the actor, only used in the editor
  PreEditChangeDataLayers: unknown;
  PrimaryActorTick: unknown; //	Primary Actor tick function, which calls TickActor().
  ReplicatedComponents: unknown; //	Set of replicated components, stored as an array to save space as this is generally not very large
  RootComponent: unknown; //	The component that defines the transform (location, rotation, scale) of this Actor in the world, all other components must be attached to this one somehow
  RuntimeGrid: string; //	Determine in which partition grid this actor will be placed in the partition (if the world is partitioned).
  SpawnCollisionHandlingMethod: unknown; //	Controls how to handle spawning this actor in a situation where it's colliding with something else.
  SpriteScale: number; //	The scale to apply to any billboard components in editor builds (happens in any WITH_EDITOR build, including non-cooked games).
  Tags: unknown; //	Array of tags that can be used for grouping and categorizing.
  TimerHandle_LifeSpanExpired: unknown; //	Handle for efficient management of LifeSpanExpired timer
  UpdateOverlapsMethodDuringLevelStreaming: unknown; //	Condition for calling UpdateOverlaps() to initialize overlap state when loaded in during level streaming.

  Initialize(Initializer: unknown[]): void;
  UserConstructionScript(): void;
  ReceiveBeginPlay(): void;
  ReceiveEndPlay(): void;
  ReceiveTick(DeltaSeconds: number): void;
  ReceiveAnyDamage(
    Damage: number,
    DamageType: unknown,
    InstigatedBy: unknown,
    DamageCauser: unknown,
  ): void;
  ReceiveActorBeginOverlap(OtherActor: AActor): void;
  ReceiveActorEndOverlap(OtherActor: AActor): void;

  GetWorld(): UWorld;

  // Returns Distance to closest Body Instance surface.
  ActorGetDistanceToCollision(): number;

  // See if this actor's Tags array contains the supplied name tag
  ActorHasTag(Tag: string): boolean;

  // Trace a ray against the Components of this Actor and return the first blocking hit
  ActorLineTraceSingle(): boolean;

  // Get the local-to-world transform of the RootComponent.
  ActorToWorld(): unknown;

  // Register a SubObject that will get replicated along with the actor component owning it.
  AddActorComponentReplicatedSubObject(): void;

  // Adds a delta to the location of this component in its local reference frame.
  AddActorLocalOffset(): void;

  // Adds a delta to the rotation of this component in its local reference frame
  AddActorLocalRotation(): void;
}
