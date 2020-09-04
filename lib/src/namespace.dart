import 'package:hetu_script/hetu.dart';

import 'errors.dart';
import 'class.dart';
import 'common.dart';
import 'value.dart';

class HS_Namespace extends HS_Value {
  String get type => HS_Common.Namespace;

  String toString() => '${HS_Common.Namespace} $name';

  String _name;
  String get name => _name;
  String _fullName;
  String get fullName => _fullName;

  final Map<String, Field> defs = {};
  HS_Namespace _closure;
  HS_Namespace get closure => _closure;
  void set closure(HS_Namespace closure) {
    _closure = closure;
    _fullName = getFullName(_name, _closure);
  }

  static int spaceIndex = 0;

  static String getFullName(String name, HS_Namespace space) {
    var fullName = name;
    var cur_space = space.closure;
    while ((cur_space != null) && (cur_space.name != HS_Common.Global)) {
      fullName = cur_space.name + HS_Common.Dot + fullName;
      cur_space = cur_space.closure;
    }
    return fullName;
  }

  HS_Namespace(
      //int line, int column, String fileName,
      //this.fileName,
      {
    String name,
    String fullName,
    HS_Namespace closure,
  }) {
    _name = name == null ? '__namespace${spaceIndex++}' : name;
    _closure = closure;
    _fullName = fullName == null ? getFullName(_name, this) : fullName;
  }

  HS_Namespace closureAt(int distance) {
    var namespace = this;
    for (var i = 0; i < distance; i++) {
      namespace = namespace.closure;
    }

    return namespace;
  }

  bool contains(String varName) {
    if (defs.containsKey(varName)) return true;
    if (closure != null) return closure.contains(varName);
    return false;
  }

  // String lookUp(String varName) {
  //   String fullName = varName;
  //   var space = this;
  //   while (!space.contains(varName)) {
  //     space = space.closure;
  //     if (space == null) {
  //       return null;
  //     }
  //     fullName = space.name + HS_Common.Dot + fullName;
  //   }
  //   return fullName;
  // }

  /// 在当前命名空间声明一个变量名称
  // void declare(String varName, int line, int column, String fileName) {
  //   if (!defs.containsKey(varName)) {
  //     defs[varName] = null;
  //   } else {
  //     throw HSErr_Defined(varName, line, column, fileName);
  //   }
  // }

  /// 在当前命名空间定义一个变量的类型
  void define(String varName, String varType, int line, int column, Interpreter interpreter,
      {List<String> varTypeParams, dynamic value, bool mutable = true}) {
    var val_type = HS_TypeOf(value);
    var val_type_params = HS_TypeParamsOf(value);
    if ((varType == HS_Common.Any) || ((value != null) && (varType == val_type)) || (value == null)) {
      if (varTypeParams != null) {
        for (int i = 0; i < val_type_params.length; i++) {
          if (i < varTypeParams.length) {
            var param = val_type_params[i];
            var decl_param = varTypeParams[i];
            if ((decl_param != HS_Common.Any) && (decl_param != param)) {
              throw HSErr_TypeParam(param, decl_param, line, column, interpreter.curFileName);
            }
          } else {
            varTypeParams.add(HS_Common.Any);
          }
        }
      }
      defs[varName] = Field(varType, value: value, mutable: mutable, initialized: (value == null ? false : true));
    } else if ((value != null) && (value is Map)) {
      var klass = interpreter.global.fetch(varType, line, column, interpreter);
      if (klass is HS_Class) {
        var instance = klass.createInstance(interpreter, line, column, this);
        for (var key in value.keys) {
          instance.assign(key, value[key], line, column, interpreter);
        }
        defs[varName] = Field(varType, value: instance);
      } else {
        throw HSErr_Type(varName, varType, val_type, line, column, interpreter.curFileName);
      }
    } else {
      throw HSErr_Type(varName, varType, val_type, line, column, interpreter.curFileName);
    }
  }

  dynamic fetch(String varName, int line, int column, Interpreter interpreter,
      {bool nonExistError = true, String from = HS_Common.Global, bool recursive = true}) {
    if (defs.containsKey(varName)) {
      if (from.startsWith(this.fullName) || (name == HS_Common.Global) || !varName.startsWith(HS_Common.Underscore)) {
        return defs[varName].value;
      }
      throw HSErr_Private(varName, line, column, interpreter.curFileName);
    }

    if (recursive && (closure != null))
      return closure.fetch(varName, line, column, interpreter, nonExistError: nonExistError, from: from);

    if (nonExistError) throw HSErr_Undefined(varName, line, column, interpreter.curFileName);

    return null;
  }

  dynamic fetchAt(String varName, int distance, int line, int column, Interpreter interpreter,
      {bool nonExistError = true, String from = HS_Common.Global, bool recursive = true}) {
    var space = closureAt(distance);
    return space.fetch(varName, line, column, interpreter,
        nonExistError: nonExistError, from: space.fullName, recursive: false);
  }

  /// 向一个已经定义的变量赋值
  void assign(String varName, dynamic value, int line, int column, Interpreter interpreter,
      {bool nonExistError = true, String from = HS_Common.Global, bool recursive = true}) {
    if (defs.containsKey(varName)) {
      if (from.startsWith(this.fullName) || (!varName.startsWith(HS_Common.Underscore))) {
        var varType = defs[varName].type;
        if ((varType == HS_Common.Any) || ((value != null) && (varType == HS_TypeOf(value))) || (value == null)) {
          if (defs[varName].mutable) {
            defs[varName].value = value;
            return;
          }
          throw HSErr_Mutable(varName, line, column, interpreter.curFileName);
        }
        throw HSErr_Type(varName, HS_TypeOf(value), varType, line, column, interpreter.curFileName);
      }
      throw HSErr_Private(varName, line, column, interpreter.curFileName);
    } else if (recursive && (closure != null)) {
      closure.assign(varName, value, line, column, interpreter, from: from);
      return;
    }

    if (nonExistError) throw HSErr_Undefined(varName, line, column, interpreter.curFileName);
  }

  void assignAt(String varName, dynamic value, int distance, int line, int column, Interpreter interpreter,
      {String from = HS_Common.Global, bool recursive = true}) {
    var space = closureAt(distance);
    space.assign(varName, value, line, column, interpreter, from: space.fullName, recursive: false);
  }
}
