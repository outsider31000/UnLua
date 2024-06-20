

declare class UActor {

}
declare class Weapon {

}

declare class UClass {
    constructor();
    Initialize(): void
    ReceiveBeginPlay(): void;
    ReceiveActorBeginOverlap(actor: UActor): void;
    ReceiveActorEndOverlap(actor: UActor): void;
}