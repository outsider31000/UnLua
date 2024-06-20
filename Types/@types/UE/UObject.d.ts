declare class UObject extends UClass {
    Super: UClass & UObject;

    /**
     * Load an object. for example: UObject.Load("/Game/Core/Blueprints/AI/BehaviorTree_Enemy.BehaviorTree_Enemy")
     * @see LoadObject(...)
     */
    Load(path: string): UObject;

}