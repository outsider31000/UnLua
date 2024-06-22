

declare class APawn extends UActor {
    IsDead: boolean;
    BodyDuration: number;
    BoneName: string;
    Health: number;
    MaxHealth: number;
    Weapon: Weapon;
    Mesh: Mesh;

    StartFire_Server_RPC(): void;
    StopFire_Server_RPC(): void;

    StartFire_Multicast_RPC(): void;
    StopFire_Multicast_RPC(): void;

    Died_Multicast_RPC(DamageType: any): void;

    ChangeToRagdoll(): void;

    SpawnWeapon(): Weapon;
    GetController(): Controller;
}

