declare namespace UKismetSystemLibrary {
  function PrintString(
    target: UObject,
    msg: string,
    a: boolean,
    b: boolean,
    color: FLinearColor,
    duration: number,
  ): void;
  function Delay(Actor: AActor, Duration?: number): void;
}
