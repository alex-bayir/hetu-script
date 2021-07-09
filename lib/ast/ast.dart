import '../lexer/token.dart';
import '../grammar/semantic.dart';
import '../source/source.dart';

part 'visitor/abstract_ast_visitor.dart';

abstract class AstNode {
  final String type;

  final HTSource? source;

  final int line;

  final int column;

  final int offset;

  final int length;

  int get end => offset + length;

  /// Visit this node
  dynamic accept(AbstractAstVisitor visitor);

  /// Visit all the sub nodes of this, doing nothing by default.
  void acceptAll(AbstractAstVisitor visitor) {}

  const AstNode(this.type,
      {this.source,
      this.line = 0,
      this.column = 0,
      this.offset = 0,
      this.length = 0});
}

// Has no meaning, a helper for parser to recover from errors.
class EmptyExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitEmptyExpr(this);

  const EmptyExpr(
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.empty,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class CommentExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitCommentExpr(this);

  final String content;

  final bool isMultiline;

  const CommentExpr(this.content,
      {this.isMultiline = false,
      HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.comment,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class NullExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitNullExpr(this);

  const NullExpr(
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.nullLiteral,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class BooleanExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitBooleanExpr(this);

  final bool value;

  const BooleanExpr(this.value,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.booleanLiteral,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ConstIntExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitConstIntExpr(this);

  final int value;

  const ConstIntExpr(this.value,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.integerLiteral,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ConstFloatExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitConstFloatExpr(this);

  final double value;

  const ConstFloatExpr(this.value,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.floatLiteral,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ConstStringExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitConstStringExpr(this);

  final String value;

  final String quotationLeft;

  final String quotationRight;

  const ConstStringExpr(this.value, this.quotationLeft, this.quotationRight,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.stringLiteral,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class StringInterpolationExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitStringInterpolationExpr(this);

  @override
  dynamic acceptAll(AbstractAstVisitor visitor) => null;

  final String value;

  final String quotationLeft;

  final String quotationRight;

  final List<AstNode> interpolation;

  const StringInterpolationExpr(
      this.value, this.quotationLeft, this.quotationRight, this.interpolation,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.stringInterpolation,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class SymbolExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitSymbolExpr(this);

  final String id;

  final bool isLocal;

  const SymbolExpr(this.id,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.isLocal = true})
      : super(SemanticNames.symbolExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);

  SymbolExpr.fromToken(Token id, {HTSource? source})
      : this(id.lexeme,
            source: source,
            line: id.line,
            column: id.column,
            offset: id.offset,
            length: id.length);
}

class ListExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitListExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    for (final item in list) {
      item.accept(visitor);
    }
  }

  final List<AstNode> list;

  const ListExpr(this.list,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.listLiteral,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class MapExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitMapExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    for (final key in map.keys) {
      key.accept(visitor);
      final value = map[key]!;
      value.accept(visitor);
    }
  }

  final Map<AstNode, AstNode> map;

  const MapExpr(this.map,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.mapLiteral,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class GroupExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitGroupExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    inner.accept(visitor);
  }

  final AstNode inner;

  const GroupExpr(this.inner,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.groupExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class TypeExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitTypeExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    id.accept(visitor);
    for (final item in arguments) {
      item.accept(visitor);
    }
  }

  final SymbolExpr id;

  final List<TypeExpr> arguments;

  final bool isNullable;

  final bool isLocal;

  const TypeExpr(this.id,
      {this.arguments = const [],
      this.isNullable = false,
      this.isLocal = true,
      HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.typeExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ParamTypeExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitParamTypeExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    id?.accept(visitor);
    declType.accept(visitor);
  }

  /// Wether this is an optional parameter.
  final bool isOptional;

  /// Wether this is a variadic parameter.
  final bool isVariadic;

  bool get isNamed => id != null;

  /// Wether this is a named parameter.
  final SymbolExpr? id;

  final TypeExpr declType;

  const ParamTypeExpr(this.declType,
      {this.id,
      required this.isOptional,
      required this.isVariadic,
      HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.paramTypeExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class FuncTypeExpr extends TypeExpr {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitFunctionTypeExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    for (final item in genericTypeParameters) {
      item.accept(visitor);
    }
    for (final item in paramTypes) {
      item.accept(visitor);
    }
    returnType.accept(visitor);
  }

  final SymbolExpr keyword;

  final List<GenericTypeParameterExpr> genericTypeParameters;

  final List<ParamTypeExpr> paramTypes;

  final TypeExpr returnType;

  final bool hasOptionalParam;

  final bool hasNamedParam;

  const FuncTypeExpr(this.keyword, this.returnType,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      bool isLocal = true,
      this.genericTypeParameters = const [],
      this.paramTypes = const [],
      required this.hasOptionalParam,
      required this.hasNamedParam})
      : super(keyword,
            isLocal: isLocal,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class GenericTypeParameterExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitGenericTypeParamExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    id.accept(visitor);
    superType?.accept(visitor);
  }

  final SymbolExpr id;

  final TypeExpr? superType;

  const GenericTypeParameterExpr(this.id,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.superType})
      : super(SemanticNames.genericTypeParamExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class UnaryPrefixExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitUnaryPrefixExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    value.accept(visitor);
  }

  final String op;

  final AstNode value;

  const UnaryPrefixExpr(this.op, this.value,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.unaryExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class UnaryPostfixExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitUnaryPostfixExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    value.accept(visitor);
  }

  final AstNode value;

  final String op;

  const UnaryPostfixExpr(this.value, this.op,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.unaryExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class BinaryExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitBinaryExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    left.accept(visitor);
    right.accept(visitor);
  }

  final AstNode left;

  final String op;

  final AstNode right;

  const BinaryExpr(this.left, this.op, this.right,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.binaryExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class TernaryExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitTernaryExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    condition.accept(visitor);
    thenBranch.accept(visitor);
    elseBranch.accept(visitor);
  }

  final AstNode condition;

  final AstNode thenBranch;

  final AstNode elseBranch;

  const TernaryExpr(this.condition, this.thenBranch, this.elseBranch,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.binaryExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class MemberExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitMemberExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    object.accept(visitor);
    key.accept(visitor);
  }

  final AstNode object;

  final SymbolExpr key;

  const MemberExpr(this.object, this.key,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.memberGetExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class MemberAssignExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitMemberAssignExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    object.accept(visitor);
    key.accept(visitor);
    value.accept(visitor);
  }

  final AstNode object;

  final SymbolExpr key;

  final AstNode value;

  const MemberAssignExpr(this.object, this.key, this.value,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.memberSetExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

// class MemberCallExpr extends AstNode {
//   @override
//   dynamic accept(AbstractAstVisitor visitor) =>
//       visitor.visitMemberCallExpr(this);

//   final AstNode collection;

//   final String key;

//   const MemberCallExpr(this.collection, this.key, int line, int column, int offset, int length, {HTSource? source})
//       : super(SemanticType.memberGetExpr, source: source, line: line, column: column, offset: offset, length: length);
// }

class SubExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitSubExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    array.accept(visitor);
    key.accept(visitor);
  }

  final AstNode array;

  final AstNode key;

  const SubExpr(this.array, this.key,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.subGetExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class SubAssignExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitSubAssignExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    array.accept(visitor);
    key.accept(visitor);
    value.accept(visitor);
  }

  final AstNode array;

  final AstNode key;

  final AstNode value;

  const SubAssignExpr(this.array, this.key, this.value,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.subSetExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

// class SubCallExpr extends AstNode {
//   @override
//   dynamic accept(AbstractAstVisitor visitor) => visitor.visitSubCallExpr(this);

//   final AstNode collection;

//   final AstNode key;

//   const SubCallExpr(this.collection, this.key, int line, int column, int offset, int length, {HTSource? source})
//       : super(SemanticType.subGetExpr, source: source, line: line, column: column, offset: offset, length: length);
// }

class CallExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitCallExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    callee.accept(visitor);
    for (final posArg in positionalArgs) {
      posArg.accept(visitor);
    }
    for (final namedArg in namedArgs.values) {
      namedArg.accept(visitor);
    }
  }

  final AstNode callee;

  final List<AstNode> positionalArgs;

  final Map<String, AstNode> namedArgs;

  const CallExpr(this.callee, this.positionalArgs, this.namedArgs,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.callExpr,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ExprStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitExprStmt(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    expr.accept(visitor);
  }

  final AstNode expr;

  final bool hasEndOfStmtMark;

  const ExprStmt(this.expr,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.hasEndOfStmtMark = false})
      : super(SemanticNames.exprStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class BlockStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitBlockStmt(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    for (final stmt in statements) {
      stmt.accept(visitor);
    }
  }

  final List<AstNode> statements;

  final bool hasOwnNamespace;

  final String? id;

  const BlockStmt(this.statements,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.hasOwnNamespace = true,
      this.id})
      : super(SemanticNames.blockStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ReturnStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitReturnStmt(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    value?.accept(visitor);
  }

  final Token keyword;

  final AstNode? value;

  final bool hasEndOfStmtMark;

  const ReturnStmt(this.keyword, this.value,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.hasEndOfStmtMark = false})
      : super(SemanticNames.returnStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class IfStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitIfStmt(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    condition.accept(visitor);
    thenBranch.accept(visitor);
    elseBranch?.accept(visitor);
  }

  final AstNode condition;

  final AstNode thenBranch;

  final AstNode? elseBranch;

  const IfStmt(this.condition, this.thenBranch, this.elseBranch,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.ifStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class WhileStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitWhileStmt(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    condition.accept(visitor);
    loop.accept(visitor);
  }

  final AstNode condition;

  final BlockStmt loop;

  const WhileStmt(this.condition, this.loop,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.whileStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class DoStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitDoStmt(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    loop.accept(visitor);
    condition?.accept(visitor);
  }

  final BlockStmt loop;

  final AstNode? condition;

  const DoStmt(this.loop, this.condition,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.doStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ForStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitForStmt(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    declaration?.accept(visitor);
    condition?.accept(visitor);
    increment?.accept(visitor);
    loop.accept(visitor);
  }

  final VarDecl? declaration;

  final AstNode? condition;

  final AstNode? increment;

  final bool hasBracket;

  final BlockStmt loop;

  const ForStmt(this.declaration, this.condition, this.increment, this.loop,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.hasBracket = false})
      : super(SemanticNames.forStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ForInStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitForInStmt(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    declaration.accept(visitor);
    collection.accept(visitor);
    loop.accept(visitor);
  }

  final VarDecl declaration;

  final AstNode collection;

  final bool hasBracket;

  final BlockStmt loop;

  const ForInStmt(this.declaration, this.collection, this.loop,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.hasBracket = false})
      : super(SemanticNames.forInStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class WhenStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitWhenStmt(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    condition?.accept(visitor);
    for (final caseExpr in cases.keys) {
      caseExpr.accept(visitor);
      final branch = cases[caseExpr]!;
      branch.accept(visitor);
    }
    elseBranch?.accept(visitor);
  }

  final AstNode? condition;

  final Map<AstNode, AstNode> cases;

  final AstNode? elseBranch;

  const WhenStmt(this.cases, this.elseBranch, this.condition,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.whenStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class BreakStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitBreakStmt(this);

  final Token keyword;

  final bool hasEndOfStmtMark;

  const BreakStmt(this.keyword,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.hasEndOfStmtMark = false})
      : super(SemanticNames.breakStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ContinueStmt extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitContinueStmt(this);

  final Token keyword;

  final bool hasEndOfStmtMark;

  const ContinueStmt(this.keyword,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.hasEndOfStmtMark = false})
      : super(SemanticNames.continueStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class LibraryDecl extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitLibraryDecl(this);

  final String id;

  const LibraryDecl(this.id,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.libraryStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ImportDecl extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitImportDecl(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    alias?.accept(visitor);
    for (final id in showList) {
      id.accept(visitor);
    }
  }

  final String key;

  final SymbolExpr? alias;

  final List<SymbolExpr> showList;

  /// The normalized absolute path of the imported module.
  /// It is left as null when parsing because at this time we don't know yet.
  String? fullName;

  final bool hasEndOfStmtMark;

  ImportDecl(this.key,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.alias,
      this.showList = const [],
      this.hasEndOfStmtMark = false})
      : super(SemanticNames.importStmt,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class NamespaceDecl extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitNamespaceDecl(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    id.accept(visitor);
    definition.accept(visitor);
  }

  final SymbolExpr id;

  final String? classId;

  final BlockStmt definition;

  final bool isPrivate;

  final bool isTopLevel;

  final bool isExported;

  bool get isMember => classId != null;

  const NamespaceDecl(this.id, this.definition,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.classId,
      this.isPrivate = false,
      this.isTopLevel = false,
      this.isExported = false})
      : super(SemanticNames.namespaceDeclaration,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class TypeAliasDecl extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitTypeAliasDecl(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    id.accept(visitor);
    for (final param in genericTypeParameters) {
      param.accept(visitor);
    }
    value.accept(visitor);
  }

  final SymbolExpr id;

  final String? classId;

  final List<GenericTypeParameterExpr> genericTypeParameters;

  final TypeExpr value;

  final bool hasEndOfStmtMark;

  bool get isMember => classId != null;

  final bool isPrivate;

  final bool isTopLevel;

  final bool isExported;

  const TypeAliasDecl(this.id, this.value,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.classId,
      this.genericTypeParameters = const [],
      this.hasEndOfStmtMark = false,
      this.isPrivate = false,
      this.isTopLevel = false,
      this.isExported = false})
      : super(SemanticNames.typeAliasDeclaration,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class VarDecl extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitVarDecl(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    id.accept(visitor);
    declType?.accept(visitor);
    initializer?.accept(visitor);
  }

  final SymbolExpr id;

  final String internalName;

  final String? classId;

  final TypeExpr? declType;

  final AstNode? initializer;

  final bool hasEndOfStmtMark;

  // final bool typeInferrence;

  bool get isMember => classId != null;

  final bool isExternal;

  final bool isStatic;

  final bool isMutable;

  final bool isConst;

  final bool isPrivate;

  final bool isTopLevel;

  final bool isExported;

  final bool lateInitialize;

  const VarDecl(this.id, this.internalName,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.classId,
      this.declType,
      this.initializer,
      this.hasEndOfStmtMark = false,
      // this.typeInferrence = false,
      this.isExternal = false,
      this.isStatic = false,
      this.isConst = false,
      this.isMutable = false,
      this.isPrivate = false,
      this.isTopLevel = false,
      this.isExported = false,
      this.lateInitialize = false})
      : super(SemanticNames.variableDeclaration,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ParamDecl extends VarDecl {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitParamDecl(this);

  final bool isVariadic;

  final bool isOptional;

  final bool isNamed;

  const ParamDecl(SymbolExpr id,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      TypeExpr? declType,
      AstNode? initializer,
      bool isConst = false,
      bool isMutable = false,
      this.isVariadic = false,
      this.isOptional = false,
      this.isNamed = false})
      : super(id,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length,
            declType: declType,
            initializer: initializer,
            isConst: isConst,
            isMutable: isMutable);
}

class ReferConstructCallExpr extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) =>
      visitor.visitReferConstructCallExpr(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    callee.accept(visitor);
    key?.accept(visitor);
    for (final posArg in positionalArgs) {
      posArg.accept(visitor);
    }
    for (final namedArg in namedArgs.values) {
      namedArg.accept(visitor);
    }
  }

  final SymbolExpr callee;

  final SymbolExpr? key;

  final List<AstNode> positionalArgs;

  final Map<String, AstNode> namedArgs;

  const ReferConstructCallExpr(
      this.callee, this.key, this.positionalArgs, this.namedArgs,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0})
      : super(SemanticNames.referConstructorExpression,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class FuncDecl extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitFuncDecl(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    id?.accept(visitor);
    for (final param in genericTypeParameters) {
      param.accept(visitor);
    }
    returnType?.accept(visitor);
    referConstructor?.accept(visitor);
    for (final param in paramDecls) {
      param.accept(visitor);
    }
    definition?.accept(visitor);
  }

  final String internalName;

  final SymbolExpr? id;

  final String? classId;

  final List<GenericTypeParameterExpr> genericTypeParameters;

  final String? externalTypeId;

  final TypeExpr? returnType;

  final ReferConstructCallExpr? referConstructor;

  final bool hasParamDecls;

  final List<ParamDecl> paramDecls;

  final int minArity;

  final int maxArity;

  final bool isExpressionBody;

  final bool hasEndOfStmtMark;

  final AstNode? definition;

  bool get isMember => classId != null;

  bool get isAbstract => definition != null;

  final bool isExternal;

  final bool isStatic;

  final bool isConst;

  final bool isVariadic;

  final bool isPrivate;

  final bool isTopLevel;

  final bool isExported;

  final FunctionCategory category;

  bool get isLiteral => category == FunctionCategory.literal;

  const FuncDecl(this.internalName, this.paramDecls,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.id,
      this.classId,
      this.genericTypeParameters = const [],
      this.externalTypeId,
      this.returnType,
      this.referConstructor,
      this.hasParamDecls = true,
      this.minArity = 0,
      this.maxArity = 0,
      this.isExpressionBody = false,
      this.hasEndOfStmtMark = false,
      this.definition,
      this.isExternal = false,
      this.isStatic = false,
      this.isConst = false,
      this.isVariadic = false,
      this.isPrivate = false,
      this.isTopLevel = false,
      this.isExported = false,
      this.category = FunctionCategory.normal})
      : super(SemanticNames.functionDeclaration,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class ClassDecl extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitClassDecl(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    id.accept(visitor);
    for (final param in genericTypeParameters) {
      param.accept(visitor);
    }
    superType?.accept(visitor);
    for (final implementsType in implementsTypes) {
      implementsType.accept(visitor);
    }
    for (final withType in withTypes) {
      withType.accept(visitor);
    }
    definition.accept(visitor);
  }

  final SymbolExpr id;

  final String? classId;

  final List<GenericTypeParameterExpr> genericTypeParameters;

  final TypeExpr? superType;

  final List<TypeExpr> implementsTypes;

  final List<TypeExpr> withTypes;

  bool get isMember => classId != null;

  bool get isNested => classId != null;

  final bool isExternal;

  final bool isAbstract;

  final bool isPrivate;

  final bool isTopLevel;

  final bool isExported;

  final bool hasUserDefinedConstructor;

  final BlockStmt definition;

  const ClassDecl(this.id, this.definition,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.classId,
      this.genericTypeParameters = const [],
      this.superType,
      this.implementsTypes = const [],
      this.withTypes = const [],
      this.isExternal = false,
      this.isAbstract = false,
      this.isPrivate = false,
      this.isExported = true,
      this.isTopLevel = false,
      this.hasUserDefinedConstructor = false})
      : super(SemanticNames.classDeclaration,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class EnumDecl extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitEnumDecl(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    id.accept(visitor);
    for (final enumItem in enumerations) {
      enumItem.accept(visitor);
    }
  }

  final SymbolExpr id;

  final String? classId;

  final List<SymbolExpr> enumerations;

  bool get isMember => classId != null;

  final bool isExternal;

  final bool isPrivate;

  final bool isTopLevel;

  final bool isExported;

  const EnumDecl(
    this.id,
    this.enumerations, {
    HTSource? source,
    int line = 0,
    int column = 0,
    int offset = 0,
    int length = 0,
    this.classId,
    this.isExternal = false,
    this.isPrivate = false,
    this.isTopLevel = false,
    this.isExported = true,
  }) : super(SemanticNames.enumDeclaration,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}

class StructDecl extends AstNode {
  @override
  dynamic accept(AbstractAstVisitor visitor) => visitor.visitStructDecl(this);

  @override
  void acceptAll(AbstractAstVisitor visitor) {
    id.accept(visitor);
    for (final field in fields) {
      field.accept(visitor);
    }
  }

  final SymbolExpr id;

  final String? classId;

  final String? prototypeId;

  final List<VarDecl> fields;

  final bool isPrivate;

  final bool isTopLevel;

  final bool isExported;

  bool get isMember => classId != null;

  StructDecl(this.id, this.fields,
      {HTSource? source,
      int line = 0,
      int column = 0,
      int offset = 0,
      int length = 0,
      this.classId,
      this.prototypeId,
      this.isPrivate = false,
      this.isTopLevel = false,
      this.isExported = false})
      : super(SemanticNames.structDeclaration,
            source: source,
            line: line,
            column: column,
            offset: offset,
            length: length);
}
