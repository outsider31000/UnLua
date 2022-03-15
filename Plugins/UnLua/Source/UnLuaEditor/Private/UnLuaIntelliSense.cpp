﻿// Tencent is pleased to support the open source community by making UnLua available.
// 
// Copyright (C) 2019 THL A29 Limited, a Tencent company. All rights reserved.
//
// Licensed under the MIT License (the "License"); 
// you may not use this file except in compliance with the License. You may obtain a copy of the License at
//
// http://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, 
// software distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
// See the License for the specific language governing permissions and limitations under the License.

#include "UnLuaIntelliSense.h"

#include "ObjectEditorUtils.h"
#include "UnLuaInterface.h"
#include "UObject/MetaData.h"

static const FName NAME_ToolTip(TEXT("ToolTip")); // key of ToolTip meta data
static const FName NAME_LatentInfo = TEXT("LatentInfo"); // tag of latent function

static FString GetCommentBlock(const UField* Field)
{
    const FString ToolTip = Field->GetMetaData(NAME_ToolTip);
    if (ToolTip.IsEmpty())
        return "";
    return "---" + UnLua::IntelliSense::EscapeComments(ToolTip, false) + "\r\n";
}


FString UnLua::IntelliSense::Get(const UBlueprint* Blueprint)
{
    return Get(Blueprint->GeneratedClass);
}

FString UnLua::IntelliSense::Get(const UField* Field)
{
    const UStruct* Struct = Cast<UStruct>(Field);
    if (Struct)
        return Get(Struct);

    const UEnum* Enum = Cast<UEnum>(Field);
    if (Enum)
        return Get(Enum);

    return "";
}

FString UnLua::IntelliSense::Get(const UEnum* Enum)
{
    FString Ret = GetCommentBlock(Enum);

    FString TypeName = GetTypeName(Enum);
    Ret += FString::Printf(TEXT("---@class %s"), *TypeName);

    // fields
    const int32 Num = Enum->NumEnums();
    for (int32 i = 0; i < Num; ++i)
    {
        Ret += FString::Printf(TEXT("\r\n---@field %s %s %s"), TEXT("public"), *Enum->GetNameStringByIndex(i), TEXT("integer"));
    }

    // declaration
    Ret += FString::Printf(TEXT("\r\nlocal %s = {}\r\n\r\n"), *TypeName);

    // export to UE namespace
    if (Enum->IsNative())
        Ret += FString::Printf(TEXT("UE.%s = %s\r\n"), *TypeName, *TypeName);

    Ret += "\r\n";

    return Ret;
}

FString UnLua::IntelliSense::Get(const UStruct* Struct)
{
    const UClass* Class = Cast<UClass>(Struct);
    if (Class)
        return Get(Class);

    const UScriptStruct* ScriptStruct = Cast<UScriptStruct>(Struct);
    if (ScriptStruct)
        return Get(ScriptStruct);

    const UFunction* Function = Cast<UFunction>(Struct);
    if (Function)
        return Get(Function);

    return "";
}

FString UnLua::IntelliSense::Get(const UScriptStruct* ScriptStruct)
{
    FString Ret = GetCommentBlock(ScriptStruct);

    FString TypeName = GetTypeName(ScriptStruct);
    Ret += "---@class " + TypeName;
    UStruct* SuperStruct = ScriptStruct->GetSuperStruct();
    if (SuperStruct)
        Ret += " : " + GetTypeName(SuperStruct);
    Ret += "\r\n";

    // fields
    for (TFieldIterator<FProperty> It(ScriptStruct, EFieldIteratorFlags::ExcludeSuper, EFieldIteratorFlags::ExcludeDeprecated); It; ++It)
    {
        const FProperty* Property = *It;
        Ret += Get(Property) += "\r\n";
    }

    // declaration
    Ret += FString::Printf(TEXT("local %s = {}\r\n"), *TypeName);

    // export to UE namespace
    if (ScriptStruct->IsNative())
        Ret += FString::Printf(TEXT("UE.%s = %s\r\n"), *TypeName, *TypeName);

    Ret += "\r\n";

    return Ret;
}

