declare class APawn extends AActor {
  IsDead: boolean;
  BodyDuration: number;
  BoneName: string | null;
  Health: number;
  MaxHealth: number;
  Weapon: Weapon;
  Mesh: Mesh;

  WeaponPoint: FVector;

  CapsuleComponent: CapsuleComponent;

  StartFire_Server_RPC(): void; // unused
  StopFire_Server_RPC(): void; // unused

  StartFire_Multicast_RPC(): void; // unused
  StopFire_Multicast_RPC(): void; // unused

  Died_Multicast_RPC(DamageType: unknown): void; //  unused

  StartFire(): void;
  StopFire(): void;
  StartFire_Multicast(): void;
  StopFire_Multicast(): void;
  Died_Multicast(DamageType: unknown): void;

  ChangeToRagdoll(): void;

  SpawnWeapon(): Weapon | null;
  GetController(): Controller;
}
