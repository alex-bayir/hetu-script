import 'package:hetu_script/hetu_script.dart';

void main() {
  final hetu = Hetu();

  hetu.init();

  hetu.eval(r'''
function main() {
  var l = [1,2,3,4,1,2,3.33,[12,4]];
  var c = l.toSet();
  var d = c.toList();
  print(d);

  var k = l.toMap((e)=>e,(e)=>'any').jsonify();
  
  print(k);
  
}

main()
''');
}