FString UnLua::IntelliSense::Get(const UClass* Class)
{
    FString Ret = GetCommentBlock(Class);

    const FString TypeName = GetTypeName(Class);
    Ret += "---@class " + TypeName;
    UStruct* SuperStruct = Class->GetSuperStruct();
    if (SuperStruct)
        Ret += " : " + GetTypeName(SuperStruct);
    Ret += "\r\n";

    // fields
    for (TFieldIterator<FProperty> It(Class, EFieldIteratorFlags::ExcludeSuper, EFieldIteratorFlags::ExcludeDeprecated); It; ++It)
    {
        const FProperty* Property = *It;
        Ret += Get(Property) += "\r\n";
    }

    // declaration
    Ret += FString::Printf(TEXT("local %s = {}\r\n\r\n"), *TypeName);

    // functions
    for (TFieldIterator<UFunction> FunctionIt(Class, EFieldIteratorFlags::ExcludeSuper, EFieldIteratorFlags::ExcludeDeprecated, EFieldIteratorFlags::ExcludeInterfaces); FunctionIt; ++FunctionIt)
    {
        const UFunction* Function = *FunctionIt;
        if (!IsValid(Function))
            continue;
        if (FObjectEditorUtils::IsFunctionHiddenFromClass(Function, Class))
            continue;
        Ret += Get(Function) + "\r\n";
    }

    // export to UE namespace
    if (Class->IsNative())
        Ret += FString::Printf(TEXT("UE.%s = %s\r\n"), *TypeName, *TypeName);

    return Ret;
}

FString UnLua::IntelliSense::Get(const UFunction* Function)
{
    FString Ret = GetCommentBlock(Function);
    FString Properties;

    // black list of Lua key words
    static FString LuaKeyWords[] = {TEXT("local"), TEXT("function"), TEXT("end")};
    static constexpr int32 NumLuaKeyWords = sizeof(LuaKeyWords) / sizeof(FString);

    for (TFieldIterator<FProperty> It(Function); It && (It->PropertyFlags & CPF_Parm); ++It)
    {
        const FProperty* Property = *It;
        if (Property->GetFName() == NAME_LatentInfo)
            continue;

        FString TypeName = GetTypeName(Property);
        const FString& PropertyComment = Property->GetMetaData(NAME_ToolTip);
        FString ExtraDesc;

        if (Property->HasAnyPropertyFlags(CPF_ReturnParm))
        {
            Ret += FString::Printf(TEXT("---@return %s"), *TypeName); // return parameter
        }
        else
        {
            FString PropertyName = Property->GetName();
            for (int32 KeyWordIdx = 0; KeyWordIdx < NumLuaKeyWords; ++KeyWordIdx)
            {
                if (PropertyName.Equals(LuaKeyWords[KeyWordIdx], ESearchCase::CaseSensitive))
                {
                    PropertyName += TEXT("__"); // add suffix for Lua key words
                    break;
                }
            }

            if (Properties.IsEmpty())
                Properties = PropertyName;
            else
                Properties += FString::Printf(TEXT(", %s"), *PropertyName);

            FName KeyName = FName(*FString::Printf(TEXT("CPP_Default_%s"), *Property->GetName()));
            const FString& Value = Function->GetMetaData(KeyName);
            if (!Value.IsEmpty())
            {
                ExtraDesc = TEXT("[opt]"); // default parameter
            }
            else if (Property->HasAnyPropertyFlags(CPF_OutParm) && !Property->HasAnyPropertyFlags(CPF_ConstParm))
            {
                ExtraDesc = TEXT("[out]"); // non-const reference
            }
            Ret += FString::Printf(TEXT("---@param %s %s"), *PropertyName, *TypeName);
        }

        if (ExtraDesc.Len() > 0 || PropertyComment.Len() > 0)
        {
            Ret += TEXT(" @");
            if (ExtraDesc.Len() > 0)
                Ret += FString::Printf(TEXT("%s "), *ExtraDesc);
        }

        Ret += TEXT("\r\n");
    }

    const FString ClassName = GetTypeName(Function->GetOwnerClass());
    Ret += FString::Printf(TEXT("function %s%s%s(%s) end\r\n"), *ClassName, Function->HasAnyFunctionFlags(FUNC_Static) ? TEXT(".") : TEXT(":"), *Function->GetName(), *Properties);
    return Ret;
}

