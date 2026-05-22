import 'dart:io';

String removeComments(String src) {
  final sb = StringBuffer();
  int i = 0;
  final length = src.length;

  bool inSingleLineComment = false;
  bool inBlockComment = false;
  bool inString = false;
  String stringDelim = '';
  bool inTriple = false;

  while (i < length) {
    if (inSingleLineComment) {
      if (src[i] == '\n') {
        inSingleLineComment = false;
        sb.write('\n');
        i++;
      } else {
        i++;
      }
      continue;
    }

    if (inBlockComment) {
      if (i + 1 < length && src[i] == '*' && src[i + 1] == '/') {
        inBlockComment = false;
        i += 2;
      } else {
        i++;
      }
      continue;
    }

    if (inString) {
      // handle escapes
      if (src[i] == r'\\') {
        // a backslash, copy it and next char if exists
        sb.write('\\');
        i++;
        if (i < length) {
          sb.write(src[i]);
          i++;
        }
        continue;
      }

      // check for string end
      if (inTriple) {
        if (i + 2 < length && src[i] == stringDelim && src[i + 1] == stringDelim && src[i + 2] == stringDelim) {
          sb.write(stringDelim * 3);
          i += 3;
          inString = false;
          inTriple = false;
          continue;
        } else {
          sb.write(src[i]);
          i++;
          continue;
        }
      } else {
        if (src[i] == stringDelim) {
          sb.write(src[i]);
          i++;
          inString = false;
          continue;
        } else {
          sb.write(src[i]);
          i++;
          continue;
        }
      }
    }

    // not in comment or string
    // detect start of string
    if (src[i] == "'" || src[i] == '"') {
      // detect triple quotes
      final delim = src[i];
      if (i + 2 < length && src[i + 1] == delim && src[i + 2] == delim) {
        inString = true;
        inTriple = true;
        stringDelim = delim;
        sb.write(delim * 3);
        i += 3;
        continue;
      } else {
        inString = true;
        inTriple = false;
        stringDelim = delim;
        sb.write(src[i]);
        i++;
        continue;
      }
    }

    // detect single-line comment
    if (i + 1 < length && src[i] == '/' && src[i + 1] == '/') {
      // but ignore if it's triple slash used for documentation? They should be removed too per request
      inSingleLineComment = true;
      i += 2;
      continue;
    }

    // detect block comment
    if (i + 1 < length && src[i] == '/' && src[i + 1] == '*') {
      inBlockComment = true;
      i += 2;
      continue;
    }

    // normal char
    sb.write(src[i]);
    i++;
  }

  return sb.toString();
}

void main() async {
  final libDir = Directory('lib');
  if (!await libDir.exists()) {
    print('lib/ directory not found. Run this from project root.');
    exit(1);
  }

  final dartFiles = <File>[];
  await for (var entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      dartFiles.add(entity);
    }
  }

  print('Found \\${dartFiles.length} Dart files under lib/. Processing...');

  for (var file in dartFiles) {
    final original = await file.readAsString();
    final cleaned = removeComments(original);
    if (cleaned != original) {
      final backupPath = file.path + '.bak';
      await File(backupPath).writeAsString(original);
      await file.writeAsString(cleaned);
      print('Cleaned: ' + file.path);
    } else {
      print('No comments: ' + file.path);
    }
  }

  print('Done. Backups saved with .bak extension next to originals.');
}
