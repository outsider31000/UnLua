// OK
declare class UObject {
  Super: UClass & UObject;

  /**
   * Load an object. for example: UObject.Load("/Game/Core/Blueprints/AI/BehaviorTree_Enemy.BehaviorTree_Enemy")
   * @see LoadObject(...)
   */
  public Load(path: string): UObject;

  /**
   * Test validity of an object
   */
  public IsValid(): boolean;

  /**
   * Get the name of an object (with no path information)
   */
  public GetName(): string;

  /**
   * Get the UObject this object resides in
   */
  public GetOuter(): UObject;

  /**
   * Get the UClass that defines the fields of this object
   */
  public GetClass(): UClass;

  /**
   * Get the UWorld this object is contained within
   */
  public GetWorld(): UWorld;

  /**
   * Test whether this object is of the specified type
   */
  public IsA(Object: UObject): boolean;
  public Release(): void;
  public Destroy(Duration?: number): void;
}
