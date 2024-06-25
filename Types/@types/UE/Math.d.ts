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
}

/** @noSelf @customName UE.FVector **/
declare function FVector(x?: number, y?: number, z?: number): FVector;

/** @noSelf @customName UE.FVector.Dist **/
declare function Dist(a: FVector, b: FVector): number;

/** @noSelf @customName UE.FVector.Dist2D **/
declare function Dist2D(a: FVector, b: FVector): number;

/** @noSelf @customName UE.FVector.DistSquared **/
declare function DistSquared(a: FVector, b: FVector): number;

/** @noSelf @customName UE.FVector.DistSquared2D **/
declare function DistSquared2D(a: FVector, b: FVector): number;

type FVector2D = Vector2;
declare class Vector2 {
  X: number;
  Y: number;
  Add: LuaAdditionMethod<FVector2D, FVector2D> & LuaAdditionMethod<number, FVector2D>;
  Sub: LuaSubtractionMethod<FVector2D, FVector2D> & LuaSubtractionMethod<number, FVector2D>;
  Mul: LuaMultiplicationMethod<FVector2D, FVector2D> & LuaMultiplicationMethod<number, FVector2D>;
  Div: LuaDivisionMethod<FVector2D, FVector2D> & LuaDivisionMethod<number, FVector2D>;
  Dot(a: FVector2D): number;
  Cross(a: FVector2D): FVector2D;
  Size(): number;
  SizeSquared(): number;
}

/** @noSelf @customName UE.FVector2D **/
declare function FVector2D(x?: number, y?: number): FVector2D;

/** @noSelf @customName UE.FVector2D.Dist **/
declare function Dist(a: FVector2D, b: FVector2D): number;

/** @noSelf @customName UE.FVector2D.DistSquared **/
declare function DistSquared(a: FVector2D, b: FVector2D): number;

type FVector4 = number & Vector4;

declare class Vector4 {
  X: number;
  Y: number;
  Z: number;
  W: number;
  Add: LuaAdditionMethod<FVector4, FVector4> & LuaAdditionMethod<number, FVector4>;
  Sub: LuaSubtractionMethod<FVector4, FVector4> & LuaSubtractionMethod<number, FVector4>;
  Mul: LuaMultiplicationMethod<FVector4, FVector4> & LuaMultiplicationMethod<number, FVector4>;
  Div: LuaDivisionMethod<FVector4, FVector4> & LuaDivisionMethod<number, FVector4>;
  Cross(a: FVector4): FVector4;
  Size(): number;
  Size3(): number;
  SizeSquared(): number;
  SizeSquared3(): number;
  ToRotator(): FRotator;
  ToQuat(): FQuat;
}

/** @noSelf @customName UE.FVector4 **/
declare function FVector4(x?: number, y?: number, z?: number, w?: number): FVector4;

/** @noSelf @customName UE.FVector4.Dot3 **/
declare function Dot3(a: FVector4, b: FVector4): number; // Unreal Engine 5.x

// UnLua\Private\MathLib\LuaLib_FQuat.cpp
type FQuat = number & Quat;
declare class Quat {
  X: number;
  Y: number;
  Z: number;
  W: number;
  Add: LuaAdditionMethod<Quat, Quat> & LuaAdditionMethod<number, Quat>;
  Sub: LuaSubtractionMethod<Quat, Quat> & LuaSubtractionMethod<number, Quat>;
  Mul: LuaMultiplicationMethod<Quat, Quat> & LuaMultiplicationMethod<number, Quat>;
  Div: LuaDivisionMethod<Quat, Quat> & LuaDivisionMethod<number, Quat>;
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

  ToEuler(): FVector;
  ToRotator(): FRotator;
}

/** @noSelf @customName UE.FQuat **/
declare function FQuat(x?: number, y?: number, z?: number, w?: number): FQuat;

/** @noSelf @customName UE.FQuat **/
declare function FQuat(R: FRotator): FQuat;

/** @noSelf @customName UE.FQuat **/
declare function FQuat(Axis: FVector, AngleRad: number): FQuat;

/** @noSelf @customName UE.FQuat.Slearp **/
declare function Slerp(a: FQuat, b: FQuat, alpha: number): FQuat;

type FRotator = Rotator;
declare class Rotator {
  Pitch: number;
  Yaw: number;
  Roll: number;
  Set(Pitch: number, Yaw: number, Roll: number): void;
  GetRightVector(): FVector;
  GetUpVector(): FVector;
  GetUnitAxis(): number; // 0: x, 1: y, 2: z
  Normalize(): void;
  GetNormalized(): FVector;
  RotateVector(): FVector;
  UnrotateVector(): FVector;
  Clamp(): void;
  GetForwardVector(): FVector;
  ToVector(): FVector;
  ToEuler(): FVector;
  ToQuat(): FQuat;
  Inverse(): FRotator;
  Add: LuaAdditionMethod<FRotator, FRotator> & LuaAdditionMethod<number, FRotator>;
  Sub: LuaSubtractionMethod<FRotator, FRotator> & LuaSubtractionMethod<number, FRotator>;
  Mul: LuaMultiplicationMethod<FRotator, FRotator> & LuaMultiplicationMethod<number, FRotator>;
}

/** @noSelf @customName UE.FRotator **/
declare function FRotator(Pitch: number, Yaw: number, Roll: number): FRotator;

// UnLua\Private\MathLib\LuaLib_FTransform.cpp
type FTransform = Transform;
declare class Transform {
  Rotation: FQuat;
  Translation: FVector;
  Scale: FVector;
  Add: LuaAdditionMethod<FTransform, FTransform> & LuaAdditionMethod<number, FTransform>;
  Mul: LuaMultiplicationMethod<Transform, Transform> & LuaMultiplicationMethod<number, Transform>;
  Blend(): FTransform;
  BlendWith(): FTransform;
  Inverse(): FTransform;
  TransformPosition(a: FVector): FVector;
  TransformPositionNoScale(a: FVector): FVector;
  InverseTransformPosition(a: FVector): FVector;
  InverseTransformPositionNoScale(a: FVector): FVector;
  TransformVector(a: FVector): FVector;
  TransformVectorNoScale(): void;
  InverseTransformVector(): void;
  InverseTransformVectorNoScale(): void;
  TransformRotation(): void;
}

/** @noSelf @customName UE.FTransform **/
declare function FTransform(Rotation?: FQuat, Translation?: FVector, Scale?: FVector): FTransform;
