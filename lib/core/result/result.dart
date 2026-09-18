/// Erreur applicative typée : chaque échec porte un message déjà adapté à
/// l'affichage (jamais une exception Postgres/HTTP brute montrée à Sandra).
class AppException implements Exception {
  final String message;
  final Object? cause;

  const AppException(this.message, [this.cause]);

  @override
  String toString() => message;
}

/// Résultat d'une opération pouvant échouer, sans lever d'exception.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) ok,
    required R Function(AppException error) err,
  }) => switch (this) {
    Ok<T>(:final value) => ok(value),
    Err<T>(:final error) => err(error),
  };
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final AppException error;
  const Err(this.error);
}
