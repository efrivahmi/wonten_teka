import 'dart:io';

void main() {
  final dir = Directory('mobile/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    var content = file.readAsStringSync();
    if (content.contains('companyId') || content.contains('company_id')) {
      // Remove field declaration
      content = content.replaceAll(RegExp(r'^\s*final int\?? companyId;.*$', multiLine: true), '');
      
      // Remove from constructor
      content = content.replaceAll(RegExp(r'^\s*required this\.companyId,.*$', multiLine: true), '');
      content = content.replaceAll(RegExp(r'^\s*this\.companyId,.*$', multiLine: true), '');
      
      // Remove from json parsing
      content = content.replaceAll(RegExp(r'^\s*companyId:\s*json\[\'company_id\'\][^,]*?,.*$', multiLine: true), '');
      
      // Remove from toJson
      content = content.replaceAll(RegExp(r'^\s*\'company_id\':\s*companyId,.*$', multiLine: true), '');
      
      // Remove from props
      content = content.replaceAll(', companyId', '');
      content = content.replaceAll('companyId, ', '');

      file.writeAsStringSync(content);
    }
  }
  print('Done Dart cleaning');
}
