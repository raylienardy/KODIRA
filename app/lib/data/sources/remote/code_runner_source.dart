import 'package:supabase_flutter/supabase_flutter.dart';

import 'ai_source.dart' show AiException;

/// Sumber data remote untuk mengeksekusi kode melalui Edge Function `code-runner`.
class CodeRunnerSource {
  final SupabaseClient _client;

  CodeRunnerSource(this._client);

  /// Eksekusi kode ke Judge0 melalui Edge Function `code-runner`.
  Future<CodeRunResult> run({
    required String sourceCode,
    required String language,
    String? stdin,
  }) async {
    if (sourceCode.trim().isEmpty) {
      throw AiException(400, 'Kode tidak boleh kosong.');
    }

    final response = await _client.functions.invoke(
      'code-runner',
      body: {
        'sourceCode': sourceCode,
        'language': language,
        if (stdin != null && stdin.isNotEmpty) 'stdin': stdin,
      },
    );

    if (response.status != 200) {
      final data = response.data;
      final error = data is Map ? data['error'] : null;
      throw AiException(
        response.status,
        error is String && error.isNotEmpty ? error : 'Gagal menjalankan kode.',
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw AiException(response.status, 'Format respons tidak valid.');
    }

    final dynamic rawTime = data['time'];
    final String timeStr = rawTime == null ? '' : rawTime.toString();

    return CodeRunResult(
      stdout: (data['stdout'] as String?) ?? '',
      stderr: (data['stderr'] as String?) ?? '',
      compileOutput: (data['compile_output'] as String?) ?? '',
      message: (data['message'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'Unknown',
      time: timeStr,
    );
  }
}

/// Representasi hasil eksekusi kode dari Judge0.
class CodeRunResult {
  final String stdout;
  final String stderr;
  final String compileOutput;
  final String message;
  final String status;
  final String time;

  const CodeRunResult({
    required this.stdout,
    required this.stderr,
    required this.compileOutput,
    required this.message,
    required this.status,
    required this.time,
  });

  /// `true` jika kode berhasil dikompilasi dan dijalankan tanpa error run-time.
  bool get isSuccess => status == 'Accepted';

  /// `true` jika terdapat pesan kesalahan kompilasi atau run-time error.
  bool get hasError => compileOutput.isNotEmpty || stderr.isNotEmpty;

  /// Teks yang diprioritaskan untuk ditampilkan di panel output.
  /// Urutan prioritas: compileOutput > stderr > stdout > message > fallback.
  String get displayOutput {
    if (compileOutput.isNotEmpty) return compileOutput;
    if (stderr.isNotEmpty) return stderr;
    if (stdout.isNotEmpty) return stdout;
    if (message.isNotEmpty) return message;
    return '(tidak ada output)';
  }
}
