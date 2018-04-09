import 'main_test.dart' as mainTestSuite;
import 'dart:async';
Future main() async{
 return mainTestSuite.main();
}

//dart --pause-isolates-on-exit --enable-vm-service=8181 test/all.dart
//pub global run coverage:collect_coverage --uri=http://127.0.0.1:8181/ -o var/coverage.json --resume-isolates
//pub global run coverage:format_coverage --packages=.packages --in=var/coverage.json --lcov --out=var/lcov.info --report-on=lib
//pub global run coveralls var/lcov.info