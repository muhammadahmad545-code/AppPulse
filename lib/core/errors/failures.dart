import 'package:equatable/equatable.dart';

/// Base failure type for domain / presentation error handling.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.cause});
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.cause});
}

final class PlatformFailure extends Failure {
  const PlatformFailure(super.message, {super.cause});
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause});
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.cause});
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause});
}