FString UnLua::IntelliSense::Get(const FProperty* Property)
{
    FString Ret;

    const UStruct* Struct = Property->GetOwnerStruct();

    // access level
    FString AccessLevel;
    if (Property->HasAnyPropertyFlags(CPF_NativeAccessSpecifierPublic))
        AccessLevel = TEXT("public");
    else if (Property->HasAllPropertyFlags(CPF_NativeAccessSpecifierProtected))
        AccessLevel = TEXT("protected");
    else if (Property->HasAllPropertyFlags(CPF_NativeAccessSpecifierPrivate))
        AccessLevel = TEXT("private");
    else
        AccessLevel = Struct->IsNative() ? "private" : "public";

    FString TypeName = IntelliSense::GetTypeName(Property);
    Ret += FString::Printf(TEXT("---@field %s %s %s"), *AccessLevel, *Property->GetName(), *TypeName);

    // comment
    const FString& ToolTip = Property->GetMetaData(NAME_ToolTip);
    if (!ToolTip.IsEmpty())
        Ret += " @" + EscapeComments(ToolTip, true);

    return Ret;
}

FString UnLua::IntelliSense::GetTypeName(const UObject* Field)
{
    if (!Field)
        return "";
    if (!Field->IsNative() && Field->GetName().EndsWith("_C"))
        return Field->GetName().LeftChop(2);
    const UStruct* Struct = Cast<UStruct>(Field);
    if (Struct)
        return Struct->GetPrefixCPP() + Struct->GetName();
    return Field->GetName();
}

