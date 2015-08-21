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
  final Map<String, String> imports;
  RegExp _importMatcher;
  static const String JS_STUB_PACKAGE = 'package:dom_stub/dom_stub.dart';

  DomStubTransformer([List<String> files, bool releaseMode, this.imports])
      : _files = files,
        releaseMode = releaseMode == true {
    _init();
  }
  DomStubTransformer.asPlugin(BarbackSettings settings)
      : _files = _readFiles(settings.configuration['files']),
        releaseMode = settings.mode == BarbackMode.RELEASE,
        imports = _readImports(settings.configuration['imports']) {
    _init();
  }

  _init() {
    imports['dart:js'] = JS_STUB_PACKAGE;
    imports['dart:html'] = JS_STUB_PACKAGE;
    StringBuffer sb = new StringBuffer();
    sb.write("import[ ]*('|\")(");
    sb.write(imports.keys.join('|'));
    sb.write(")('|\")");
    _importMatcher = new RegExp(sb.toString());
  }

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
    if (error) print('Invalid value for "files" in the dom_stub transformer.');
    return files;
  }

  static Map<String, String> _readImports(value) {
    if (value == null) return {};
    if (value is Map) {
      return value;
    } else {
      print('Invalid value for "imports" in the dom_stub transformer.');
    }
    return {};
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

      if (!_importMatcher.hasMatch(content)) return null;

      var id = transform.primaryInput.id;
      // TODO(sigmund): improve how we compute this url
      var url = id.path.startsWith('lib/')
          ? 'package:${id.package}/${id.path.substring(4)}'
          : id.path;
      var sourceFile = new SourceFile(content, url: url);

      var transaction =
          transformCompilationUnit(content, sourceFile, transform.logger);
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

  _replacePackageName(TextEditTransaction code, NamespaceDirective directive,
      TransformLogger logger, String newImport) {
    code.edit(directive.uri.offset+1, directive.uri.end-1, newImport);
    logger.info("Replace ${directive.uri} -> '$newImport'");
  }

  TextEditTransaction transformCompilationUnit(
      String inputCode, SourceFile sourceFile, TransformLogger logger) {
    CompilationUnit unit =
        parseCompilationUnit(inputCode, suppressErrors: true);
    var code = new TextEditTransaction(inputCode, sourceFile);
    unit.directives
        .where((item) => item is ImportDirective)
        .forEach((ImportDirective directive) {
      var v = imports[directive.uri.stringValue];
      if (v != null) {
        _replacePackageName(code, directive, logger, v);
      }
    });
    unit.directives
    .where((item) => item is ExportDirective)
    .forEach((ExportDirective directive) {
      var v = imports[directive.uri.stringValue];
      if (v != null) {
        _replacePackageName(code, directive, logger, v);
      }
    });
    return code;
  }
}
