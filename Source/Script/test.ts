


// https://typescripttolua.github.io/docs/the-self-parameter
// https://typescripttolua.github.io/docs/advanced/writing-declarations
// https://typescripttolua.github.io/docs/advanced/language-extensions/#operator-map-types



export class CharacterBase extends UnLua.Class<APawn>()
{
    Initialize(Initializer: any[]): void {
        this.IsDead = false;
        this.BodyDuration = 3.0;
        this.BoneName = null;
        let Health = 100;
        this.Health = Health;
        this.MaxHealth = Health;
    }

    ReceiveBeginPlay(): void {
        let Weapon = this.SpawnWeapon();
        if (Weapon != null) {
            Weapon.K2_AttachToComponent(this.WeaponPoint);
            this.Weapon = Weapon;
        }

    }
    SpawnWeapon(): Weapon | null {
        return null;
    }

    StartFire_Server_RPC(): void {
        this.StartFire_Multicast();
    }

    StartFire_Multicast_RPC(): void {
        if (this.Weapon != null)
            this.Weapon.StartFire();
    }

    StopFire_Server_RPC(): void {
        this.StopFire_Multicast();
    }

    StopFire_Multicast_RPC(): void {
        if (this.Weapon != null)
            this.Weapon.StopFire();
    }

    ReceiveAnyDamage(Damage: number, DamageType: any, InstigatedBy: any, DamageCauser: any): void {
        if (this.IsDead != false) {
            let Health = this.Health - Damage;
            this.Health = Math.max(Health, 0);
            if (Health <= 0.0) {
                this.Died_Multicast(DamageType);

            }
        }
    }

    Died_Multicast_RPC(DamageType: any) {
        this.IsDead = true;
        this.CapsuleComponent.SetCollisionEnabled(false);
        this.StopFire();
        let Controller = this.GetController();
        if (Controller != null)
            Controller.UnPossess();
    }

    public Destroy(Duration?: number | undefined): void {
        UKismetSystemLibrary.Delay(this, Duration);
    }
}



