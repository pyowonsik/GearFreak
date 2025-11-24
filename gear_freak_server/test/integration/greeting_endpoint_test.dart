import 'package:test/test.dart';

// Import the generated test helper file, it contains everything you need.
import 'test_tools/serverpod_test_tools.dart';

void main() {
  // This is an example test that uses the `withServerpod` test helper.
  // `withServerpod` enables you to call your endpoints directly from the test like regular functions.
  // Note that after adding or modifying an endpoint, you will need to run
  // `serverpod generate` to update the test tools code.
  // Refer to the docs for more information on how to use the test helper.
  withServerpod('Given Greeting endpoint', (sessionBuilder, endpoints) {});
}
