
/** @customConstructor UE.FVector */
declare class FVector {
    constructor();
    constructor(InF: number);
    constructor(InX: number, InY: number, InZ: number);
    constructor(Param1: number);
    X: number;
    Y: number;
    Z: number;

    Add: LuaAdditionMethod<FVector, FVector> & LuaAdditionMethod<number, FVector>;
    Sub: LuaSubtractionMethod<FVector, FVector> & LuaSubtractionMethod<number, FVector>;
    Mul: LuaMultiplicationMethod<FVector, FVector> & LuaMultiplicationMethod<Number, FVector>;
    Div: LuaDivisionMethod<FVector, FVector> & LuaDivisionMethod<number, FVector>;

}

declare class FRotator {
    constructor();
    constructor(InF: number);
    constructor(InPitch: number, InYaw: number, InRoll: number);
    constructor(Param1: number);
    constructor(Quat: FQuat);
    Pitch: number;
    Yaw: number;
    Roll: number;
}

declare class FQuat {
    constructor();
    constructor(Param1: number);
    constructor(InX: number, InY: number, InZ: number, InW: number);
    constructor(R: FRotator);
    constructor(Axis: FVector, AngleRad: number);
    X: number;
    Y: number;
    Z: number;
    W: number;
}
