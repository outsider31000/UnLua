type FVector = number & Vector3;

declare class Vector3 {
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
  Size2D(): number;
  SizeSquared(): number;
  SizeSquared2D(): number;
  IsNormalized(): boolean;
  CosineAngle2D(): unknown;
  RotateAngleAxis(): unknown;

  static Dist(a: FVector, b: FVector): number;
  static Dist2D(a: FVector2D, b: FVector2D): number;
  static DistSquared(a: FVector, b: FVector): number;
  static DistSquared2D(a: FVector2D, b: FVector2D): number;
}

/** @noSelf @customName UE.FVector **/
declare function FVector(x?: number, y?: number, z?: number): FVector;

type FVector4 = number & Vector4;

declare class Vector4 {
  X: number;
  Y: number;
  Z: number;
  W: number;
}

type FVector2D = Vector2;
declare class Vector2 {
  X: number;
  Y: number;
}

type FQuat = number & Quat;

declare class Quat {
  X: number;
  Y: number;
  Z: number;
  W: number;

  Set(x: number, y: number, z: number, w: number): void;
  FromAxisAndAngle(axis: FVector, angle: number): void;
  GetNormalized(): FQuat;
  IsNormalized(): boolean;
  Size(): number;
  SizeSquared(): number;
  ToAxisAndAngle(): unknown; // multi return: FVector, number
  Inverse(): FQuat;
  RotateVector(): FVector;
  UnrotateVector(): FVector;
  GetAxisX(): FVector;
  GetAxisY(): FVector;
  GetAxisZ(): FVector;
  GetForwardVector(): FVector;
  GetRightVector(): FVector;
  GetUpVector(): FVector;
  Slerp(a: FQuat, alpha: number): FQuat;
  ToEuler(): FVector;
  ToRotator(): FRotator;
}

/** @noSelf @customName UE.FQuat **/
declare function FQuat(x?: number, y?: number, z?: number, w?: number): FQuat;

/** @noSelf @customName UE.FQuat **/
declare function FQuat(R: FRotator): FQuat;

/** @noSelf @customName UE.FQuat **/
declare function FQuat(Axis: FVector, AngleRad: number): FQuat;

type FRotator = Rotator;
declare class Rotator {
  Pitch: number;
  Yaw: number;
  Roll: number;
}

type FTransform = Transform;
declare class Transform {
  Rotation: FQuat;
  Translation: FVector;
  Scale: FVector;
}
