// eslint-disable-next-line @typescript-eslint/no-var-requires, no-undef
const ts = require('typescript');
// eslint-disable-next-line @typescript-eslint/no-var-requires, no-undef, @typescript-eslint/no-unused-vars
const tstl = require('typescript-to-lua');

const plugin = {
  visitors: {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    [ts.SyntaxKind.ClassDeclaration]: (node, context) => {
      // eslint-disable-next-line @typescript-eslint/strict-boolean-expressions
      const className = node.name ? node.name.getText() : 'UnknownClass';
      // eslint-disable-next-line no-undef
      console.log(`Visiting class: ${className}`);
      const updatedMembers = node.members.map(member => {
        // eslint-disable-next-line @typescript-eslint/strict-boolean-expressions
        if (ts.isMethodDeclaration(member) && member.name) {
          const methodName = member.name.getText();
          const newMethodName = ts.factory.createIdentifier(`${className}:${methodName}`);
          // eslint-disable-next-line no-undef
          console.log(`Transforming method: ${className}.${methodName} to ${newMethodName.text}`);

          return ts.factory.updateMethodDeclaration(
            member,
            member.modifiers,
            member.asteriskToken,
            newMethodName,
            member.questionToken,
            member.typeParameters,
            member.parameters,
            member.type,
            member.body,
          );
        }
        return member;
      });

      const updatedClass = ts.factory.updateClassDeclaration(
        node,
        node.modifiers,
        node.name,
        node.typeParameters,
        node.heritageClauses,
        updatedMembers,
      );

      return context.superTransformNode(updatedClass);
    },
  },

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  beforeEmit(program, options, emitHost, result) {
    const sourceFiles = program.getSourceFiles();
    const classMethodMap = new Map();

    sourceFiles.forEach(sourceFile => {
      ts.forEachChild(sourceFile, node => {
        if (ts.isClassDeclaration(node) && node.name) {
          const className = node.name.getText();
          // eslint-disable-next-line no-undef
          console.log(`Class: ${className}`);
          const methodNames = [];
          node.members.forEach(member => {
            // eslint-disable-next-line @typescript-eslint/strict-boolean-expressions
            if (ts.isMethodDeclaration(member) && member.name) {
              const methodName = member.name.getText();
              // eslint-disable-next-line no-undef
              console.log(`  Method: ${methodName}`);
              methodNames.push(methodName);
            }
          });
          classMethodMap.set(className, methodNames);
        }
      });
    });

    for (const file of result) {
      // eslint-disable-next-line no-undef
      console.log(`Processing file: ${file.fileName}`);
      classMethodMap.forEach((methodNames, className) => {
        methodNames.forEach(methodName => {
          const luaMethodName = `${className}:${methodName}`;
          const prototypePattern = new RegExp(
            `${className}\\.prototype\\["${className}:${methodName}"\\]\\s*=\\s*function\\(self(,\\s*[^)]*)?\\)`,
            'g',
          );
          // eslint-disable-next-line @typescript-eslint/no-unused-vars
          const functionPattern = (match, params) => {
            // Remove the 'self' parameter
            // eslint-disable-next-line @typescript-eslint/strict-boolean-expressions
            const newParams = params ? params.replace(/,\s*/, '') : '';
            return `function ${className}:${methodName}(${newParams})`;
          };
          const originalCode = file.code;
          file.code = file.code.replace(prototypePattern, functionPattern);
          if (originalCode !== file.code) {
            // eslint-disable-next-line no-undef
            console.log(
              `Transformed method: ${luaMethodName} to function ${className}:${methodName}`,
            );
          }
        });
      });
      // eslint-disable-next-line no-undef
      console.log(`Transformed code:\n${file.code}`);
    }
  },
};

// eslint-disable-next-line no-undef
module.exports = plugin;
