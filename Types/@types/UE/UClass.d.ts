// https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/Engine/UBlueprintGeneratedClass

declare class UClass extends UObject {
  /**
   * Load a class. for example: UClass.Load("/Game/Core/Blueprints/AICharacter.AICharacter_C")
   */
  Load(Path: string): UClass;

  /**
   * Test whether this class is a child of another class
   */
  IsChildOf(TargetClass: UClass): boolean;

  /**
   * Get the default object of UClass.
   */
  GetDefaultObject(): UObject;
}
