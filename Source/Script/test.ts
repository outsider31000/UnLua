// Declare exposed API


type Vector = [number, number, number];

declare function findUnitsInRadius(this: void, center: Vector, radius: number): Unit[];
declare interface Unit {
    isFriend(other: Unit): boolean;
    givePoints(pointsAmount: number): void;
}

// Use declared API in code
function onAbilityCast(this: void, caster: Unit, targetLocation: Vector) {
    const units = findUnitsInRadius(targetLocation, 500);
    const friends = units.filter(unit => caster.isFriend(unit));

    for (const friend of friends) {
        friend.givePoints(5500);
    }
}



// https://typescripttolua.github.io/docs/the-self-parameter
// https://typescripttolua.github.io/docs/advanced/writing-declarations
// https://typescripttolua.github.io/docs/advanced/language-extensions/#operator-map-types



class UUActor extends UObject {
    UserConstructionScript() {
        this.Super.Load("sdfsdf");


    }
}

function Test(): void {
    const ccc = UnLua.Class("Weapon.BP_ProjectileBase_C");
    const axis: FVector = new FVector();
    const axis2: FVector = new FVector(0.5);
    const axis3: FVector = new FVector(0.5, 0.5, 0.7);
    axis.Add(axis3);
    axis.Add(5);
    axis.Mul(axis2);
    axis.Mul(5);
    axis.Div(2.0);
    axis.Sub(2.0);
    axis == axis2;

    const test = new FLinearColor(0, 0, 0, 0);
    UEPrint("sdfsdf", 5, 23);
}

