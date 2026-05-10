class CodeDebugRequest {
  final String code;
  final String language;
  final String mode;
  final String? instruction;

  CodeDebugRequest({
    required this.code,
    this.language = 'python',
    this.mode = 'debug',
    this.instruction,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'language': language,
        'mode': mode,
        if (instruction != null) 'instruction': instruction,
      };
}
