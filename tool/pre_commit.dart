import 'dart:io';

// ignore_for_file: avoid_print
main(List<String> args) {
  _run(args).then((c) => exitCode = c);
}

Future<int> _run(List<String> args) async {
  try {
    var result = await Process.run('flutter', ['format', 'lib/', 'tool/']);
    print(result.stdout);
    if (result.exitCode != 0) {
      return result.exitCode;
    }
    result = await Process.run('flutter', ['analyze']);
    return result.exitCode;
  } catch (e) {
    print(e);
    return 1;
  }
}
