import '../value/entity.dart';
import '../declaration/namespace/declaration_namespace.dart';

/// Type is basically a set of things.
/// It is used to check errors in code.
abstract class HTType with HTEntity {
  bool get isResolved => true;

  bool get isTop => false;

  bool get isBottom => false;

  HTType resolve(HTDeclarationNamespace namespace) => this;

  final String? id;

  const HTType([this.id]);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      other is HTType && hashCode == other.hashCode;

  /// Check wether value of this [HTType] can be assigned to other [HTType].
  bool isA(HTType? other) {
    if (other == null) return true;

    if (id != other.id) return false;

    return true;
  }

  /// Wether object of this [HTType] cannot be assigned to other [HTType]
  bool isNotA(HTType? other) => !isA(other);
}

class HTIntrinsicType extends HTType {
  @override
  final bool isTop;

  @override
  final bool isBottom;

  const HTIntrinsicType(super.id,
      {required this.isTop, required this.isBottom});

  /// A type is both `top` and `bottom`, only used on declaration for analysis.
  ///
  /// There's no runtime value that has `any` as its type.
  ///
  /// In analysis, you can do everything with it:
  ///
  /// 1, use any operator on it.
  ///
  /// 2, call it as a function.
  ///
  /// 3, get a member out of it.
  ///
  /// 4, get a subscript value out of it.
  ///
  /// Every type is assignable to type any (the meaning of `top`),
  /// and type any is assignable to every type (the meaning of `bottom`).
  ///
  /// With `any` we lose any protection that is normally given to us by static type system.
  ///
  /// Therefore, it should only be used as a last resort
  /// when we can’t use more specific types or `unknown`.
  const HTIntrinsicType.any(String id) : this(id, isTop: true, isBottom: true);

  /// A `top` type, basically a type-safe version of the type any.
  ///
  /// Every type is assignable to type unknown (the meaning of `top`).
  ///
  /// Type unknown cannot assign to other types except `any` & `unknown`.
  ///
  /// You cannot do anything with it, unless you do an explicit type assertion.
  const HTIntrinsicType.unknown(String id)
      : this(id, isTop: true, isBottom: false);

  /// A `bottom` type. A function whose return type is never cannot return.
  /// For example by throwing an error or looping forever.
  const HTIntrinsicType.never(String id)
      : this(id, isTop: false, isBottom: true);

  /// A `empty` type. A function whose return type is empty.
  /// It may contain return statement, but cannot return any value.
  /// And you cannot use the function call result in any operation.
  const HTIntrinsicType.vo1d(String id)
      : this(id, isTop: false, isBottom: true);

  /// A `zero` type. It's the type of runtime null value.
  /// You cannot get this type via expression or declaration.
  const HTIntrinsicType.nu11(String id)
      : this(id, isTop: false, isBottom: false);

  @override
  bool isA(HTType? other) {
    if (other == null) return true;

    if (other.isTop) return true;

    if (other.isBottom && isBottom) return true;

    if (id == other.id) return true;

    return false;
  }
}