FString UnLua::IntelliSense::GetTypeName(const FProperty* Property)
{
    if (!Property)
        return "Unknown";

    if (CastField<FByteProperty>(Property))
        return "integer";

    if (CastField<FInt8Property>(Property))
        return "integer";

    if (CastField<FInt16Property>(Property))
        return "integer";

    if (CastField<FIntProperty>(Property))
        return "integer";

    if (CastField<FInt64Property>(Property))
        return "integer";

    if (CastField<FUInt16Property>(Property))
        return "integer";

    if (CastField<FUInt32Property>(Property))
        return "integer";

    if (CastField<FUInt64Property>(Property))
        return "integer";

    if (CastField<FFloatProperty>(Property))
        return "number";

    if (CastField<FDoubleProperty>(Property))
        return "number";

    if (CastField<FEnumProperty>(Property))
        return ((FEnumProperty*)Property)->GetEnum()->GetName();

    if (CastField<FBoolProperty>(Property))
        return TEXT("boolean");

    if (CastField<FClassProperty>(Property))
    {
        const UClass* Class = ((FClassProperty*)Property)->MetaClass;
        return FString::Printf(TEXT("TSubclassOf<%s%s>"), Class->GetPrefixCPP(), *Class->GetName());
    }

    if (CastField<FSoftObjectProperty>(Property))
    {
        if (((FSoftObjectProperty*)Property)->PropertyClass->IsChildOf(UClass::StaticClass()))
        {
            const UClass* Class = ((FSoftClassProperty*)Property)->MetaClass;
            return FString::Printf(TEXT("TSoftClassPtr<%s%s>"), Class->GetPrefixCPP(), *Class->GetName());
        }
        const UClass* Class = ((FSoftObjectProperty*)Property)->PropertyClass;
        return FString::Printf(TEXT("TSoftObjectPtr<%s%s>"), Class->GetPrefixCPP(), *Class->GetName());
    }

    if (CastField<FObjectProperty>(Property))
    {
        const UClass* Class = ((FObjectProperty*)Property)->PropertyClass;
        return FString::Printf(TEXT("%s%s"), Class->GetPrefixCPP(), *Class->GetName());
    }

    if (CastField<FWeakObjectProperty>(Property))
    {
        const UClass* Class = ((FWeakObjectProperty*)Property)->PropertyClass;
        return FString::Printf(TEXT("TWeakObjectPtr<%s%s>"), Class->GetPrefixCPP(), *Class->GetName());
    }

    if (CastField<FLazyObjectProperty>(Property))
    {
        const UClass* Class = ((FLazyObjectProperty*)Property)->PropertyClass;
        return FString::Printf(TEXT("TLazyObjectPtr<%s%s>"), Class->GetPrefixCPP(), *Class->GetName());
    }

    if (CastField<FInterfaceProperty>(Property))
    {
        const UClass* Class = ((FInterfaceProperty*)Property)->InterfaceClass;
        return FString::Printf(TEXT("TScriptInterface<%s%s>"), Class->GetPrefixCPP(), *Class->GetName());
    }

    if (CastField<FNameProperty>(Property))
        return "string";

    if (CastField<FStrProperty>(Property))
        return "string";

    if (CastField<FTextProperty>(Property))
        return "string";

    if (CastField<FArrayProperty>(Property))
    {
        const FProperty* Inner = ((FArrayProperty*)Property)->Inner;
        return FString::Printf(TEXT("TArray<%s>"), *GetTypeName(Inner));
    }

    if (CastField<FMapProperty>(Property))
    {
        const FProperty* KeyProp = ((FMapProperty*)Property)->KeyProp;
        const FProperty* ValueProp = ((FMapProperty*)Property)->ValueProp;
        return FString::Printf(TEXT("TMap<%s, %s>"), *GetTypeName(KeyProp), *GetTypeName(ValueProp));
    }

    if (CastField<FSetProperty>(Property))
    {
        const FProperty* ElementProp = ((FSetProperty*)Property)->ElementProp;
        return FString::Printf(TEXT("TSet<%s>"), *GetTypeName(ElementProp));
    }

    if (CastField<FStructProperty>(Property))
        return ((FStructProperty*)Property)->Struct->GetStructCPPName();

    if (CastField<FDelegateProperty>(Property))
        return "Delegate";

    if (CastField<FMulticastDelegateProperty>(Property))
        return "MulticastDelegate";

    return "Unknown";
}

FString UnLua::IntelliSense::EscapeComments(const FString Comments, const bool bSingleLine)
{
    if (Comments.IsEmpty())
        return Comments;

    auto Filter = [](const FString Prefix, const FString Line)
    {
        if (Line.StartsWith("@"))
            return FString();
        return Prefix + Line;
    };

    TArray<FString> Lines;
    Comments.Replace(TEXT("@"), TEXT("@@")).ParseIntoArray(Lines, TEXT("\n"));

    FString Ret = Filter("", Lines[0]);
    if (bSingleLine)
    {
        for (int i = 1; i < Lines.Num(); i++)
            Ret += Filter(" ", Lines[i]);
    }
    else
    {
        for (int i = 1; i < Lines.Num(); i++)
            Ret += Filter("\r\n---", Lines[i]);
    }

    return Ret;
}

bool UnLua::IntelliSense::IsValid(const UFunction* Function)
{
    if (!Function)
        return false;

    if (Function->HasAnyFunctionFlags(FUNC_UbergraphFunction))
        return false;

    if (!UEdGraphSchema_K2::CanUserKismetCallFunction(Function))
        return false;

    const FString Name = Function->GetName();
    if (Name.Len() == 0)
        return false;

    if (Name.Contains(" "))
        return false;

    return true;
}
