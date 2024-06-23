// https://typescripttolua.github.io/docs/the-self-parameter
// https://typescripttolua.github.io/docs/advanced/writing-declarations
// https://typescripttolua.github.io/docs/advanced/language-extensions/#operator-map-types

class CharacterBase extends UnLua.Class<APawn>() {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  Initialize(_Initializer: unknown[]): void {
    this.IsDead = false;
    this.BodyDuration = 3.0;
    this.BoneName = null;
    const Health = 100;
    this.Health = Health;
    this.MaxHealth = Health;
    let position = FVector();
    position = (position * position) as FVector;
    print(position);
  }

  ReceiveBeginPlay(): void {
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
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    InstigatedBy: unknown,
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    DamageCauser: unknown,
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

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  Died_Multicast_RPC(DamageType: unknown) {
    this.IsDead = true;
    this.CapsuleComponent.SetCollisionEnabled(false);
    this.StopFire();
    const Controller = this.GetController();
    if (Controller != null) Controller.UnPossess();
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  public Destroy(Duration?: number | undefined): void {
    //UKismetSystemLibrary.Delay(this, Duration);
  }
}

export = CharacterBase;
