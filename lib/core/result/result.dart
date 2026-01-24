/// Result class for handling success and failure states
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(String message) = Failure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  });
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return success(data);
  }
}

class Failure<T> extends Result<T> {
  final String message;

  const Failure(this.message);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    return failure(message);
  }
}
