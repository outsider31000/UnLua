declare class UActor extends UObject {
    constructor();
    Initialize(Initializer: any[]): void;
    UserConstructionScript(): void;
    ReceiveBeginPlay(): void;
    ReceiveEndPlay(): void;
    ReceiveTick(DeltaSeconds: number): void;
    ReceiveAnyDamage(Damage: any, DamageType: any, InstigatedBy: any, DamageCauser: any): void;
    ReceiveActorBeginOverlap(OtherActor: UActor): void;
    ReceiveActorEndOverlap(OtherActor: UActor): void;

    GetWorld(): UWorld;
}

