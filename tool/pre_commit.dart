import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ignore_for_file: avoid_print
main(List<String> args) {
  _run(args).then((c) => exitCode = c);
}

Future<int> _run(List<String> args) async {
  try {
    // exclude delete diff
    final gitDiff = await Process.start('git', [
      'diff',
      '--cached',
      '--name-only',
      '--diff-filter=d',
    ]);

    final controller = StreamController<List<int>>();
    final pipe = gitDiff.stdout.pipe(controller);
    final dartFiles = [];

    await for (var x in controller.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (RegExp(r'\\*.dart+$').hasMatch(x)) {
        dartFiles.add(x);
      }
    }

    await pipe;

    if (dartFiles.isEmpty) {
      print('Skip because there is no change in the dart files.');
      return 0;
    }

    var result = await Process.run(
        'flutter', ['format', '--set-exit-if-changed', ...dartFiles]);
    print(result.stdout);
    if (result.exitCode != 0) {
      return result.exitCode;
    }

    // look at analysis_options.yaml
    result = await Process.run('flutter', ['analyze']);
    return result.exitCode;
  } catch (e) {
    print(e);
    return 1;
  }
}
