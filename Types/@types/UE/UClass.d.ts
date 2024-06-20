declare class UClass {
    /**
    * Load a class. for example: UClass.Load("/Game/Core/Blueprints/AICharacter.AICharacter_C")
    */
    Load(Path: string): UClass

    /**
    * Test whether this class is a child of another class
    */
    IsChildOf(TargetClass: UClass): boolean

    /**
    * Get the default object of UClass.
    */
    GetDefaultObject(): UObject
}