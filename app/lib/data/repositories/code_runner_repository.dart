import '../sources/remote/code_runner_source.dart';

/// Repository untuk mengelola eksekusi kode melalui Judge0.
class CodeRunnerRepository {
  final CodeRunnerSource _source;

  CodeRunnerRepository(this._source);

  /// Menjalankan kode pengguna pada Judge0 via backend Edge Function.
  /// Parameter yang dikirim dibatasi hanya [sourceCode], [language], dan opsional [stdin]
  /// untuk mencegah kebocoran data pribadi (PII).
  Future<CodeRunResult> runCode({
    required String sourceCode,
    required String language,
    String? stdin,
  }) async {
    return _source.run(
      sourceCode: sourceCode,
      language: language,
      stdin: stdin,
    );
  }
}
