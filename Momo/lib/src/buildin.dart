import 'dart:io';
import 'dart:math';

import 'package:hetu_script/src/environment.dart';
import 'package:hetu_script/src/class.dart';
import 'package:hetu_script/src/interpreter.dart';
import 'package:hetu_script/src/value.dart';

abstract class HT_Buildin {
  static const coreLib = 'class Object {}\n'
      'class Function {}\n';

  static Map<String, HT_External> functions = {
    'typeof': _typeof,
    'help': _help,
    'print': _print,
    'string': _string,
    'System.invoke': _system_invoke,
    'System.now': _system_now,
    'Console.write': _console_write,
    'Console.writeln': _console_writeln,
    'Console.getln': _console_getln,
    'Console.eraseLine': _console_erase_line,
    'Console.setTitle': _console_set_title,
    'Console.cls': _console_cls,
    'Value.toString': HSVal_Value._to_string,
    'num.parse': HSVal_Number._parse,
    'num.toStringAsFixed': HSVal_Number._to_string_as_fixed,
    'num.truncate': HSVal_Number._truncate,
    'String.__get__isEmpty': HSVal_String._is_empty,
    'String.parse': HSVal_String._parse,
    'String.substring': HSVal_String._substring,
    'List.__get__length': HSVal_List._get_length,
    'List.add': HSVal_List._add,
    'List.clear': HSVal_List._clear,
    'List.removeAt': HSVal_List._remove_at,
    'List.indexOf': HSVal_List._index_of,
    'List.elementAt': HSVal_List._element_at,
    'Map.__get__length': HSVal_Map._get_length,
    'Map.__get__keys': HSVal_Map._get_keys,
    'Map.__get__values': HSVal_Map._get_values,
    'Map.containsKey': HSVal_Map._contains_key,
    'Map.containsValue': HSVal_Map._contains_value,
    'Map.setVal': HSVal_Map._set_val,
    'Map.addAll': HSVal_Map._add_all,
    'Map.clear': HSVal_Map._clear,
    'Map.remove': HSVal_Map._remove,
    'Map.getVal': HSVal_Map._get_val,
    'Map.putIfAbsent': HSVal_Map._put_if_absent,
    'random': _math_random,
    'randomInt': _math_random_int,
    'sqrt': _math_sqrt,
    'log': _math_log,
    'sin': _math_sin,
    'cos': _math_cos,
  };

  static dynamic _typeof(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      return HT_TypeOf(args.first).toString();
    }
  }

  static dynamic _help(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      var value = args.first;
      if (value is HT_Instance) {
        return value.typeid;
      } else {
        return HT_TypeOf(value);
      }
    }
  }

  static dynamic _print(HT_Instance instance, List<dynamic> args) {
    var sb = StringBuffer();
    for (var arg in args) {
      sb.write('$arg ');
    }
    print(sb.toString());
  }

  static dynamic _string(HT_Instance instance, List<dynamic> args) {
    var result = StringBuffer();
    for (var arg in args) {
      result.write(arg);
    }
    return result.toString();
  }

  static dynamic _system_invoke(HT_Instance instance, List<dynamic> args) {
    if (args.length >= 2) {
      var func_name = args[0];
      var className = args[1];
      var arguments = args[2];
      itp.invoke(func_name, classname: className, args: arguments);
    }
  }

  static dynamic _console_write(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) stdout.write(args.first);
  }

  static dynamic _console_writeln(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) stdout.writeln(args.first);
  }

  static dynamic _console_getln(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      stdout.write('${args.first.toString()}');
    } else {
      stdout.write('>');
    }
    var input = stdin.readLineSync();
    return input;
  }

  static dynamic _console_erase_line(HT_Instance instance, List<dynamic> args) {
    stdout.write('\x1B[1F\x1B[1G\x1B[1K');
  }

  static dynamic _console_set_title(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      var title = args.first.toString();
      stdout.write('\x1b]0;${title}\x07');
    }
  }

  static dynamic _console_cls(HT_Instance instance, List<dynamic> args) {
    stdout.write("\x1B[2J\x1B[0;0H");
  }

  static dynamic _math_random(HT_Instance instance, List<dynamic> args) {
    return Random().nextDouble();
  }

  static dynamic _math_random_int(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      int value = (args.first as num).truncate();
      return Random().nextInt(value);
    }
  }

  static dynamic _math_sqrt(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      num value = args.first;
      return sqrt(value);
    }
  }

  static dynamic _math_log(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      num value = args.first;
      return log(value);
    }
  }

  static dynamic _math_sin(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      num value = args.first;
      return sin(value);
    }
  }

  static dynamic _math_cos(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      num value = args.first;
      return cos(value);
    }
  }

  static dynamic _system_now(HT_Instance instance, List<dynamic> args) {
    return DateTime.now().millisecondsSinceEpoch;
  }
}

