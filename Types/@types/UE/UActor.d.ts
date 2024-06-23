// https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/GameFramework/AActor

declare class UActor extends UObject {
    constructor();
    Initialize(Initializer: any[]): void;
    UserConstructionScript(): void;
    ReceiveBeginPlay(): void;
    ReceiveEndPlay(): void;
    ReceiveTick(DeltaSeconds: number): void;
    ReceiveAnyDamage(Damage: number, DamageType: any, InstigatedBy: any, DamageCauser: any): void;
    ReceiveActorBeginOverlap(OtherActor: UActor): void;
    ReceiveActorEndOverlap(OtherActor: UActor): void;

    GetWorld(): UWorld;



    // Returns Distance to closest Body Instance surface.
    ActorGetDistanceToCollision(): number;

    // See if this actor's Tags array contains the supplied name tag
    ActorHasTag(Tag: string): boolean;

    // Trace a ray against the Components of this Actor and return the first blocking hit
    ActorLineTraceSingle(): boolean;

    // Get the local-to-world transform of the RootComponent.
    ActorToWorld(): any;

    // Register a SubObject that will get replicated along with the actor component owning it.
    AddActorComponentReplicatedSubObject(): void;

    // Adds a delta to the location of this component in its local reference frame.
    AddActorLocalOffset(): void
}

