import 'dart:async';
import 'package:grinder/grinder.dart';
import '../test/secrets.dart' as secrets;

/// Starts the build system.
Future<Null> main(List<String> args) => grind(args);

/// Deletes all generated files and reset any saved state.
@Task('Delete the generated files')
void clean() {
  defaultClean();
  ['.dart_tool/build', 'doc/api', webDir.path].map(getDir).forEach(delete);
  new FileSet.fromDir(getDir('var'), pattern: '*.{info,json}')
      .files
      .forEach(delete);
}

/// Uploads the code coverage report.
@Task('Upload the code coverage')
void coverage() => Pub.run('coveralls', arguments: ['var/lcov.info']);

/// Builds the documentation.
@Task('Build the documentation')
void doc() {
  DartDoc.doc();
  run('mkdocs', arguments: ['build']);
}

/// Fixes the coding standards issues.
@Task('Fix the coding issues')
void fix() => DartFmt.format(existingSourceDirs);

/// Performs static analysis of source code.
@Task('Perform the static analysis')
void lint() => Analyzer.analyze(existingSourceDirs);

/// Runs all the test suites.
@DefaultTask('Run the tests')
Future<Null> test() async {
  var keys = await secrets.main();

  if (keys['secret'] == null) fail('FIREBASE_API_KEY environment variable not set.');
  if (keys['host'] == null) fail('FIREBASE_HOST environment variable not set.');
  await Future.wait([
    Dart.runAsync('test/all.dart',
        vmArgs: [
          '--enable-vm-service',
        '--pause-isolates-on-exit'
        ]),
    Pub.runAsync('coverage', script: 'collect_coverage', arguments: [
      '--out=var/coverage.json',
      '--resume-isolates',
      '--wait-paused'
    ])
  ]);

  var args = [
    '--in=var/coverage.json',
    '--lcov',
    '--out=var/lcov.info',
    '--packages=.packages',
    '--report-on=${libDir.path}'
  ];
  return Pub.runAsync('coverage', script: 'format_coverage', arguments: args);
}
