// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signup_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

mixin _$SignupState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SignupState);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class $SignupStateCopyWith<$Res> {
  $SignupStateCopyWith(SignupState _, $Res Function(SignupState) __);
}

extension SignupStatePatterns on SignupState {
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(SignupResponse signupResponse)? success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _Success() when success != null:
        return success(_that.signupResponse);
      case _Error() when error != null:
        return error(_that.message);
      default:
        return orElse();
    }
  }

  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(SignupResponse signupResponse) success,
    required TResult Function(String message) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Loading():
        return loading();
      case _Success():
        return success(_that.signupResponse);
      case _Error():
        return error(_that.message);
      default:
        throw StateError('Unexpected subclass');
    }
  }
}

class _Initial implements SignupState {
  const _Initial();

  @override
  String toString() {
    return 'SignupState.initial()';
  }
}

class _Loading implements SignupState {
  const _Loading();

  @override
  String toString() {
    return 'SignupState.loading()';
  }
}

class _Success implements SignupState {
  const _Success(this.signupResponse);

  final SignupResponse signupResponse;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Success &&
            other.signupResponse == signupResponse);
  }

  @override
  int get hashCode => Object.hash(runtimeType, signupResponse);

  @override
  String toString() {
    return 'SignupState.success(signupResponse: $signupResponse)';
  }
}

class _Error implements SignupState {
  const _Error(this.message);

  final String message;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Error &&
            other.message == message);
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'SignupState.error(message: $message)';
  }
}
