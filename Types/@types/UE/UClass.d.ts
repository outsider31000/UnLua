declare class UClass {
    Load(Path: string): UClass
    IsChildOf(TargetClass: UClass): boolean
    GetDefaultObject(): UObject
}