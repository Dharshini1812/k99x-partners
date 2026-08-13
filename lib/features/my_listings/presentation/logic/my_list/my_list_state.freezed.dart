// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MyListState {
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
    required TResult Function(_MyListStateInitial value) initial,
    required TResult Function(_MyListStateLoading value) loading,
    required TResult Function(_MyListStateData value) data,
    required TResult Function(_MyListStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MyListStateInitial value)? initial,
    TResult? Function(_MyListStateLoading value)? loading,
    TResult? Function(_MyListStateData value)? data,
    TResult? Function(_MyListStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MyListStateInitial value)? initial,
    TResult Function(_MyListStateLoading value)? loading,
    TResult Function(_MyListStateData value)? data,
    TResult Function(_MyListStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyListStateCopyWith<$Res> {
  factory $MyListStateCopyWith(
          MyListState value, $Res Function(MyListState) then) =
      _$MyListStateCopyWithImpl<$Res, MyListState>;
}

/// @nodoc
class _$MyListStateCopyWithImpl<$Res, $Val extends MyListState>
    implements $MyListStateCopyWith<$Res> {
  _$MyListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$MyListStateInitialImplCopyWith<$Res> {
  factory _$$MyListStateInitialImplCopyWith(_$MyListStateInitialImpl value,
          $Res Function(_$MyListStateInitialImpl) then) =
      __$$MyListStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MyListStateInitialImplCopyWithImpl<$Res>
    extends _$MyListStateCopyWithImpl<$Res, _$MyListStateInitialImpl>
    implements _$$MyListStateInitialImplCopyWith<$Res> {
  __$$MyListStateInitialImplCopyWithImpl(_$MyListStateInitialImpl _value,
      $Res Function(_$MyListStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MyListStateInitialImpl implements _MyListStateInitial {
  const _$MyListStateInitialImpl();

  @override
  String toString() {
    return 'MyListState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MyListStateInitialImpl);
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
    required TResult Function(_MyListStateInitial value) initial,
    required TResult Function(_MyListStateLoading value) loading,
    required TResult Function(_MyListStateData value) data,
    required TResult Function(_MyListStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MyListStateInitial value)? initial,
    TResult? Function(_MyListStateLoading value)? loading,
    TResult? Function(_MyListStateData value)? data,
    TResult? Function(_MyListStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MyListStateInitial value)? initial,
    TResult Function(_MyListStateLoading value)? loading,
    TResult Function(_MyListStateData value)? data,
    TResult Function(_MyListStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _MyListStateInitial implements MyListState {
  const factory _MyListStateInitial() = _$MyListStateInitialImpl;
}

/// @nodoc
abstract class _$$MyListStateLoadingImplCopyWith<$Res> {
  factory _$$MyListStateLoadingImplCopyWith(_$MyListStateLoadingImpl value,
          $Res Function(_$MyListStateLoadingImpl) then) =
      __$$MyListStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$MyListStateLoadingImplCopyWithImpl<$Res>
    extends _$MyListStateCopyWithImpl<$Res, _$MyListStateLoadingImpl>
    implements _$$MyListStateLoadingImplCopyWith<$Res> {
  __$$MyListStateLoadingImplCopyWithImpl(_$MyListStateLoadingImpl _value,
      $Res Function(_$MyListStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$MyListStateLoadingImpl implements _MyListStateLoading {
  const _$MyListStateLoadingImpl();

  @override
  String toString() {
    return 'MyListState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$MyListStateLoadingImpl);
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
    required TResult Function(_MyListStateInitial value) initial,
    required TResult Function(_MyListStateLoading value) loading,
    required TResult Function(_MyListStateData value) data,
    required TResult Function(_MyListStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MyListStateInitial value)? initial,
    TResult? Function(_MyListStateLoading value)? loading,
    TResult? Function(_MyListStateData value)? data,
    TResult? Function(_MyListStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MyListStateInitial value)? initial,
    TResult Function(_MyListStateLoading value)? loading,
    TResult Function(_MyListStateData value)? data,
    TResult Function(_MyListStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _MyListStateLoading implements MyListState {
  const factory _MyListStateLoading() = _$MyListStateLoadingImpl;
}

/// @nodoc
abstract class _$$MyListStateDataImplCopyWith<$Res> {
  factory _$$MyListStateDataImplCopyWith(_$MyListStateDataImpl value,
          $Res Function(_$MyListStateDataImpl) then) =
      __$$MyListStateDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({VehicleResponse data});
}

/// @nodoc
class __$$MyListStateDataImplCopyWithImpl<$Res>
    extends _$MyListStateCopyWithImpl<$Res, _$MyListStateDataImpl>
    implements _$$MyListStateDataImplCopyWith<$Res> {
  __$$MyListStateDataImplCopyWithImpl(
      _$MyListStateDataImpl _value, $Res Function(_$MyListStateDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$MyListStateDataImpl(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as VehicleResponse,
    ));
  }
}

/// @nodoc

class _$MyListStateDataImpl implements _MyListStateData {
  const _$MyListStateDataImpl(this.data);

  @override
  final VehicleResponse data;

  @override
  String toString() {
    return 'MyListState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyListStateDataImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MyListStateDataImplCopyWith<_$MyListStateDataImpl> get copyWith =>
      __$$MyListStateDataImplCopyWithImpl<_$MyListStateDataImpl>(
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
    required TResult Function(_MyListStateInitial value) initial,
    required TResult Function(_MyListStateLoading value) loading,
    required TResult Function(_MyListStateData value) data,
    required TResult Function(_MyListStateError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MyListStateInitial value)? initial,
    TResult? Function(_MyListStateLoading value)? loading,
    TResult? Function(_MyListStateData value)? data,
    TResult? Function(_MyListStateError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MyListStateInitial value)? initial,
    TResult Function(_MyListStateLoading value)? loading,
    TResult Function(_MyListStateData value)? data,
    TResult Function(_MyListStateError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _MyListStateData implements MyListState {
  const factory _MyListStateData(final VehicleResponse data) =
      _$MyListStateDataImpl;

  VehicleResponse get data;
  @JsonKey(ignore: true)
  _$$MyListStateDataImplCopyWith<_$MyListStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MyListStateErrorImplCopyWith<$Res> {
  factory _$$MyListStateErrorImplCopyWith(_$MyListStateErrorImpl value,
          $Res Function(_$MyListStateErrorImpl) then) =
      __$$MyListStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$MyListStateErrorImplCopyWithImpl<$Res>
    extends _$MyListStateCopyWithImpl<$Res, _$MyListStateErrorImpl>
    implements _$$MyListStateErrorImplCopyWith<$Res> {
  __$$MyListStateErrorImplCopyWithImpl(_$MyListStateErrorImpl _value,
      $Res Function(_$MyListStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$MyListStateErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MyListStateErrorImpl implements _MyListStateError {
  const _$MyListStateErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'MyListState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyListStateErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MyListStateErrorImplCopyWith<_$MyListStateErrorImpl> get copyWith =>
      __$$MyListStateErrorImplCopyWithImpl<_$MyListStateErrorImpl>(
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
    required TResult Function(_MyListStateInitial value) initial,
    required TResult Function(_MyListStateLoading value) loading,
    required TResult Function(_MyListStateData value) data,
    required TResult Function(_MyListStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_MyListStateInitial value)? initial,
    TResult? Function(_MyListStateLoading value)? loading,
    TResult? Function(_MyListStateData value)? data,
    TResult? Function(_MyListStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_MyListStateInitial value)? initial,
    TResult Function(_MyListStateLoading value)? loading,
    TResult Function(_MyListStateData value)? data,
    TResult Function(_MyListStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _MyListStateError implements MyListState {
  const factory _MyListStateError(final String msg) = _$MyListStateErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$MyListStateErrorImplCopyWith<_$MyListStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
