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
  function Class<T extends UObject>(cls?: string): { new (...args: any[]): T };
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

declare class TSet {}

declare class Color {}

declare class MulticastDelegate {
  Add(Object: UObject, Function: any): void;
  Remove(Object: UObject, Function: any): void;
  Clear(): void;
  Brodcast(): void;
  IsBound(): boolean;
}

/** @noSelf */
declare function UEPrint(...args: any[]): void;
