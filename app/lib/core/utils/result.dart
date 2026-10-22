import '../errors/error_type.dart';

/// Hasil operasi yang bisa gagal (network, validasi, aturan bisnis).
///
/// Memaksa pemanggil menangani dua kemungkinan lewat pattern matching,
/// sehingga error tidak lagi dilempar sebagai exception yang tidak tertangani.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Nilai bila [Success], null bila [Failure].
  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;

  /// Error bila [Failure], null bila [Success].
  ErrorType? get errorOrNull =>
      this is Failure<T> ? (this as Failure<T>).error : null;

  /// Ubah nilai di dalam [Success]; [Failure] diteruskan apa adanya.
  Result<R> map<R>(R Function(T value) fn) {
    return switch (this) {
      Success(:final value) => Success<R>(fn(value)),
      Failure(:final error) => Failure<R>(error),
    };
  }

  /// Tangani kedua kemungkinan tanpa memeriksa tipe secara manual.
  R when<R>({
    required R Function(T value) success,
    required R Function(ErrorType error) failure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      Failure(:final error) => failure(error),
    };
  }
}

/// Operasi berhasil dan membawa nilai.
class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

/// Operasi gagal dan membawa jenis error.
class Failure<T> extends Result<T> {
  final ErrorType error;

  const Failure(this.error);
}
