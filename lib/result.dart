
import 'package:flutter/services.dart';

abstract class Result<T> {
  const Result._(); // private constructor

  factory Result.success(T value) = Success<T>;
  factory Result.failure(PlatformException error) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get value => isSuccess ? (this as Success<T>).value : null;
  PlatformException? get error => isFailure ? (this as Failure<T>).error : null;

  void onSuccess(void Function(T) action) {
    if (isSuccess) {
      action((this as Success<T>).value);
    }
  }

  void onFailure(void Function(PlatformException) action) {
    if (isFailure) {
      action((this as Failure<T>).error);
    }
  }
}

class Success<T> extends Result<T> {
  @override
  T value;

  Success(this.value) : super._();
}

class Failure<T> extends Result<T> {
  @override
  final PlatformException error;

  Failure(this.error) : super._();
}