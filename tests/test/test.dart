import 'package:hetu_script/hetu_script.dart';

void main() {
  var hetu = Hetu();
  hetu.init();
  hetu.eval(r'''
      class Person {
        var _name
        construct (name) {
          _name = name
        }
        fun greeting {
          print('Hi, I\'m ', _name)
        }
      }
      final p = Person('jimmy')
      // Error!
      // print(p._name)
      p.greeting()
    ''', isScript: true);
}
