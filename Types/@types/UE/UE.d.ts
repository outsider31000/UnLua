

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

declare class UClass {
    Load(Path: string): UClass
    IsChildOf(TargetClass: UClass): boolean
    GetDefaultObject(): UObject
}

declare class UObject extends UClass {
    Super: UClass & UObject;

    Test(): void;
}

declare class MulticastDelegate {
    Add(Object: UObject, Function: any): void;
    Remove(Object: UObject, Function: any): void;
    Clear(): void;
    Brodcast(): void;
    IsBound(): boolean;
}

/*
declare class UProjectile extends UnLua.Class("UProjectile") {
    BaseColor: Color;
}
    */


declare class UActor extends UClass {
    Initialize(Initializer: any[]): void;
    UserConstructionScript(): void;
    ReceiveBeginPlay(): void;
    ReceiveEndPlay(): void;
    ReceiveTick(DeltaSeconds: number): void;
    ReceiveAnyDamage(Damage: any, DamageType: any, InstigatedBy: any, DamageCauser: any): void;
    ReceiveActorBeginOverlap(OtherActor: UActor): void;
    ReceiveActorEndOverlap(OtherActor: UActor): void;
}

declare class UPawn extends UActor {
}

declare namespace UKismetMathLibrary {

}

declare namespace UWidgetBlueprintLibrary {

}

declare namespace UGameplayStatics {
    function GetWorldDeltaSeconds(): number;
}


/** @noSelf */
declare function UEPrint(...args: any[]): void

