// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'logout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LogoutState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(LogoutResponseModel data) data,
    required TResult Function(String msg) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(LogoutResponseModel data)? data,
    TResult? Function(String msg)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(LogoutResponseModel data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LogoutInitial value) initial,
    required TResult Function(_LogoutLoading value) loading,
    required TResult Function(_LogoutData value) data,
    required TResult Function(_LogoutError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LogoutInitial value)? initial,
    TResult? Function(_LogoutLoading value)? loading,
    TResult? Function(_LogoutData value)? data,
    TResult? Function(_LogoutError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LogoutInitial value)? initial,
    TResult Function(_LogoutLoading value)? loading,
    TResult Function(_LogoutData value)? data,
    TResult Function(_LogoutError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogoutStateCopyWith<$Res> {
  factory $LogoutStateCopyWith(
          LogoutState value, $Res Function(LogoutState) then) =
      _$LogoutStateCopyWithImpl<$Res, LogoutState>;
}

/// @nodoc
class _$LogoutStateCopyWithImpl<$Res, $Val extends LogoutState>
    implements $LogoutStateCopyWith<$Res> {
  _$LogoutStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LogoutInitialImplCopyWith<$Res> {
  factory _$$LogoutInitialImplCopyWith(
          _$LogoutInitialImpl value, $Res Function(_$LogoutInitialImpl) then) =
      __$$LogoutInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LogoutInitialImplCopyWithImpl<$Res>
    extends _$LogoutStateCopyWithImpl<$Res, _$LogoutInitialImpl>
    implements _$$LogoutInitialImplCopyWith<$Res> {
  __$$LogoutInitialImplCopyWithImpl(
      _$LogoutInitialImpl _value, $Res Function(_$LogoutInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LogoutInitialImpl implements _LogoutInitial {
  const _$LogoutInitialImpl();

  @override
  String toString() {
    return 'LogoutState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LogoutInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(LogoutResponseModel data) data,
    required TResult Function(String msg) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(LogoutResponseModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(LogoutResponseModel data)? data,
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
    required TResult Function(_LogoutInitial value) initial,
    required TResult Function(_LogoutLoading value) loading,
    required TResult Function(_LogoutData value) data,
    required TResult Function(_LogoutError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LogoutInitial value)? initial,
    TResult? Function(_LogoutLoading value)? loading,
    TResult? Function(_LogoutData value)? data,
    TResult? Function(_LogoutError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LogoutInitial value)? initial,
    TResult Function(_LogoutLoading value)? loading,
    TResult Function(_LogoutData value)? data,
    TResult Function(_LogoutError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _LogoutInitial implements LogoutState {
  const factory _LogoutInitial() = _$LogoutInitialImpl;
}

/// @nodoc
abstract class _$$LogoutLoadingImplCopyWith<$Res> {
  factory _$$LogoutLoadingImplCopyWith(
          _$LogoutLoadingImpl value, $Res Function(_$LogoutLoadingImpl) then) =
      __$$LogoutLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LogoutLoadingImplCopyWithImpl<$Res>
    extends _$LogoutStateCopyWithImpl<$Res, _$LogoutLoadingImpl>
    implements _$$LogoutLoadingImplCopyWith<$Res> {
  __$$LogoutLoadingImplCopyWithImpl(
      _$LogoutLoadingImpl _value, $Res Function(_$LogoutLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LogoutLoadingImpl implements _LogoutLoading {
  const _$LogoutLoadingImpl();

  @override
  String toString() {
    return 'LogoutState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LogoutLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(LogoutResponseModel data) data,
    required TResult Function(String msg) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(LogoutResponseModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(LogoutResponseModel data)? data,
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
    required TResult Function(_LogoutInitial value) initial,
    required TResult Function(_LogoutLoading value) loading,
    required TResult Function(_LogoutData value) data,
    required TResult Function(_LogoutError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LogoutInitial value)? initial,
    TResult? Function(_LogoutLoading value)? loading,
    TResult? Function(_LogoutData value)? data,
    TResult? Function(_LogoutError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LogoutInitial value)? initial,
    TResult Function(_LogoutLoading value)? loading,
    TResult Function(_LogoutData value)? data,
    TResult Function(_LogoutError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _LogoutLoading implements LogoutState {
  const factory _LogoutLoading() = _$LogoutLoadingImpl;
}

/// @nodoc
abstract class _$$LogoutDataImplCopyWith<$Res> {
  factory _$$LogoutDataImplCopyWith(
          _$LogoutDataImpl value, $Res Function(_$LogoutDataImpl) then) =
      __$$LogoutDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({LogoutResponseModel data});
}

/// @nodoc
class __$$LogoutDataImplCopyWithImpl<$Res>
    extends _$LogoutStateCopyWithImpl<$Res, _$LogoutDataImpl>
    implements _$$LogoutDataImplCopyWith<$Res> {
  __$$LogoutDataImplCopyWithImpl(
      _$LogoutDataImpl _value, $Res Function(_$LogoutDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$LogoutDataImpl(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as LogoutResponseModel,
    ));
  }
}

/// @nodoc

class _$LogoutDataImpl implements _LogoutData {
  const _$LogoutDataImpl(this.data);

  @override
  final LogoutResponseModel data;

  @override
  String toString() {
    return 'LogoutState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogoutDataImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LogoutDataImplCopyWith<_$LogoutDataImpl> get copyWith =>
      __$$LogoutDataImplCopyWithImpl<_$LogoutDataImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(LogoutResponseModel data) data,
    required TResult Function(String msg) error,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(LogoutResponseModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(LogoutResponseModel data)? data,
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
    required TResult Function(_LogoutInitial value) initial,
    required TResult Function(_LogoutLoading value) loading,
    required TResult Function(_LogoutData value) data,
    required TResult Function(_LogoutError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LogoutInitial value)? initial,
    TResult? Function(_LogoutLoading value)? loading,
    TResult? Function(_LogoutData value)? data,
    TResult? Function(_LogoutError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LogoutInitial value)? initial,
    TResult Function(_LogoutLoading value)? loading,
    TResult Function(_LogoutData value)? data,
    TResult Function(_LogoutError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _LogoutData implements LogoutState {
  const factory _LogoutData(final LogoutResponseModel data) = _$LogoutDataImpl;

  LogoutResponseModel get data;
  @JsonKey(ignore: true)
  _$$LogoutDataImplCopyWith<_$LogoutDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LogoutErrorImplCopyWith<$Res> {
  factory _$$LogoutErrorImplCopyWith(
          _$LogoutErrorImpl value, $Res Function(_$LogoutErrorImpl) then) =
      __$$LogoutErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$LogoutErrorImplCopyWithImpl<$Res>
    extends _$LogoutStateCopyWithImpl<$Res, _$LogoutErrorImpl>
    implements _$$LogoutErrorImplCopyWith<$Res> {
  __$$LogoutErrorImplCopyWithImpl(
      _$LogoutErrorImpl _value, $Res Function(_$LogoutErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$LogoutErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LogoutErrorImpl implements _LogoutError {
  const _$LogoutErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'LogoutState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogoutErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LogoutErrorImplCopyWith<_$LogoutErrorImpl> get copyWith =>
      __$$LogoutErrorImplCopyWithImpl<_$LogoutErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(LogoutResponseModel data) data,
    required TResult Function(String msg) error,
  }) {
    return error(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(LogoutResponseModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return error?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(LogoutResponseModel data)? data,
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
    required TResult Function(_LogoutInitial value) initial,
    required TResult Function(_LogoutLoading value) loading,
    required TResult Function(_LogoutData value) data,
    required TResult Function(_LogoutError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LogoutInitial value)? initial,
    TResult? Function(_LogoutLoading value)? loading,
    TResult? Function(_LogoutData value)? data,
    TResult? Function(_LogoutError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LogoutInitial value)? initial,
    TResult Function(_LogoutLoading value)? loading,
    TResult Function(_LogoutData value)? data,
    TResult Function(_LogoutError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _LogoutError implements LogoutState {
  const factory _LogoutError(final String msg) = _$LogoutErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$LogoutErrorImplCopyWith<_$LogoutErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
