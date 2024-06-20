

/** @noSelf **/
declare namespace UnLua {
    function Class(cls: string): any | UClass | UActor | UPawn;

    function HotReload(moduleName: string): void;
    function Ref(Object: any): void;
    function Unref(Object: any): void;
}

declare class TArray {
    Length(): number;
    Num(): number;
    Add(NewItem: any): number;
    AddUnique(NewItem: any): number;
    Find(ItemToFind: any): any;
}

declare class TMap {
    Length(): number;
    Num(): number;
    Add(Key: any, Value: any): void;
}

declare class TSet {

}

declare class Color {

}





declare class MulticastDelegate {
    Add(Object: UObject, Function: any): void;
    Remove(Object: UObject, Function: any): void;
    Clear(): void;
    Brodcast(): void;
    IsBound(): boolean;
}

declare class UActor extends UObject {
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

declare class UPawn extends UActor {
}

declare class UWeapon extends UActor {
    GetFireInfo(): any;
}

/** @customConstructor UE.FLinearColor */
declare class FLinearColor {
    R: number;
    G: number;
    B: number;
    A: number;

    constructor(r: number, g: number, b: number, a: number);
}

/** @customConstructor UE.FColor */
declare class FColor {
    R: number;
    G: number;
    B: number;
    A: number;

    constructor(r: number, g: number, b: number, a: number);
}

declare namespace UKismetMathLibrary {
    function RandomFloat(): number;
}

declare namespace UWidgetBlueprintLibrary {

}

declare namespace UGameplayStatics {
    function GetWorldDeltaSeconds(): number;
}

declare class UWorld {
    SpawnActor(Class: UClass, Transform: any): UActor;
}

/** @noSelf */
declare function UEPrint(...args: any[]): void

