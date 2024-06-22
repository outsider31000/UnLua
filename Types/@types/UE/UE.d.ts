

/**
 * Export UObject
 */
/*
BEGIN_EXPORT_REFLECTED_CLASS(UObject)
    ADD_LIB(UObjectLib)
END_EXPORT_CLASS()
IMPLEMENT_EXPORTED_CLASS(UObject)
*/



/** @noSelf **/
declare namespace UnLua {
    function Class<T>(cls?: string): { new(): T };
    function Class<T extends UObject>(cls?: string): { new(...args: any[]): T };

    function Classes<T extends UObject>(ctor: { new(...args: any[]): T }): { new(...args: any[]): T };


    function HotReload(moduleName: string): void;
    function Ref(Object: any): void;
    function Unref(Object: any): void;


}

/** @noSelf **/
declare namespace UE {
    function LoadObject(Path: string): UObject;
    function LoadClass(Path: string): UClass;
    function NewObject(Path: string): UObject;
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
    constructor();
    name: "UActor";
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

