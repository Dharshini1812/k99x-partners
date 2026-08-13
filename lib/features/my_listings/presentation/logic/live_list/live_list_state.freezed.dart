// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LiveListState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VehicleResponse data) data,
    required TResult Function(String msg) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VehicleResponse data)? data,
    TResult? Function(String msg)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VehicleResponse data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LiveListStateInitial value) initial,
    required TResult Function(_LiveListStateLoading value) loading,
    required TResult Function(_LiveListStateData value) data,
    required TResult Function(_LiveListStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LiveListStateInitial value)? initial,
    TResult? Function(_LiveListStateLoading value)? loading,
    TResult? Function(_LiveListStateData value)? data,
    TResult? Function(_LiveListStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LiveListStateInitial value)? initial,
    TResult Function(_LiveListStateLoading value)? loading,
    TResult Function(_LiveListStateData value)? data,
    TResult Function(_LiveListStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveListStateCopyWith<$Res> {
  factory $LiveListStateCopyWith(
          LiveListState value, $Res Function(LiveListState) then) =
      _$LiveListStateCopyWithImpl<$Res, LiveListState>;
}

/// @nodoc
class _$LiveListStateCopyWithImpl<$Res, $Val extends LiveListState>
    implements $LiveListStateCopyWith<$Res> {
  _$LiveListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LiveListStateInitialImplCopyWith<$Res> {
  factory _$$LiveListStateInitialImplCopyWith(_$LiveListStateInitialImpl value,
          $Res Function(_$LiveListStateInitialImpl) then) =
      __$$LiveListStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LiveListStateInitialImplCopyWithImpl<$Res>
    extends _$LiveListStateCopyWithImpl<$Res, _$LiveListStateInitialImpl>
    implements _$$LiveListStateInitialImplCopyWith<$Res> {
  __$$LiveListStateInitialImplCopyWithImpl(_$LiveListStateInitialImpl _value,
      $Res Function(_$LiveListStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LiveListStateInitialImpl implements _LiveListStateInitial {
  const _$LiveListStateInitialImpl();

  @override
  String toString() {
    return 'LiveListState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveListStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VehicleResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VehicleResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VehicleResponse data)? data,
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
    required TResult Function(_LiveListStateInitial value) initial,
    required TResult Function(_LiveListStateLoading value) loading,
    required TResult Function(_LiveListStateData value) data,
    required TResult Function(_LiveListStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LiveListStateInitial value)? initial,
    TResult? Function(_LiveListStateLoading value)? loading,
    TResult? Function(_LiveListStateData value)? data,
    TResult? Function(_LiveListStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LiveListStateInitial value)? initial,
    TResult Function(_LiveListStateLoading value)? loading,
    TResult Function(_LiveListStateData value)? data,
    TResult Function(_LiveListStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _LiveListStateInitial implements LiveListState {
  const factory _LiveListStateInitial() = _$LiveListStateInitialImpl;
}

/// @nodoc
abstract class _$$LiveListStateLoadingImplCopyWith<$Res> {
  factory _$$LiveListStateLoadingImplCopyWith(_$LiveListStateLoadingImpl value,
          $Res Function(_$LiveListStateLoadingImpl) then) =
      __$$LiveListStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LiveListStateLoadingImplCopyWithImpl<$Res>
    extends _$LiveListStateCopyWithImpl<$Res, _$LiveListStateLoadingImpl>
    implements _$$LiveListStateLoadingImplCopyWith<$Res> {
  __$$LiveListStateLoadingImplCopyWithImpl(_$LiveListStateLoadingImpl _value,
      $Res Function(_$LiveListStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LiveListStateLoadingImpl implements _LiveListStateLoading {
  const _$LiveListStateLoadingImpl();

  @override
  String toString() {
    return 'LiveListState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveListStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VehicleResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VehicleResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VehicleResponse data)? data,
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
    required TResult Function(_LiveListStateInitial value) initial,
    required TResult Function(_LiveListStateLoading value) loading,
    required TResult Function(_LiveListStateData value) data,
    required TResult Function(_LiveListStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LiveListStateInitial value)? initial,
    TResult? Function(_LiveListStateLoading value)? loading,
    TResult? Function(_LiveListStateData value)? data,
    TResult? Function(_LiveListStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LiveListStateInitial value)? initial,
    TResult Function(_LiveListStateLoading value)? loading,
    TResult Function(_LiveListStateData value)? data,
    TResult Function(_LiveListStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _LiveListStateLoading implements LiveListState {
  const factory _LiveListStateLoading() = _$LiveListStateLoadingImpl;
}

/// @nodoc
abstract class _$$LiveListStateDataImplCopyWith<$Res> {
  factory _$$LiveListStateDataImplCopyWith(_$LiveListStateDataImpl value,
          $Res Function(_$LiveListStateDataImpl) then) =
      __$$LiveListStateDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VehicleResponse data});
}

/// @nodoc
class __$$LiveListStateDataImplCopyWithImpl<$Res>
    extends _$LiveListStateCopyWithImpl<$Res, _$LiveListStateDataImpl>
    implements _$$LiveListStateDataImplCopyWith<$Res> {
  __$$LiveListStateDataImplCopyWithImpl(_$LiveListStateDataImpl _value,
      $Res Function(_$LiveListStateDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$LiveListStateDataImpl(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as VehicleResponse,
    ));
  }
}

/// @nodoc

class _$LiveListStateDataImpl implements _LiveListStateData {
  const _$LiveListStateDataImpl(this.data);

  @override
  final VehicleResponse data;

  @override
  String toString() {
    return 'LiveListState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveListStateDataImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveListStateDataImplCopyWith<_$LiveListStateDataImpl> get copyWith =>
      __$$LiveListStateDataImplCopyWithImpl<_$LiveListStateDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VehicleResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VehicleResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VehicleResponse data)? data,
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
    required TResult Function(_LiveListStateInitial value) initial,
    required TResult Function(_LiveListStateLoading value) loading,
    required TResult Function(_LiveListStateData value) data,
    required TResult Function(_LiveListStateError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LiveListStateInitial value)? initial,
    TResult? Function(_LiveListStateLoading value)? loading,
    TResult? Function(_LiveListStateData value)? data,
    TResult? Function(_LiveListStateError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LiveListStateInitial value)? initial,
    TResult Function(_LiveListStateLoading value)? loading,
    TResult Function(_LiveListStateData value)? data,
    TResult Function(_LiveListStateError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _LiveListStateData implements LiveListState {
  const factory _LiveListStateData(final VehicleResponse data) =
      _$LiveListStateDataImpl;

  VehicleResponse get data;
  @JsonKey(ignore: true)
  _$$LiveListStateDataImplCopyWith<_$LiveListStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LiveListStateErrorImplCopyWith<$Res> {
  factory _$$LiveListStateErrorImplCopyWith(_$LiveListStateErrorImpl value,
          $Res Function(_$LiveListStateErrorImpl) then) =
      __$$LiveListStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$LiveListStateErrorImplCopyWithImpl<$Res>
    extends _$LiveListStateCopyWithImpl<$Res, _$LiveListStateErrorImpl>
    implements _$$LiveListStateErrorImplCopyWith<$Res> {
  __$$LiveListStateErrorImplCopyWithImpl(_$LiveListStateErrorImpl _value,
      $Res Function(_$LiveListStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$LiveListStateErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LiveListStateErrorImpl implements _LiveListStateError {
  const _$LiveListStateErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'LiveListState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveListStateErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveListStateErrorImplCopyWith<_$LiveListStateErrorImpl> get copyWith =>
      __$$LiveListStateErrorImplCopyWithImpl<_$LiveListStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(VehicleResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return error(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(VehicleResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return error?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(VehicleResponse data)? data,
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
    required TResult Function(_LiveListStateInitial value) initial,
    required TResult Function(_LiveListStateLoading value) loading,
    required TResult Function(_LiveListStateData value) data,
    required TResult Function(_LiveListStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LiveListStateInitial value)? initial,
    TResult? Function(_LiveListStateLoading value)? loading,
    TResult? Function(_LiveListStateData value)? data,
    TResult? Function(_LiveListStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LiveListStateInitial value)? initial,
    TResult Function(_LiveListStateLoading value)? loading,
    TResult Function(_LiveListStateData value)? data,
    TResult Function(_LiveListStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _LiveListStateError implements LiveListState {
  const factory _LiveListStateError(final String msg) =
      _$LiveListStateErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$LiveListStateErrorImplCopyWith<_$LiveListStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
