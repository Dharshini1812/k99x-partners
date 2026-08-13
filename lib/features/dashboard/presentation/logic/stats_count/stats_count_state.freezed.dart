// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_count_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$StatsCountState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DashboardStats data) data,
    required TResult Function(String msg) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DashboardStats data)? data,
    TResult? Function(String msg)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DashboardStats data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_StatsCountStateInitial value) initial,
    required TResult Function(_StatsCountStateLoading value) loading,
    required TResult Function(_StatsCountStateData value) data,
    required TResult Function(_StatsCountStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_StatsCountStateInitial value)? initial,
    TResult? Function(_StatsCountStateLoading value)? loading,
    TResult? Function(_StatsCountStateData value)? data,
    TResult? Function(_StatsCountStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_StatsCountStateInitial value)? initial,
    TResult Function(_StatsCountStateLoading value)? loading,
    TResult Function(_StatsCountStateData value)? data,
    TResult Function(_StatsCountStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsCountStateCopyWith<$Res> {
  factory $StatsCountStateCopyWith(
          StatsCountState value, $Res Function(StatsCountState) then) =
      _$StatsCountStateCopyWithImpl<$Res, StatsCountState>;
}

/// @nodoc
class _$StatsCountStateCopyWithImpl<$Res, $Val extends StatsCountState>
    implements $StatsCountStateCopyWith<$Res> {
  _$StatsCountStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$StatsCountStateInitialImplCopyWith<$Res> {
  factory _$$StatsCountStateInitialImplCopyWith(
          _$StatsCountStateInitialImpl value,
          $Res Function(_$StatsCountStateInitialImpl) then) =
      __$$StatsCountStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StatsCountStateInitialImplCopyWithImpl<$Res>
    extends _$StatsCountStateCopyWithImpl<$Res, _$StatsCountStateInitialImpl>
    implements _$$StatsCountStateInitialImplCopyWith<$Res> {
  __$$StatsCountStateInitialImplCopyWithImpl(
      _$StatsCountStateInitialImpl _value,
      $Res Function(_$StatsCountStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$StatsCountStateInitialImpl implements _StatsCountStateInitial {
  const _$StatsCountStateInitialImpl();

  @override
  String toString() {
    return 'StatsCountState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsCountStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DashboardStats data) data,
    required TResult Function(String msg) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DashboardStats data)? data,
    TResult? Function(String msg)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DashboardStats data)? data,
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
    required TResult Function(_StatsCountStateInitial value) initial,
    required TResult Function(_StatsCountStateLoading value) loading,
    required TResult Function(_StatsCountStateData value) data,
    required TResult Function(_StatsCountStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_StatsCountStateInitial value)? initial,
    TResult? Function(_StatsCountStateLoading value)? loading,
    TResult? Function(_StatsCountStateData value)? data,
    TResult? Function(_StatsCountStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_StatsCountStateInitial value)? initial,
    TResult Function(_StatsCountStateLoading value)? loading,
    TResult Function(_StatsCountStateData value)? data,
    TResult Function(_StatsCountStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _StatsCountStateInitial implements StatsCountState {
  const factory _StatsCountStateInitial() = _$StatsCountStateInitialImpl;
}

/// @nodoc
abstract class _$$StatsCountStateLoadingImplCopyWith<$Res> {
  factory _$$StatsCountStateLoadingImplCopyWith(
          _$StatsCountStateLoadingImpl value,
          $Res Function(_$StatsCountStateLoadingImpl) then) =
      __$$StatsCountStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StatsCountStateLoadingImplCopyWithImpl<$Res>
    extends _$StatsCountStateCopyWithImpl<$Res, _$StatsCountStateLoadingImpl>
    implements _$$StatsCountStateLoadingImplCopyWith<$Res> {
  __$$StatsCountStateLoadingImplCopyWithImpl(
      _$StatsCountStateLoadingImpl _value,
      $Res Function(_$StatsCountStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$StatsCountStateLoadingImpl implements _StatsCountStateLoading {
  const _$StatsCountStateLoadingImpl();

  @override
  String toString() {
    return 'StatsCountState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsCountStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DashboardStats data) data,
    required TResult Function(String msg) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DashboardStats data)? data,
    TResult? Function(String msg)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DashboardStats data)? data,
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
    required TResult Function(_StatsCountStateInitial value) initial,
    required TResult Function(_StatsCountStateLoading value) loading,
    required TResult Function(_StatsCountStateData value) data,
    required TResult Function(_StatsCountStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_StatsCountStateInitial value)? initial,
    TResult? Function(_StatsCountStateLoading value)? loading,
    TResult? Function(_StatsCountStateData value)? data,
    TResult? Function(_StatsCountStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_StatsCountStateInitial value)? initial,
    TResult Function(_StatsCountStateLoading value)? loading,
    TResult Function(_StatsCountStateData value)? data,
    TResult Function(_StatsCountStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _StatsCountStateLoading implements StatsCountState {
  const factory _StatsCountStateLoading() = _$StatsCountStateLoadingImpl;
}

/// @nodoc
abstract class _$$StatsCountStateDataImplCopyWith<$Res> {
  factory _$$StatsCountStateDataImplCopyWith(_$StatsCountStateDataImpl value,
          $Res Function(_$StatsCountStateDataImpl) then) =
      __$$StatsCountStateDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DashboardStats data});
}

/// @nodoc
class __$$StatsCountStateDataImplCopyWithImpl<$Res>
    extends _$StatsCountStateCopyWithImpl<$Res, _$StatsCountStateDataImpl>
    implements _$$StatsCountStateDataImplCopyWith<$Res> {
  __$$StatsCountStateDataImplCopyWithImpl(_$StatsCountStateDataImpl _value,
      $Res Function(_$StatsCountStateDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$StatsCountStateDataImpl(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as DashboardStats,
    ));
  }
}

/// @nodoc

class _$StatsCountStateDataImpl implements _StatsCountStateData {
  const _$StatsCountStateDataImpl(this.data);

  @override
  final DashboardStats data;

  @override
  String toString() {
    return 'StatsCountState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsCountStateDataImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsCountStateDataImplCopyWith<_$StatsCountStateDataImpl> get copyWith =>
      __$$StatsCountStateDataImplCopyWithImpl<_$StatsCountStateDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DashboardStats data) data,
    required TResult Function(String msg) error,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DashboardStats data)? data,
    TResult? Function(String msg)? error,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DashboardStats data)? data,
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
    required TResult Function(_StatsCountStateInitial value) initial,
    required TResult Function(_StatsCountStateLoading value) loading,
    required TResult Function(_StatsCountStateData value) data,
    required TResult Function(_StatsCountStateError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_StatsCountStateInitial value)? initial,
    TResult? Function(_StatsCountStateLoading value)? loading,
    TResult? Function(_StatsCountStateData value)? data,
    TResult? Function(_StatsCountStateError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_StatsCountStateInitial value)? initial,
    TResult Function(_StatsCountStateLoading value)? loading,
    TResult Function(_StatsCountStateData value)? data,
    TResult Function(_StatsCountStateError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _StatsCountStateData implements StatsCountState {
  const factory _StatsCountStateData(final DashboardStats data) =
      _$StatsCountStateDataImpl;

  DashboardStats get data;
  @JsonKey(ignore: true)
  _$$StatsCountStateDataImplCopyWith<_$StatsCountStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StatsCountStateErrorImplCopyWith<$Res> {
  factory _$$StatsCountStateErrorImplCopyWith(_$StatsCountStateErrorImpl value,
          $Res Function(_$StatsCountStateErrorImpl) then) =
      __$$StatsCountStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$StatsCountStateErrorImplCopyWithImpl<$Res>
    extends _$StatsCountStateCopyWithImpl<$Res, _$StatsCountStateErrorImpl>
    implements _$$StatsCountStateErrorImplCopyWith<$Res> {
  __$$StatsCountStateErrorImplCopyWithImpl(_$StatsCountStateErrorImpl _value,
      $Res Function(_$StatsCountStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$StatsCountStateErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$StatsCountStateErrorImpl implements _StatsCountStateError {
  const _$StatsCountStateErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'StatsCountState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsCountStateErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsCountStateErrorImplCopyWith<_$StatsCountStateErrorImpl>
      get copyWith =>
          __$$StatsCountStateErrorImplCopyWithImpl<_$StatsCountStateErrorImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DashboardStats data) data,
    required TResult Function(String msg) error,
  }) {
    return error(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DashboardStats data)? data,
    TResult? Function(String msg)? error,
  }) {
    return error?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DashboardStats data)? data,
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
    required TResult Function(_StatsCountStateInitial value) initial,
    required TResult Function(_StatsCountStateLoading value) loading,
    required TResult Function(_StatsCountStateData value) data,
    required TResult Function(_StatsCountStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_StatsCountStateInitial value)? initial,
    TResult? Function(_StatsCountStateLoading value)? loading,
    TResult? Function(_StatsCountStateData value)? data,
    TResult? Function(_StatsCountStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_StatsCountStateInitial value)? initial,
    TResult Function(_StatsCountStateLoading value)? loading,
    TResult Function(_StatsCountStateData value)? data,
    TResult Function(_StatsCountStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _StatsCountStateError implements StatsCountState {
  const factory _StatsCountStateError(final String msg) =
      _$StatsCountStateErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$StatsCountStateErrorImplCopyWith<_$StatsCountStateErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}
