// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RegisterState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(RegisterResponse data) data,
    required TResult Function(String msg) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(RegisterResponse data)? data,
    TResult? Function(String msg)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(RegisterResponse data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegisterStateInitial value) initial,
    required TResult Function(_RegisterStateLoading value) loading,
    required TResult Function(_RegisterStateData value) data,
    required TResult Function(_RegisterStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegisterStateInitial value)? initial,
    TResult? Function(_RegisterStateLoading value)? loading,
    TResult? Function(_RegisterStateData value)? data,
    TResult? Function(_RegisterStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegisterStateInitial value)? initial,
    TResult Function(_RegisterStateLoading value)? loading,
    TResult Function(_RegisterStateData value)? data,
    TResult Function(_RegisterStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterStateCopyWith<$Res> {
  factory $RegisterStateCopyWith(
          RegisterState value, $Res Function(RegisterState) then) =
      _$RegisterStateCopyWithImpl<$Res, RegisterState>;
}

/// @nodoc
class _$RegisterStateCopyWithImpl<$Res, $Val extends RegisterState>
    implements $RegisterStateCopyWith<$Res> {
  _$RegisterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$RegisterStateInitialImplCopyWith<$Res> {
  factory _$$RegisterStateInitialImplCopyWith(_$RegisterStateInitialImpl value,
          $Res Function(_$RegisterStateInitialImpl) then) =
      __$$RegisterStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RegisterStateInitialImplCopyWithImpl<$Res>
    extends _$RegisterStateCopyWithImpl<$Res, _$RegisterStateInitialImpl>
    implements _$$RegisterStateInitialImplCopyWith<$Res> {
  __$$RegisterStateInitialImplCopyWithImpl(_$RegisterStateInitialImpl _value,
      $Res Function(_$RegisterStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RegisterStateInitialImpl implements _RegisterStateInitial {
  const _$RegisterStateInitialImpl();

  @override
  String toString() {
    return 'RegisterState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(RegisterResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(RegisterResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(RegisterResponse data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegisterStateInitial value) initial,
    required TResult Function(_RegisterStateLoading value) loading,
    required TResult Function(_RegisterStateData value) data,
    required TResult Function(_RegisterStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegisterStateInitial value)? initial,
    TResult? Function(_RegisterStateLoading value)? loading,
    TResult? Function(_RegisterStateData value)? data,
    TResult? Function(_RegisterStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegisterStateInitial value)? initial,
    TResult Function(_RegisterStateLoading value)? loading,
    TResult Function(_RegisterStateData value)? data,
    TResult Function(_RegisterStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _RegisterStateInitial implements RegisterState {
  const factory _RegisterStateInitial() = _$RegisterStateInitialImpl;
}

/// @nodoc
abstract class _$$RegisterStateLoadingImplCopyWith<$Res> {
  factory _$$RegisterStateLoadingImplCopyWith(_$RegisterStateLoadingImpl value,
          $Res Function(_$RegisterStateLoadingImpl) then) =
      __$$RegisterStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RegisterStateLoadingImplCopyWithImpl<$Res>
    extends _$RegisterStateCopyWithImpl<$Res, _$RegisterStateLoadingImpl>
    implements _$$RegisterStateLoadingImplCopyWith<$Res> {
  __$$RegisterStateLoadingImplCopyWithImpl(_$RegisterStateLoadingImpl _value,
      $Res Function(_$RegisterStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RegisterStateLoadingImpl implements _RegisterStateLoading {
  const _$RegisterStateLoadingImpl();

  @override
  String toString() {
    return 'RegisterState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(RegisterResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(RegisterResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(RegisterResponse data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegisterStateInitial value) initial,
    required TResult Function(_RegisterStateLoading value) loading,
    required TResult Function(_RegisterStateData value) data,
    required TResult Function(_RegisterStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegisterStateInitial value)? initial,
    TResult? Function(_RegisterStateLoading value)? loading,
    TResult? Function(_RegisterStateData value)? data,
    TResult? Function(_RegisterStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegisterStateInitial value)? initial,
    TResult Function(_RegisterStateLoading value)? loading,
    TResult Function(_RegisterStateData value)? data,
    TResult Function(_RegisterStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _RegisterStateLoading implements RegisterState {
  const factory _RegisterStateLoading() = _$RegisterStateLoadingImpl;
}

/// @nodoc
abstract class _$$RegisterStateDataImplCopyWith<$Res> {
  factory _$$RegisterStateDataImplCopyWith(_$RegisterStateDataImpl value,
          $Res Function(_$RegisterStateDataImpl) then) =
      __$$RegisterStateDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({RegisterResponse data});
}

/// @nodoc
class __$$RegisterStateDataImplCopyWithImpl<$Res>
    extends _$RegisterStateCopyWithImpl<$Res, _$RegisterStateDataImpl>
    implements _$$RegisterStateDataImplCopyWith<$Res> {
  __$$RegisterStateDataImplCopyWithImpl(_$RegisterStateDataImpl _value,
      $Res Function(_$RegisterStateDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$RegisterStateDataImpl(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as RegisterResponse,
    ));
  }
}

/// @nodoc

class _$RegisterStateDataImpl implements _RegisterStateData {
  const _$RegisterStateDataImpl(this.data);

  @override
  final RegisterResponse data;

  @override
  String toString() {
    return 'RegisterState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterStateDataImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterStateDataImplCopyWith<_$RegisterStateDataImpl> get copyWith =>
      __$$RegisterStateDataImplCopyWithImpl<_$RegisterStateDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(RegisterResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(RegisterResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(RegisterResponse data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this.data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegisterStateInitial value) initial,
    required TResult Function(_RegisterStateLoading value) loading,
    required TResult Function(_RegisterStateData value) data,
    required TResult Function(_RegisterStateError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegisterStateInitial value)? initial,
    TResult? Function(_RegisterStateLoading value)? loading,
    TResult? Function(_RegisterStateData value)? data,
    TResult? Function(_RegisterStateError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegisterStateInitial value)? initial,
    TResult Function(_RegisterStateLoading value)? loading,
    TResult Function(_RegisterStateData value)? data,
    TResult Function(_RegisterStateError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _RegisterStateData implements RegisterState {
  const factory _RegisterStateData(final RegisterResponse data) =
      _$RegisterStateDataImpl;

  RegisterResponse get data;
  @JsonKey(ignore: true)
  _$$RegisterStateDataImplCopyWith<_$RegisterStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RegisterStateErrorImplCopyWith<$Res> {
  factory _$$RegisterStateErrorImplCopyWith(_$RegisterStateErrorImpl value,
          $Res Function(_$RegisterStateErrorImpl) then) =
      __$$RegisterStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$RegisterStateErrorImplCopyWithImpl<$Res>
    extends _$RegisterStateCopyWithImpl<$Res, _$RegisterStateErrorImpl>
    implements _$$RegisterStateErrorImplCopyWith<$Res> {
  __$$RegisterStateErrorImplCopyWithImpl(_$RegisterStateErrorImpl _value,
      $Res Function(_$RegisterStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$RegisterStateErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RegisterStateErrorImpl implements _RegisterStateError {
  const _$RegisterStateErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'RegisterState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterStateErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterStateErrorImplCopyWith<_$RegisterStateErrorImpl> get copyWith =>
      __$$RegisterStateErrorImplCopyWithImpl<_$RegisterStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(RegisterResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return error(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(RegisterResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return error?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(RegisterResponse data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(msg);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_RegisterStateInitial value) initial,
    required TResult Function(_RegisterStateLoading value) loading,
    required TResult Function(_RegisterStateData value) data,
    required TResult Function(_RegisterStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_RegisterStateInitial value)? initial,
    TResult? Function(_RegisterStateLoading value)? loading,
    TResult? Function(_RegisterStateData value)? data,
    TResult? Function(_RegisterStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_RegisterStateInitial value)? initial,
    TResult Function(_RegisterStateLoading value)? loading,
    TResult Function(_RegisterStateData value)? data,
    TResult Function(_RegisterStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _RegisterStateError implements RegisterState {
  const factory _RegisterStateError(final String msg) =
      _$RegisterStateErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$RegisterStateErrorImplCopyWith<_$RegisterStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
