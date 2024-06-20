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
        friend.givePoints(50);
    }
}
