declare namespace UKismetSystemLibrary {
  function PrintString(
    target: Object,
    msg: string,
    a: boolean,
    b: boolean,
    color: FLinearColor,
    duration: number,
  ): void;
  function Delay(Actor: UActor, Duration?: number): void;
}
