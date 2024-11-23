
# UnLua

[![LOGO](./Docs/Images/UnLua.png)]()

[![license](https://img.shields.io/badge/license-MIT-blue)](https://github.com/Tencent/UnLua/blob/master/LICENSE.TXT)
[![release](https://img.shields.io/github/v/release/Tencent/UnLua)](https://github.com/Tencent/UnLua/releases)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/Tencent/UnLua/pulls)

## Overview
**UnLua** is a highly optimized **Lua scripting solution** for Unreal Engine (UE). It follows UE's programming paradigm, is feature-rich, and easy to learn, enabling UE developers to use it with zero learning curve.

---

## Using Lua in UE
* Directly access all `UCLASS`, `UPROPERTY`, `UFUNCTION`, `USTRUCT`, and `UENUM` without glue code.
* Replace implementations defined in Blueprints (Event / Function).
* Handle various event notifications (Replication / Animation / Input).

For more detailed functionality, check the [Feature List](Docs/CN/Features.md).

---

## Optimized Features
* **`UFUNCTION` Calls**: Includes persistent parameter caching, optimized parameter passing, and improved handling of non-const references and return values.
* **Access Container Classes**: (`TArray`, `TSet`, `TMap`), memory layout matches the engine, with no need for conversion between Lua tables and containers.
* **Efficient Struct Handling**: Creation, access, and garbage collection (GC).
* **Support for Custom Static Export**: Includes classes, member variables, member functions, global functions, and enums.

---

## Platform Support
* **Runtime Platforms**: Windows / Android / iOS / Linux / macOS
* **Engine Versions**: Unreal Engine 4.17.x - Unreal Engine 5.x

**Note**: Versions 4.17.x and 4.18.x require modifications to `Build.cs`.

---

## Quick Start
### Installation
1. Copy the `Plugins` directory to the root directory of your UE project.
2. Restart your UE project.

### Start Your UnLua Journey
**Note**: If you are new to UE, it is recommended to follow the more detailed [Quickstart Guide for UE Newbies](Docs/CN/Quickstart_For_UE_Newbie.md) to continue with the following steps.
1. Create and open a Blueprint. In the UnLua toolbar, select `Bind` (you can also hold `Alt` to automatically generate the path in step 2).
2. In the `GetModule` function of the interface, enter the Lua file path, e.g., `GameModes.BP_MyGameMode`.
3. Select `Create Lua Template File` in the UnLua toolbar.
4. Open `Content/Script/GameModes/BP_MyGameMode.lua` and write your code.

---

## More Examples
* [01_HelloWorld](Content/Script/Tutorials/01_HelloWorld.lua): A quick start example.
* [02_OverrideBlueprintEvents](Content/Script/Tutorials/02_OverrideBlueprintEvents.lua): Overriding Blueprint events (Overridden Functions).
* [03_BindInputs](Content/Script/Tutorials/03_BindInputs.lua): Input event binding.
* [04_DynamicBinding](Content/Script/Tutorials/04_DynamicBinding.lua): Dynamic binding.
* [05_BindDelegates](Content/Script/Tutorials/05_BindDelegates.lua): Binding, unbinding, and triggering delegates.
* [06_NativeContainers](Content/Script/Tutorials/06_NativeContainers.lua): Accessing native engine containers.
* [07_CallLatentFunction](Content/Script/Tutorials/07_CallLatentFunction.lua): Calling `Latent` functions in coroutines.
* [08_CppCallLua](Content/Script/Tutorials/08_CppCallLua.lua): Calling Lua from C++.
* [09_StaticExport](Content/Script/Tutorials/09_StaticExport.lua): Exporting custom types for use in Lua.
* [10_Replications](Content/Script/Tutorials/10_Replications.lua): Overriding network replication events.
* [11_ReleaseUMG](Content/Script/Tutorials/11_ReleaseUMG.lua): Releasing UMG-related objects.
* [12_CustomLoader](Content/Script/Tutorials/12_CustomLoader.lua): Custom loader.
* [13_AnimNotify](Content/Script/Tutorials/AN_FootStep.lua): Animation notifications.

---

## Best Practice Example

[Lyra with UnLua](https://github.com/xuyanghuang-tencent/LyraWithUnLua): A complete example project based on the official UE **Lyra Starter Game Package** (currently under development).

---

## Documentation

- **Common Docs**: [Settings Options](Docs/CN/Settings.md) | [Debugging](Docs/CN/Debugging.md) | [IntelliSense](Docs/CN/IntelliSense.md) | [Console Commands](Docs/CN/ConsoleCommand.md) | [FAQ](Docs/CN/FAQ.md)

### Detailed Documentation:
* [Programming Guide](Docs/CN/UnLua_Programming_Guide.md): Introduces UnLua's main features and programming paradigms.
* [Plugins and Modules](Docs/CN/Plugins_And_Modules.md): Describes the plugins in the `Plugins` directory and their included modules.
* [Feature List](Docs/CN/Features.md): A more detailed list of features.
* [Implementation Principles](Docs/CN/How_To_Implement_Overriding.md): Explains UnLua's two overriding mechanisms.
* [API](Docs/CN/API.md): Detailed UnLua API documentation.

---

## Technical Support
- **Official QQ Group**: 936285107
- **Recommended VSCode Plugin**: [Lua Booster](https://marketplace.visualstudio.com/items?itemName=operali.lua-booster)
