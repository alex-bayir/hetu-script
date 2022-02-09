import 'dart:typed_data';

import '../value/namespace/namespace.dart';
import 'bytecode_reader.dart';
import '../constant/global_constant_table.dart';

class HTBytecodeModule with BytecodeReader, HTGlobalConstantTable {
  final String id;

  final Map<String, HTNamespace> namespaces = {};

  final Map<String, dynamic> expressions = {};

  String readShortString() {
    final index = readUint16();
    return getGlobalConstant(String, index);
  }

  HTBytecodeModule({
    required this.id,
    required Uint8List bytes,
  }) {
    this.bytes = bytes;
  }
}
