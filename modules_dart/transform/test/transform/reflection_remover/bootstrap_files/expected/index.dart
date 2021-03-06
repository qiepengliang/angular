library angular2.test.transform.reflection_remover.reflection_remover_files;

// This file is intentionally formatted as a string to avoid having the
// automatic transformer prettify it.
//
// This file represents transformed user code. Because this code will be
// linked to output by a source map, we cannot change line numbers from the
// original code and we therefore add our generated code on the same line as
// those we are removing.

var code = """
library web_foo;

import 'package:angular2/bootstrap_static.dart';import 'index.template.dart' as ngStaticInit;

void main() async {
  var appRef = await bootstrapStatic(MyComponent, null, () { ngStaticInit.initReflector(); });
}
""";
