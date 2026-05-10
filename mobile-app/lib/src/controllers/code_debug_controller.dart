import 'package:code_mentor_mobile/src/models/request/code_debug_request.dart';
import 'package:code_mentor_mobile/src/models/response/code_debug_result.dart';

import '../models/repository.dart';

class CodeDebugController {
  CodeDebugController._();

  static final CodeDebugController instance = CodeDebugController._();

  final AppRepository _repository = AppRepository();

  Future<CodeDebugResult> analyzeCode({
    required String code,
    String language = 'python',
    String mode = 'debug',
    String? instruction,
  }) {
    return _repository.debugCode(
      CodeDebugRequest(
        code: code,
        language: language,
        mode: mode,
        instruction: instruction,
      ),
    );
  }
}
