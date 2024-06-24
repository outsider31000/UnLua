type FVector = number & Vector;

declare class Vector {
  X: number;
  Y: number;
  Z: number;
  Add: LuaAdditionMethod<FVector, FVector> & LuaAdditionMethod<number, FVector>;
  Sub: LuaSubtractionMethod<FVector, FVector> & LuaSubtractionMethod<number, FVector>;
  Mul: LuaMultiplicationMethod<FVector, FVector> & LuaMultiplicationMethod<number, FVector>;
  Div: LuaDivisionMethod<FVector, FVector> & LuaDivisionMethod<number, FVector>;
  Set(x: number, y: number, z: number): void;
  Normalize(): boolean;
  Dot(a: FVector): number;
  Cross(a: FVector): FVector;
  ToRotator(): FRotator;
  ToQuat(): FQuat;
  Size(): number;
  Size2D(): unknown;
  SizeSquared(): number;
  SizeSquared2D(): unknown;
  IsNormalized(): boolean;
  CosineAngle2D(): unknown;
  RotateAngleAxis(): unknown;

  static Dist(a: FVector): number;
  static Dist2D(a: unknown): unknown;
  static DistSquared(a: FVector): number;
  static DistSquared2D(a: unknown): unknown;
}

/** @noSelf @customName UE.FVector **/
declare function FVector(x?: number, y?: number, z?: number): FVector;

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
