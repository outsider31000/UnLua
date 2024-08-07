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
  function CollectGarbage(): void;
  function K2_SetTimer(Actor: AActor, FunnctionName : string, Time: number, bLooping: boolean, bMaxOncePerFrame? : boolean, InitialStartDelay? : number, InitialStartDelayVariance? : number): void;
}
