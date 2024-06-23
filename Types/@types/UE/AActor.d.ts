// https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/GameFramework/AActor

declare class AActor extends UObject {
  constructor();
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