abstract class HSVal_Value extends HT_Instance {
  final dynamic value;

  HSVal_Value(this.value, String className, int line, int column, Interpreter interpreter)
      : super(interpreter.globals.fetch(
          className, line, column, interpreter,
          //from: globalInterpreter.curContext.spaceName
        ) //, line, column, fileName
            ) {}

  //dynamic get value => fetch('_val', null, null, globalInterpreter.curFileName, error: false, from: type);

  static dynamic _to_string(HT_Instance instance, List<dynamic> args) {
    if (instance != null) {
      //var value = instance.fetch('_val', null, null, globalInterpreter.curFileName, from: instance.type);
      return (instance as HSVal_Value).value.toString();
    }
  }
}

class HSVal_Number extends HSVal_Value {
  HSVal_Number(num value, int line, int column, Interpreter interpreter)
      : super(value, env.lexicon.number, line, column, interpreter);

  static dynamic _parse(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      return num.tryParse(args.first);
    }
  }

  static dynamic _to_string_as_fixed(HT_Instance instance, List<dynamic> args) {
    int fractionDigits = 0;
    if (args.isNotEmpty) {
      fractionDigits = args.first;
    }
    var numObj = (instance as HSVal_Number);
    num number = numObj?.value;
    return number.toStringAsFixed(fractionDigits);
  }

  static dynamic _truncate(HT_Instance instance, List<dynamic> args) {
    var numObj = (instance as HSVal_Number);
    num number = numObj?.value;
    return number.truncate();
  }
}

class HSVal_Boolean extends HSVal_Value {
  HSVal_Boolean(bool value, int line, int column, Interpreter interpreter)
      : super(value, env.lexicon.number, line, column, interpreter);
}

class HSVal_String extends HSVal_Value {
  HSVal_String(String value, int line, int column, Interpreter interpreter)
      : super(value, env.lexicon.string, line, column, interpreter);

  static dynamic _is_empty(HT_Instance instance, List<dynamic> args) {
    var strObj = (instance as HSVal_String);
    String str = strObj?.value;
    return str?.isEmpty;
  }

  static dynamic _substring(HT_Instance instance, List<dynamic> args) {
    var strObj = (instance as HSVal_String);
    String str = strObj?.value;
    if (args.isNotEmpty) {
      int startIndex = args[0];
      int endIndex;
      if (args.length >= 1) {
        endIndex = args[1];
      }
      return str?.substring(startIndex, endIndex);
    }
  }

  static dynamic _parse(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      return args.first.toString();
    }
  }
}

class HSVal_List extends HSVal_Value {
  String valueType;

  HSVal_List(List value, int line, int column, Interpreter interpreter, {this.valueType})
      : super(value, env.lexicon.list, line, column, interpreter) {
    valueType ??= env.lexicon.ANY;
  }

  static dynamic _get_length(HT_Instance instance, List<dynamic> args) {
    var listObj = (instance as HSVal_List);
    List list = listObj?.value;
    var result = list?.length;
    return result == null ? -1 : result;
  }

  static dynamic _add(HT_Instance instance, List<dynamic> args) {
    var listObj = (instance as HSVal_List);
    listObj?.value?.addAll(args);
  }

