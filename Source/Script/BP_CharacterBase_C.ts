// https://typescripttolua.github.io/docs/the-self-parameter
// https://typescripttolua.github.io/docs/advanced/writing-declarations
// https://typescripttolua.github.io/docs/advanced/language-extensions/#operator-map-types

class BP_CharacterBase2_C extends UnLua.Class<ACharacter>() {
  Initialize(_Initializer: unknown[]): void {
    this.IsDead = false;
    this.BodyDuration = 3.0;
    this.BoneName = null;
    const Health = 100;
    this.Health = Health;
    this.MaxHealth = Health;

    print("Initialize!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
  }
  

  ReceiveBeginPlay(): void {
    this.Super.ReceiveBeginPlay();
    const Weapon = this.SpawnWeapon();
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
    if (this.Weapon != null) this.Weapon.StartFire();
  }

  StopFire_Server_RPC(): void {
    this.StopFire_Multicast();
  }

  StopFire_Multicast_RPC(): void {
    if (this.Weapon != null) this.Weapon.StopFire();
  }

  ReceiveAnyDamage(
    Damage: number,
    DamageType: unknown,
    _InstigatedBy: unknown,
    _DamageCauser: unknown,
  ): void {
    if (this.IsDead != false) {
      const Health = this.Health - Damage;
      this.Health = Math.max(Health, 0);
      if (Health <= 0.0) {
        this.Died_Multicast(DamageType);
        const co = coroutine.create(() => this.Destroy);
        coroutine.resume(co, this, this.BodyDuration);
      }
    }
  }

  Died_Multicast_RPC(_DamageType: unknown) {
    this.IsDead = true;
    this.CapsuleComponent.SetCollisionEnabled(false);
    this.StopFire();
    const Controller = this.GetController();
    if (Controller != null) Controller.UnPossess();
  }

  public Destroy(_Duration?: number | undefined): void {
    //UKismetSystemLibrary.Delay(this, Duration);
  }
}

export = BP_CharacterBase2_C;
