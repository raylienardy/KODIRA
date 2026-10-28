import 'package:flutter_test/flutter_test.dart';
import 'package:kodira/data/repositories/code_runner_repository.dart';
import 'package:kodira/data/sources/remote/code_runner_source.dart';
import 'package:kodira/data/sources/remote/ai_source.dart';

void main() {
  group('CodeRunnerRepository', () {
    late _FakeCodeRunnerSource source;
    late CodeRunnerRepository repository;

    setUp(() {
      source = _FakeCodeRunnerSource();
      repository = CodeRunnerRepository(source);
    });

    test('runCode mengembalikan CodeRunResult saat berhasil', () async {
      source.result = const CodeRunResult(
        stdout: 'Halo KODIRA\n',
        stderr: '',
        compileOutput: '',
        message: '',
        status: 'Accepted',
        time: '0.02',
      );

      final result = await repository.runCode(
        sourceCode: 'print("test")',
        language: 'cpp',
      );

      expect(result.isSuccess, isTrue);
      expect(result.stdout, 'Halo KODIRA\n');
      expect(result.displayOutput, 'Halo KODIRA\n');
      expect(source.lastSourceCode, 'print("test")');
      expect(source.lastLanguage, 'cpp');
    });

    test('runCode meneruskan exception dari source', () async {
      source.error = AiException(500, 'Server down');

      expect(
        () => repository.runCode(sourceCode: 'code', language: 'cpp'),
        throwsA(isA<AiException>()),
      );
    });

    test(
      'CodeRunResult priority displayOutput: compileOutput > stderr > stdout',
      () {
        const r1 = CodeRunResult(
          stdout: 'out',
          stderr: 'err',
          compileOutput: 'comp',
          message: 'msg',
          status: 'Error',
          time: '0.1',
        );
        expect(r1.displayOutput, 'comp');

        const r2 = CodeRunResult(
          stdout: 'out',
          stderr: 'err',
          compileOutput: '',
          message: 'msg',
          status: 'Error',
          time: '0.1',
        );
        expect(r2.displayOutput, 'err');

        const r3 = CodeRunResult(
          stdout: 'out',
          stderr: '',
          compileOutput: '',
          message: 'msg',
          status: 'Accepted',
          time: '0.1',
        );
        expect(r3.displayOutput, 'out');
      },
    );

    test('PII Check: hanya mengirim sourceCode, language, dan stdin', () async {
      source.result = const CodeRunResult(
        stdout: 'ok',
        stderr: '',
        compileOutput: '',
        message: '',
        status: 'Accepted',
        time: '0.01',
      );

      await repository.runCode(
        sourceCode: 'my secret code',
        language: 'java',
        stdin: 'some input',
      );

      expect(source.lastSourceCode, 'my secret code');
      expect(source.lastLanguage, 'java');
      expect(source.lastStdin, 'some input');
      // Verifikasi tidak ada field tambahan yang aneh jika ini adalah real HTTP call,
      // namun di sini repository hanya memanggil method .run dengan 3 parameter tersebut.
    });
  });
}

class _FakeCodeRunnerSource implements CodeRunnerSource {
  CodeRunResult? result;
  Object? error;

  String? lastSourceCode;
  String? lastLanguage;
  String? lastStdin;

  @override
  Future<CodeRunResult> run({
    required String sourceCode,
    required String language,
    String? stdin,
  }) async {
    lastSourceCode = sourceCode;
    lastLanguage = language;
    lastStdin = stdin;

    if (error != null) throw error!;
    return result!;
  }
}
