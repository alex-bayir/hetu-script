import 'common.dart';
import 'namespace.dart';
import 'type.dart';
import 'declaration.dart';
import 'object.dart';
import 'class.dart';

/// [HTFunction] is the base class of functions in Hetu.
///
/// Extends this class to call functions in ast or bytecode modules.
abstract class HTFunction with HTDeclaration, HTObject {
  static final callStack = <String>[];

  final String declId;
  final String moduleUniqueKey;
  final HTClass? klass;

  final FunctionType funcType;

  final ExternalFunctionType externalFunctionType;

  final String? externalTypedef;

  @override
  late final HTFunctionTypeId typeid;

  HTTypeId get returnType => typeid.returnType;

  final List<HTTypeId> typeParams; // function<T1, T2>

  final bool isStatic;

  final bool isConst;

  final bool isVariadic;

  bool get isMethod => classId != null;

  final int minArity;
  final int maxArity;

  HTNamespace? context;

  HTFunction(String id, this.declId, this.moduleUniqueKey,
      {this.klass,
      this.funcType = FunctionType.normal,
      this.externalFunctionType = ExternalFunctionType.none,
      this.externalTypedef,
      this.typeParams = const [],
      this.isStatic = false,
      this.isConst = false,
      this.isVariadic = false,
      this.minArity = 0,
      this.maxArity = 0,
      HTNamespace? context}) {
    this.id = id;
    classId = klass?.id;
    this.context = context;
  }

  dynamic call(
      {List<dynamic> positionalArgs = const [],
      Map<String, dynamic> namedArgs = const {},
      List<HTTypeId> typeArgs = const [],
      bool errorHandled = true});

  /// Sub-classes of [HTFunction] must has a definition of [clone].
  @override
  HTFunction clone();
}
