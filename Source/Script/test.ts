


// https://typescripttolua.github.io/docs/the-self-parameter
// https://typescripttolua.github.io/docs/advanced/writing-declarations
// https://typescripttolua.github.io/docs/advanced/language-extensions/#operator-map-types



// 예시 3: 클래스의 타입을 반환하는 경우
class MyClass {
    x: number | undefined;
    y: number | undefined;
}

// 팩토리 함수
/*
function Classes<T extends UObject>(ctor: { new(...args: any[]): T }): { new(...args: any[]): T } {
    return UnLua.Class(ctor.name) as { new(...args: any[]): T };
}




function Class2<T extends UObject>(): { new(...args: any[]): T } {
    //ctor: { new(...args: any[]): T }
    return UnLua.Class(T.name);
}
*/
//declare type LuaAdditionMethod<TRight, TReturn> = ((right: TRight) => TReturn) & LuaExtension<"AdditionMethod">;


class UUActor extends UnLua.Class<UActor>(UActor.name)
{
    UserConstructionScript() {
        super.GetName();
    }
}


function Test(): void {
    const ccc = UnLua.Class("Weapon.BP_ProjectileBase_C");
    const axis: FVector = FVector();
    const axis2: FVector = FVector(0.5);
    let axis3: FVector = FVector(0.5, 0.5, 0.7);
    axis3 = (axis * axis2 * 5.0) as FVector;



    /*
    axis.Add(axis3);
    axis.Add(5);
    axis.Mul(axis2);
    axis.Mul(5);
    axis.Div(2.0);
    axis.Sub(2.0);
    axis == axis2;
    */

    const test = new FLinearColor(0, 0, 0, 0);
    UEPrint("sdfsdf", 5, 23);
}