  static dynamic _clear(HT_Instance instance, List<dynamic> args) {
    var listObj = (instance as HSVal_List);
    List list = listObj?.value;
    list?.clear();
  }

  static dynamic _remove_at(HT_Instance instance, List<dynamic> args) {
    var listObj = (instance as HSVal_List);
    List list = listObj?.value;
    if (args.isNotEmpty) {
      list?.removeAt(args.first);
    }
  }

  static dynamic _index_of(HT_Instance instance, List<dynamic> args) {
    var listObj = (instance as HSVal_List);
    List list = listObj?.value;
    if (args.isNotEmpty) {
      return list?.indexOf(args.first);
    }
    return -1;
  }

  static dynamic _element_at(HT_Instance instance, List<dynamic> args) {
    var listObj = (instance as HSVal_List);
    List list = listObj?.value;
    try {
      if ((args.isNotEmpty) && (args.first is int)) {
        return list?.elementAt(args.first);
      }
    } catch (e) {
      if (e is RangeError) {
        // TODO: 打印错误信息到Errors
        return null;
      }
    }
    return null;
  }
}

class HSVal_Map extends HSVal_Value {
  String keyType;
  String valueType;

  HSVal_Map(Map value, int line, int column, Interpreter interpreter, {this.keyType, this.valueType})
      : super(value, env.lexicon.map, line, column, interpreter) {
    keyType ??= env.lexicon.ANY;
    valueType ??= env.lexicon.ANY;
  }

  static dynamic _get_length(HT_Instance instance, List<dynamic> args) {
    var mapObj = (instance as HSVal_Map);
    Map map = mapObj?.value;
    var result = map?.length;
    return result == null ? -1 : result;
  }

  static dynamic _get_keys(HT_Instance instance, List<dynamic> args) {
    var mapObj = (instance as HSVal_Map);
    Map map = mapObj?.value;
    var result = map?.keys?.toList();
    return result == null ? [] : result;
  }

  static dynamic _get_values(HT_Instance instance, List<dynamic> args) {
    var mapObj = (instance as HSVal_Map);
    Map map = mapObj?.value;
    var result = map?.values?.toList();
    return result == null ? [] : result;
  }

  static dynamic _contains_key(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      var mapObj = (instance as HSVal_Map);
      Map map = mapObj?.value;
      if (map != null) return map.containsKey(args.first);
    }
    return false;
  }

  static dynamic _contains_value(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      var mapObj = (instance as HSVal_Map);
      Map map = mapObj?.value;
      if (map != null) return map.containsValue(args.first);
    }
    return false;
  }

  static dynamic _set_val(HT_Instance instance, List<dynamic> args) {
    if ((args.isNotEmpty) && args.length >= 2) {
      var mapObj = (instance as HSVal_Map);
      Map map = mapObj?.value;
      var key = args[0];
      var value = args[1];
      if (map != null) {
        map[key] = value;
      }
    }
  }

  static dynamic _add_all(HT_Instance instance, List<dynamic> args) {
    if ((args.isNotEmpty) && (args.first is Map)) {
      var mapObj = (instance as HSVal_Map);
      Map map = mapObj?.value;
      map?.addAll(args.first);
    }
  }

  static dynamic _clear(HT_Instance instance, List<dynamic> args) {
    var mapObj = (instance as HSVal_Map);
    Map map = mapObj?.value;
    map?.clear();
  }

  static dynamic _remove(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      var mapObj = (instance as HSVal_Map);
      Map map = mapObj?.value;
      map.remove(args.first);
    }
  }

  static dynamic _get_val(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      var mapObj = (instance as HSVal_Map);
      Map map = mapObj?.value;
      var key = args[0];
      return map[key];
    }
  }

  static dynamic _put_if_absent(HT_Instance instance, List<dynamic> args) {
    if (args.isNotEmpty) {
      var mapObj = (instance as HSVal_Map);
      Map map = mapObj?.value;
      var key = args[0];
      var value = args[1];
      map.putIfAbsent(key, () => value);
    }
  }
}
