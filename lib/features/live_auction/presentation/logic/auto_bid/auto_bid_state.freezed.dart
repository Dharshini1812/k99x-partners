// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_bid_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AutoBidState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AutoBidResponseModel data) data,
    required TResult Function(String msg) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AutoBidResponseModel data)? data,
    TResult? Function(String msg)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AutoBidResponseModel data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AutoBidStateInitial value) initial,
    required TResult Function(_AutoBidStateLoading value) loading,
    required TResult Function(_AutoBidStateData value) data,
    required TResult Function(_AutoBidStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AutoBidStateInitial value)? initial,
    TResult? Function(_AutoBidStateLoading value)? loading,
    TResult? Function(_AutoBidStateData value)? data,
    TResult? Function(_AutoBidStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AutoBidStateInitial value)? initial,
    TResult Function(_AutoBidStateLoading value)? loading,
    TResult Function(_AutoBidStateData value)? data,
    TResult Function(_AutoBidStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutoBidStateCopyWith<$Res> {
  factory $AutoBidStateCopyWith(
          AutoBidState value, $Res Function(AutoBidState) then) =
      _$AutoBidStateCopyWithImpl<$Res, AutoBidState>;
}

/// @nodoc
class _$AutoBidStateCopyWithImpl<$Res, $Val extends AutoBidState>
    implements $AutoBidStateCopyWith<$Res> {
  _$AutoBidStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AutoBidStateInitialImplCopyWith<$Res> {
  factory _$$AutoBidStateInitialImplCopyWith(_$AutoBidStateInitialImpl value,
          $Res Function(_$AutoBidStateInitialImpl) then) =
      __$$AutoBidStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AutoBidStateInitialImplCopyWithImpl<$Res>
    extends _$AutoBidStateCopyWithImpl<$Res, _$AutoBidStateInitialImpl>
    implements _$$AutoBidStateInitialImplCopyWith<$Res> {
  __$$AutoBidStateInitialImplCopyWithImpl(_$AutoBidStateInitialImpl _value,
      $Res Function(_$AutoBidStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AutoBidStateInitialImpl implements _AutoBidStateInitial {
  const _$AutoBidStateInitialImpl();

  @override
  String toString() {
    return 'AutoBidState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoBidStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AutoBidResponseModel data) data,
    required TResult Function(String msg) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AutoBidResponseModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AutoBidResponseModel data)? data,
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
    required TResult Function(_AutoBidStateInitial value) initial,
    required TResult Function(_AutoBidStateLoading value) loading,
    required TResult Function(_AutoBidStateData value) data,
    required TResult Function(_AutoBidStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AutoBidStateInitial value)? initial,
    TResult? Function(_AutoBidStateLoading value)? loading,
    TResult? Function(_AutoBidStateData value)? data,
    TResult? Function(_AutoBidStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AutoBidStateInitial value)? initial,
    TResult Function(_AutoBidStateLoading value)? loading,
    TResult Function(_AutoBidStateData value)? data,
    TResult Function(_AutoBidStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _AutoBidStateInitial implements AutoBidState {
  const factory _AutoBidStateInitial() = _$AutoBidStateInitialImpl;
}

/// @nodoc
abstract class _$$AutoBidStateLoadingImplCopyWith<$Res> {
  factory _$$AutoBidStateLoadingImplCopyWith(_$AutoBidStateLoadingImpl value,
          $Res Function(_$AutoBidStateLoadingImpl) then) =
      __$$AutoBidStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AutoBidStateLoadingImplCopyWithImpl<$Res>
    extends _$AutoBidStateCopyWithImpl<$Res, _$AutoBidStateLoadingImpl>
    implements _$$AutoBidStateLoadingImplCopyWith<$Res> {
  __$$AutoBidStateLoadingImplCopyWithImpl(_$AutoBidStateLoadingImpl _value,
      $Res Function(_$AutoBidStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AutoBidStateLoadingImpl implements _AutoBidStateLoading {
  const _$AutoBidStateLoadingImpl();

  @override
  String toString() {
    return 'AutoBidState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoBidStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AutoBidResponseModel data) data,
    required TResult Function(String msg) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AutoBidResponseModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AutoBidResponseModel data)? data,
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
    required TResult Function(_AutoBidStateInitial value) initial,
    required TResult Function(_AutoBidStateLoading value) loading,
    required TResult Function(_AutoBidStateData value) data,
    required TResult Function(_AutoBidStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AutoBidStateInitial value)? initial,
    TResult? Function(_AutoBidStateLoading value)? loading,
    TResult? Function(_AutoBidStateData value)? data,
    TResult? Function(_AutoBidStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AutoBidStateInitial value)? initial,
    TResult Function(_AutoBidStateLoading value)? loading,
    TResult Function(_AutoBidStateData value)? data,
    TResult Function(_AutoBidStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _AutoBidStateLoading implements AutoBidState {
  const factory _AutoBidStateLoading() = _$AutoBidStateLoadingImpl;
}

/// @nodoc
abstract class _$$AutoBidStateDataImplCopyWith<$Res> {
  factory _$$AutoBidStateDataImplCopyWith(_$AutoBidStateDataImpl value,
          $Res Function(_$AutoBidStateDataImpl) then) =
      __$$AutoBidStateDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AutoBidResponseModel data});
}

/// @nodoc
class __$$AutoBidStateDataImplCopyWithImpl<$Res>
    extends _$AutoBidStateCopyWithImpl<$Res, _$AutoBidStateDataImpl>
    implements _$$AutoBidStateDataImplCopyWith<$Res> {
  __$$AutoBidStateDataImplCopyWithImpl(_$AutoBidStateDataImpl _value,
      $Res Function(_$AutoBidStateDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$AutoBidStateDataImpl(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as AutoBidResponseModel,
    ));
  }
}

/// @nodoc

class _$AutoBidStateDataImpl implements _AutoBidStateData {
  const _$AutoBidStateDataImpl(this.data);

  @override
  final AutoBidResponseModel data;

  @override
  String toString() {
    return 'AutoBidState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoBidStateDataImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoBidStateDataImplCopyWith<_$AutoBidStateDataImpl> get copyWith =>
      __$$AutoBidStateDataImplCopyWithImpl<_$AutoBidStateDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AutoBidResponseModel data) data,
    required TResult Function(String msg) error,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AutoBidResponseModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AutoBidResponseModel data)? data,
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
    required TResult Function(_AutoBidStateInitial value) initial,
    required TResult Function(_AutoBidStateLoading value) loading,
    required TResult Function(_AutoBidStateData value) data,
    required TResult Function(_AutoBidStateError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AutoBidStateInitial value)? initial,
    TResult? Function(_AutoBidStateLoading value)? loading,
    TResult? Function(_AutoBidStateData value)? data,
    TResult? Function(_AutoBidStateError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AutoBidStateInitial value)? initial,
    TResult Function(_AutoBidStateLoading value)? loading,
    TResult Function(_AutoBidStateData value)? data,
    TResult Function(_AutoBidStateError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _AutoBidStateData implements AutoBidState {
  const factory _AutoBidStateData(final AutoBidResponseModel data) =
      _$AutoBidStateDataImpl;

  AutoBidResponseModel get data;
  @JsonKey(ignore: true)
  _$$AutoBidStateDataImplCopyWith<_$AutoBidStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AutoBidStateErrorImplCopyWith<$Res> {
  factory _$$AutoBidStateErrorImplCopyWith(_$AutoBidStateErrorImpl value,
          $Res Function(_$AutoBidStateErrorImpl) then) =
      __$$AutoBidStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$AutoBidStateErrorImplCopyWithImpl<$Res>
    extends _$AutoBidStateCopyWithImpl<$Res, _$AutoBidStateErrorImpl>
    implements _$$AutoBidStateErrorImplCopyWith<$Res> {
  __$$AutoBidStateErrorImplCopyWithImpl(_$AutoBidStateErrorImpl _value,
      $Res Function(_$AutoBidStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$AutoBidStateErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AutoBidStateErrorImpl implements _AutoBidStateError {
  const _$AutoBidStateErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'AutoBidState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoBidStateErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoBidStateErrorImplCopyWith<_$AutoBidStateErrorImpl> get copyWith =>
      __$$AutoBidStateErrorImplCopyWithImpl<_$AutoBidStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(AutoBidResponseModel data) data,
    required TResult Function(String msg) error,
  }) {
    return error(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(AutoBidResponseModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return error?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(AutoBidResponseModel data)? data,
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
    required TResult Function(_AutoBidStateInitial value) initial,
    required TResult Function(_AutoBidStateLoading value) loading,
    required TResult Function(_AutoBidStateData value) data,
    required TResult Function(_AutoBidStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AutoBidStateInitial value)? initial,
    TResult? Function(_AutoBidStateLoading value)? loading,
    TResult? Function(_AutoBidStateData value)? data,
    TResult? Function(_AutoBidStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AutoBidStateInitial value)? initial,
    TResult Function(_AutoBidStateLoading value)? loading,
    TResult Function(_AutoBidStateData value)? data,
    TResult Function(_AutoBidStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _AutoBidStateError implements AutoBidState {
  const factory _AutoBidStateError(final String msg) = _$AutoBidStateErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$AutoBidStateErrorImplCopyWith<_$AutoBidStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
