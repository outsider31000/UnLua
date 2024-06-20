/** @customConstructor UE.FLinearColor */
declare class FLinearColor {
    R: number;
    G: number;
    B: number;
    A: number;

    constructor(r: number, g: number, b: number, a: number);
}

/** @customConstructor UE.FColor */
declare class FColor {
    R: number;
    G: number;
    B: number;
    A: number;

    constructor(r: number, g: number, b: number, a: number);

    Set(r: number, g: number, b: number, a: number): void;
}