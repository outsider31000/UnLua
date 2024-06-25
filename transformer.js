// eslint-disable-next-line @typescript-eslint/no-var-requires, no-undef
const ts = require('typescript');
// eslint-disable-next-line @typescript-eslint/no-var-requires, no-undef, @typescript-eslint/no-unused-vars
const tstl = require('typescript-to-lua');

const plugin = {
  // visitors는 TypeScript 프로그램의 Abstract Syntax Tree(AST)를 처리하기 위해 내부적으로 사용되는 방문자 패턴을 구현합니다.
  // 방문자는 처리된 노드와 변환 컨텍스트를 받아서 Lua AST 노드를 반환하는 함수입니다.
  // 플러그인은 visitors 속성을 사용하여 기본 변환 동작을 재정의할 수 있습니다.
  visitors: {
    [ts.SyntaxKind.ReturnStatement]: () => {
      // eslint-disable-next-line no-undef
      console.log('Plugin ReturnStatement is running');
      tstl.createReturnStatement([tstl.createBooleanLiteral(true)]);
    },

    [ts.SyntaxKind.StringLiteral]: (node, context) => {
      // eslint-disable-next-line no-undef
      console.log('Plugin StringLiteral is running');
      // `context` exposes `superTransform*` methods, that can be used to call either the visitor provided by previous
      // plugin, or a standard TypeScriptToLua visitor
      const result = context.superTransformExpression(node);

      // Standard visitor for ts.StringLiteral always returns tstl.StringLiteral node
      if (tstl.isStringLiteral(result)) {
        result.value = 'bar';
      }

      return result;
    },

    [ts.SyntaxKind.MethodDeclaration]: (node, context) => {
      // eslint-disable-next-line no-undef
      console.log('Plugin MethodDeclaration is running');
      const result = context.superTransformNode(node);

      // eslint-disable-next-line @typescript-eslint/strict-boolean-expressions
      if (tstl.isMethodDeclaration(result)) {
        const newMethodName = tstl.createIdentifier(`:${result.name.text}`);
        result.name = newMethodName;
        // eslint-disable-next-line no-undef
        console.log(`Transformed method: ${result.name.text}`);
      }

      return result;
    },
    [ts.SyntaxKind.MethodDeclaration]: node => {
      // eslint-disable-next-line no-undef
      console.log('Plugin MethodDeclaration is running');
      // eslint-disable-next-line @typescript-eslint/strict-boolean-expressions
      const className = node.parent.name ? node.parent.name.getText() : 'UnknownClass';
      const methodName = node.name.getText();

      const newMethodName = ts.factory.createIdentifier(`:${methodName}`);
      const newMethod = ts.factory.updateMethodDeclaration(
        node,
        node.modifiers,
        node.asteriskToken,
        newMethodName,
        node.questionToken,
        node.typeParameters,
        node.parameters,
        node.type,
        node.body,
      );

      // eslint-disable-next-line no-undef
      console.log(`Transformed method: ${className}${newMethodName.text}`);

      return newMethod;
    },
  },

  // beforeTransform 함수는 TypeScript 프로그램과 컴파일러 옵션을 수집한 후 Lua로 변환하기 전에 호출됩니다.
  // 플러그인을 설정하는 데 사용할 수 있습니다.
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  beforeTransform(program, options, emitHost) {
    // eslint-disable-next-line no-undef
    console.log('Plugin beforeTransform is running');

    const visit = node => {
      if (ts.isMethodDeclaration(node)) {
        // eslint-disable-next-line @typescript-eslint/strict-boolean-expressions
        const className = node.parent.name ? node.parent.name.getText() : 'UnknownClass';
        const methodName = node.name.getText();

        const newMethodName = ts.factory.createIdentifier(`:${methodName}`);
        const newMethod = ts.factory.updateMethodDeclaration(
          node,
          node.modifiers,
          node.asteriskToken,
          newMethodName,
          node.questionToken,
          node.typeParameters,
          node.parameters,
          node.type,
          node.body,
        );

        // eslint-disable-next-line no-undef
        console.log(`Transformed method: ${className}${newMethodName.text}`);

        //         Transformed method: CharacterBase:Initialize
        // Transformed method: CharacterBase:ReceiveBeginPlay
        // Transformed method: CharacterBase:SpawnWeapon
        // Transformed method: CharacterBase:StartFire_Server_RPC
        // Transformed method: CharacterBase:StartFire_Multicast_RPC
        // Transformed method: CharacterBase:StopFire_Server_RPC
        // Transformed method: CharacterBase:StopFire_Multicast_RPC
        // Transformed method: CharacterBase:ReceiveAnyDamage
        // Transformed method: CharacterBase:Died_Multicast_RPC
        // Transformed method: CharacterBase:Destroy
        // Transformed method: CharacterBase:Initialize
        // Transformed method: CharacterBase:ReceiveBeginPlay
        // Transformed method: CharacterBase:SpawnWeapon
        // Transformed method: CharacterBase:StartFire_Server_RPC
        // Transformed method: CharacterBase:StartFire_Multicast_RPC
        // Transformed method: CharacterBase:StopFire_Server_RPC
        // Transformed method: CharacterBase:StopFire_Multicast_RPC
        // Transformed method: CharacterBase:ReceiveAnyDamage
        // Transformed method: CharacterBase:Died_Multicast_RPC
        // Transformed method: CharacterBase:Destroy

        return newMethod; // Return the updated method
      }
      return ts.visitEachChild(node, visit, ts.nullTransformationContext);
    };

    for (const sourceFile of program.getSourceFiles()) {
      // eslint-disable-next-line @typescript-eslint/strict-boolean-expressions
      if (!sourceFile.isDeclarationFile) {
        ts.visitNode(sourceFile, visit);
      }
    }
  },
  // printer는 Lua AST 프린터의 기본 구현을 재정의하는 함수입니다. 파일과 변환된 Lua AST에 대한 정보를 받아서 처리합니다.

  // afterPrint 함수는 TypeScript 프로그램을 Lua로 변환한 후, 종속성을 해결하고 번들링을 구성하기 전에 호출됩니다.
  // 생성된 Lua 파일의 리스트를 수정하거나 직접 문자열을 수정할 수 있습니다.
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  afterPrint(program, options, emitHost, result) {
    for (const file of result) {
      file.code = '-- Comment added by afterPrint plugin\n' + file.code;
    }
  },

  // beforeEmit 함수는 입력 프로그램이 Lua로 변환되고 외부 종속성이 해결된 후, 번들링을 구성한 후에 호출됩니다.
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  beforeEmit(program, options, emitHost, result) {
    for (const file of result) {
      file.code = '-- Comment added by beforeEmit plugin\n' + file.code;
    }
  },
  // afterEmit 함수는 모든 출력 파일이 디스크에 기록된 후에 호출됩니다. 출력 Lua를 후처리하는 데 유용할 수 있습니다.
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  afterEmit(program, options, emitHost, result) {
    for (const emittedFile of result) {
      // eslint-disable-next-line no-undef
      console.log(`Emitted file ${emittedFile.outputPath}`);
    }
  },
  // moduleResolution 함수는 tstl 모듈 해석 방식을 수정하는 데 사용할 수 있습니다.
  // 요구된 경로, 모듈을 요구한 파일, 프로젝트를 컴파일하는 데 사용된 tsconfig 옵션, tstl EmitHost를 제공합니다.
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  moduleResolution(moduleIdentifier, requiringFile, options, emitHost) {
    if (moduleIdentifier === 'foo') {
      return 'bar';
    }
  },
};

// eslint-disable-next-line no-undef
module.exports = plugin;
