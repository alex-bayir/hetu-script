import 'lexicon.dart';
import 'namespace.dart';
import 'function.dart';
import 'errors.dart';
import 'type.dart';
import 'interpreter.dart';
import 'variable.dart';
import 'declaration.dart';
import 'instance.dart';
import 'enum.dart';
import 'object.dart';

abstract class HTInheritable {
  String get id;

  HTInheritable? get superClass;

  HTType? get superClassType;
}

/// [HTClass] is the Dart implementation of the class declaration in Hetu.
/// [static] members in Hetu class are stored within a _namespace of [HTClassNamespace].
/// instance members of this class created by [createInstance] are stored in [instanceMembers].
class HTClass with HTInheritable, HTDeclaration, HTObject, InterpreterRef {
  @override
  String toString() => '${HTLexicon.CLASS} $id';

  var _instanceIndex = 0;
  int get instanceIndex => _instanceIndex++;

  final String moduleFullName;

  @override
  final HTType rtType = HTType.CLASS;

  /// The [HTNamespace] for this class,
  /// for searching for static variables.
  late final HTClassNamespace namespace;

  final bool isExtern;
  final bool isAbstract;

  /// The type parameters of the class.
  final List<String> typeParameters;

  /// Super class of this class.
  /// If a class is not extends from any super class, then it is extended of class `Object`
  @override
  final HTClass? superClass;

  @override
  final HTType? superClassType;

  /// Implemented classes of this class.
  /// Implements only inherits methods declaration,
  /// and the child must re-define all implements methods,
  /// and the re-definition must be of the same function signature.
  final List<HTClass> implementedClass;

  /// Mixined class of this class.
  /// Those mixined class can not have any constructors.
  final List<HTClass> mixinedClass;

  /// The instance member variables defined in class definition.
  final instanceMembers = <String, HTDeclaration>{};
  // final Map<String, HTClass> instanceNestedClasses = {};

  /// Create a default [HTClass] instance.
  HTClass(String id, Interpreter interpreter, this.moduleFullName,
      HTNamespace closure,
      {this.superClass,
      this.superClassType,
      this.isExtern = false,
      this.isAbstract = false,
      this.typeParameters = const [],
      this.implementedClass = const [],
      this.mixinedClass = const []}) {
    this.id = classId = id;
    this.interpreter = interpreter;

    namespace = HTClassNamespace(id, id, interpreter, closure: closure);
  }

  /// Create a [HTInstance] of this [HTClass],
  /// will not call constructors
  HTInstance createInstance({List<HTType> typeArgs = const []}) {
    return HTInstance(this, interpreter, typeArgs: typeArgs);
  }

  HTInstance createInstanceFromJson(Map<dynamic, dynamic> jsonObject,
      {List<HTType> typeArgs = const []}) {
    return HTInstance(this, interpreter,
        typeArgs: typeArgs,
        jsonObject:
            jsonObject.map((key, value) => MapEntry(key.toString(), value)));
  }

  /// Wether there's a member in this [HTClass] by the [varName].
  @override
  bool contains(String varName) =>
      namespace.declarations.containsKey(varName) ||
      namespace.declarations.containsKey('${HTLexicon.getter}$varName') ||
      namespace.declarations.containsKey('$id.$varName');

  /// Get a value of a static member from this [HTClass].
  @override
  dynamic memberGet(String varName, {String from = HTLexicon.global}) {
    final getter = '${HTLexicon.getter}$varName';
    final constructor = '${HTLexicon.constructor}$varName';
    final externalName = '$id.$varName';

    if (namespace.declarations.containsKey(varName)) {
      if (varName.startsWith(HTLexicon.underscore) &&
          !from.startsWith(namespace.fullName)) {
        throw HTError.privateMember(varName);
      }
      final decl = namespace.declarations[varName]!;
      return HTDeclaration.fetch(decl, interpreter);
    } else if (namespace.declarations.containsKey(getter)) {
      if (varName.startsWith(HTLexicon.underscore) &&
          !from.startsWith(namespace.fullName)) {
        throw HTError.privateMember(varName);
      }
      final func = namespace.declarations[getter] as HTFunction;
      return func.call();
    } else if (namespace.declarations.containsKey(constructor)) {
      if (varName.startsWith(HTLexicon.underscore) &&
          !from.startsWith(namespace.fullName)) {
        throw HTError.privateMember(varName);
      }
      return namespace.declarations[constructor] as HTFunction;
    } else if (namespace.declarations.containsKey(externalName) && isExtern) {
      if (varName.startsWith(HTLexicon.underscore) &&
          !from.startsWith(namespace.fullName)) {
        throw HTError.privateMember(varName);
      }
      final decl = namespace.declarations[externalName]!;
      return HTDeclaration.fetch(decl, interpreter);
    }

    switch (varName) {
      case 'runtimeType':
        return rtType;
      case 'fromJson':
        return ({positionalArgs, namedArgs, typeArgs}) {
          return createInstanceFromJson(positionalArgs.first,
              typeArgs: typeArgs ?? const <HTType>[]);
        };
      default:
        throw HTError.undefined(varName);
    }
  }

  /// Assign a value to a static member of this [HTClass].
  @override
  void memberSet(String varName, dynamic varValue,
      {String from = HTLexicon.global}) {
    final setter = '${HTLexicon.setter}$varName';
    final externalName = '$id.$varName';

    if (namespace.declarations.containsKey(varName)) {
      if (varName.startsWith(HTLexicon.underscore) &&
          !from.startsWith(namespace.fullName)) {
        throw HTError.privateMember(varName);
      }
      final decl = namespace.declarations[varName]!;
      if (decl is HTVariable) {
        decl.assign(varValue);
        return;
      } else {
        throw HTError.immutable(varName);
      }
    } else if (namespace.declarations.containsKey(setter)) {
      if (varName.startsWith(HTLexicon.underscore) &&
          !from.startsWith(namespace.fullName)) {
        throw HTError.privateMember(varName);
      }
      final setterFunc = namespace.declarations[setter] as HTFunction;
      setterFunc.call(positionalArgs: [varValue]);
      return;
    } else if (namespace.declarations.containsKey(externalName) && isExtern) {
      final externClass = interpreter.fetchExternalClass(id);
      externClass.memberSet(externalName, varValue);
      return;
    }

    throw HTError.undefined(varName);
  }

  /// Call a static function of this [HTClass].
  dynamic invoke(String funcName,
      {List<dynamic> positionalArgs = const [],
      Map<String, dynamic> namedArgs = const {},
      List<HTType> typeArgs = const [],
      bool errorHandled = true}) {
    try {
      final func = memberGet(funcName, from: namespace.fullName);

      if (func is HTFunction) {
        return func.call(
            positionalArgs: positionalArgs,
            namedArgs: namedArgs,
            typeArgs: typeArgs);
      } else {
        throw HTError.notCallable(funcName);
      }
    } catch (error, stack) {
      if (errorHandled) {
        rethrow;
      } else {
        interpreter.handleError(error, stack);
      }
    }
  }

  /// Add a instance member declaration to this [HTClass].
  void defineInstanceMember(HTDeclaration decl,
      {bool override = false, bool error = true}) {
    if (decl is HTClass || decl is HTEnum) {
      throw HTError.classOnInstance();
    }
    if ((!instanceMembers.containsKey(decl.id)) || override) {
      instanceMembers[decl.id] = decl;
    } else {
      if (error) throw HTError.definedRuntime(decl.id);
    }
  }
}
