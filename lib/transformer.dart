library dom_stub.transformer;

import 'dart:io';
import 'package:barback/barback.dart';
import 'dart:async';
import 'package:source_span/src/file.dart';
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:source_maps/refactor.dart';
import 'package:source_span/source_span.dart';

class DomStubTransformer extends Transformer {
  static final bool isDomStub = Platform.environment["DOM_STUB"] != null;
  final bool releaseMode;
  final List<String> _files;
  DomStubTransformer([List<String> files, bool releaseMode])
      : _files = files,
        releaseMode = releaseMode == true {}
  DomStubTransformer.asPlugin(BarbackSettings settings)
      : _files = _readFiles(settings.configuration['files']),
        releaseMode = settings.mode == BarbackMode.RELEASE {}

  static List<String> _readFiles(value) {
    if (value == null) return null;
    var files = [];
    bool error;
    if (value is List) {
      files = value;
      error = value.any((e) => e is! String);
    } else if (value is String) {
      files = [value];
      error = false;
    } else {
      error = true;
    }
    if (error) print('Invalid value for "files" in the observe transformer.');
    return files;
  }

// TODO(nweiz): This should just take an AssetId when barback <0.13.0 support
// is dropped.
  Future<bool> isPrimary(idOrAsset) {
    var id = idOrAsset is AssetId ? idOrAsset : idOrAsset.id;
    return new Future.value(isDomStub &&
        id.extension == '.dart' &&
        (_files == null || _files.contains(id.path)));
  }

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) {
      // Do a quick string check to determine if this is this file even
      // plausibly might need to be transformed. If not, we can avoid an
      // expensive parse.

      if (!jsHtmlMatcher.hasMatch(content)) return null;

      var id = transform.primaryInput.id;
      // TODO(sigmund): improve how we compute this url
      var url = id.path.startsWith('lib/')
          ? 'package:${id.package}/${id.path.substring(4)}'
          : id.path;
      var sourceFile = new SourceFile(content, url: url);

      var transaction = transformCompilationUnit(content, sourceFile, transform.logger);
      if (!transaction.hasEdits) {
        transform.addOutput(transform.primaryInput);
      } else {
        var printer = transaction.commit();
        // TODO(sigmund): emit source maps when barback supports it (see
        // dartbug.com/12340)
        printer.build(url);
        transform.addOutput(new Asset.fromString(id, printer.text));
      }
    });
  }

  TextEditTransaction transformCompilationUnit(
      String inputCode, SourceFile sourceFile, TransformLogger logger) {
    CompilationUnit unit = parseCompilationUnit(inputCode, suppressErrors: true);
    var code = new TextEditTransaction(inputCode, sourceFile);
    unit.directives.where((item)=>item is ImportDirective).forEach((ImportDirective directive){
      switch(directive.uri.stringValue){
        case 'dart:js':
        case 'dart:html':
          code.edit(directive.uri.offset,directive.uri.end, JS_STUB_PACKAGE);
          logger.info("Replace ${directive.uri} -> $JS_STUB_PACKAGE");

      }
    });
    return code;
  }
  static const String JS_STUB_PACKAGE = '"package:dom_stub/dom_stub.dart"';
}

final jsHtmlMatcher =
    new RegExp("import[ ]*('|\")(dart:js|dart:html)('|\")");
