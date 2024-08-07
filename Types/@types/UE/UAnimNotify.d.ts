// https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/Animation/UAnimNotify

declare class UAnimNotify extends UObject {
  // Base class for any 'notify' type actions that can be triggered by an AnimSequence
  // This is the base class for any AnimNotify type actions that can be triggered
  // by an AnimSequence. It contains any data or methods that would be used to
  // implement such functionality.

  // Properties
  bIsNativeBranchingPoint: boolean; // Is this a native branching point notify?

  // Functions
  // Implemented in Blueprint. Called by the animation when it reaches the notify's time
  // within the sequence.
  Notify(MeshComp: unknown, Animation: unknown): void;
  
  // Returns the name of the notify
  GetNotifyName(): string;
  
  // Initializes this AnimNotify instance
  InitializeNotify(): void;
  
  // Called when the notify is triggered in the editor.
  NotifyBeginPreview(PreviewComponent: unknown, PreviewAnimInstance: unknown): void;

  // Called when the notify is triggered in the editor.
  NotifyEndPreview(PreviewComponent: unknown, PreviewAnimInstance: unknown): void;

  // Called by the animation when it reaches the notify's end time
  NotifyEnd(MeshComp: unknown, Animation: unknown): void;

  // Called to initialize the notify from a UObject
  PostInitProperties(): void;
  
  // Resets this AnimNotify instance
  ResetNotify(): void;
  
  // Sets up the notify from a UObject
  SetupNotifyFromObject(InObject: UObject): void;
}