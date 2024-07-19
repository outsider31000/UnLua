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
  // function Class<SUPER extends UObject>(Super?: string): { new (...args: unknown[]): SUPER };
  function Class<SUPER extends UObject>(Super?: string): { new (...args: unknown[]): SUPER & { Super: SUPER } };
  function HotReload(moduleName: string): void;
  function Ref(Object: unknown): void;
  function Unref(Object: unknown): void;
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
  Add(NewItem: unknown): number;
  AddUnique(NewItem: unknown): number;
  Find(ItemToFind: unknown): unknown;
}

declare class TMap {
  Length(): number;
  Num(): number;
  Add(Key: unknown, Value: unknown): void;
}

declare class TSet {}

declare class Color {}

declare class MulticastDelegate {
  Add(Object: UObject, Function: unknown): void;
  Remove(Object: UObject, Function: unknown): void;
  Clear(): void;
  Brodcast(): void;
  IsBound(): boolean;
}

/** @noSelf */
declare function UEPrint(...args: unknown[]): void;
