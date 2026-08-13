// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UploadState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(UploadModel data) data,
    required TResult Function(String msg) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(UploadModel data)? data,
    TResult? Function(String msg)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(UploadModel data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_UploadStateInitial value) initial,
    required TResult Function(_UploadStateLoading value) loading,
    required TResult Function(_UploadStateData value) data,
    required TResult Function(_UploadStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UploadStateInitial value)? initial,
    TResult? Function(_UploadStateLoading value)? loading,
    TResult? Function(_UploadStateData value)? data,
    TResult? Function(_UploadStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UploadStateInitial value)? initial,
    TResult Function(_UploadStateLoading value)? loading,
    TResult Function(_UploadStateData value)? data,
    TResult Function(_UploadStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UploadStateCopyWith<$Res> {
  factory $UploadStateCopyWith(
          UploadState value, $Res Function(UploadState) then) =
      _$UploadStateCopyWithImpl<$Res, UploadState>;
}

/// @nodoc
class _$UploadStateCopyWithImpl<$Res, $Val extends UploadState>
    implements $UploadStateCopyWith<$Res> {
  _$UploadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$UploadStateInitialImplCopyWith<$Res> {
  factory _$$UploadStateInitialImplCopyWith(_$UploadStateInitialImpl value,
          $Res Function(_$UploadStateInitialImpl) then) =
      __$$UploadStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UploadStateInitialImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$UploadStateInitialImpl>
    implements _$$UploadStateInitialImplCopyWith<$Res> {
  __$$UploadStateInitialImplCopyWithImpl(_$UploadStateInitialImpl _value,
      $Res Function(_$UploadStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$UploadStateInitialImpl implements _UploadStateInitial {
  const _$UploadStateInitialImpl();

  @override
  String toString() {
    return 'UploadState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UploadStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(UploadModel data) data,
    required TResult Function(String msg) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(UploadModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(UploadModel data)? data,
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
    required TResult Function(_UploadStateInitial value) initial,
    required TResult Function(_UploadStateLoading value) loading,
    required TResult Function(_UploadStateData value) data,
    required TResult Function(_UploadStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UploadStateInitial value)? initial,
    TResult? Function(_UploadStateLoading value)? loading,
    TResult? Function(_UploadStateData value)? data,
    TResult? Function(_UploadStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UploadStateInitial value)? initial,
    TResult Function(_UploadStateLoading value)? loading,
    TResult Function(_UploadStateData value)? data,
    TResult Function(_UploadStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _UploadStateInitial implements UploadState {
  const factory _UploadStateInitial() = _$UploadStateInitialImpl;
}

/// @nodoc
abstract class _$$UploadStateLoadingImplCopyWith<$Res> {
  factory _$$UploadStateLoadingImplCopyWith(_$UploadStateLoadingImpl value,
          $Res Function(_$UploadStateLoadingImpl) then) =
      __$$UploadStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UploadStateLoadingImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$UploadStateLoadingImpl>
    implements _$$UploadStateLoadingImplCopyWith<$Res> {
  __$$UploadStateLoadingImplCopyWithImpl(_$UploadStateLoadingImpl _value,
      $Res Function(_$UploadStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$UploadStateLoadingImpl implements _UploadStateLoading {
  const _$UploadStateLoadingImpl();

  @override
  String toString() {
    return 'UploadState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UploadStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(UploadModel data) data,
    required TResult Function(String msg) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(UploadModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(UploadModel data)? data,
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
    required TResult Function(_UploadStateInitial value) initial,
    required TResult Function(_UploadStateLoading value) loading,
    required TResult Function(_UploadStateData value) data,
    required TResult Function(_UploadStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UploadStateInitial value)? initial,
    TResult? Function(_UploadStateLoading value)? loading,
    TResult? Function(_UploadStateData value)? data,
    TResult? Function(_UploadStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UploadStateInitial value)? initial,
    TResult Function(_UploadStateLoading value)? loading,
    TResult Function(_UploadStateData value)? data,
    TResult Function(_UploadStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _UploadStateLoading implements UploadState {
  const factory _UploadStateLoading() = _$UploadStateLoadingImpl;
}

/// @nodoc
abstract class _$$UploadStateDataImplCopyWith<$Res> {
  factory _$$UploadStateDataImplCopyWith(_$UploadStateDataImpl value,
          $Res Function(_$UploadStateDataImpl) then) =
      __$$UploadStateDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({UploadModel data});
}

/// @nodoc
class __$$UploadStateDataImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$UploadStateDataImpl>
    implements _$$UploadStateDataImplCopyWith<$Res> {
  __$$UploadStateDataImplCopyWithImpl(
      _$UploadStateDataImpl _value, $Res Function(_$UploadStateDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$UploadStateDataImpl(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UploadModel,
    ));
  }
}

/// @nodoc

class _$UploadStateDataImpl implements _UploadStateData {
  const _$UploadStateDataImpl(this.data);

  @override
  final UploadModel data;

  @override
  String toString() {
    return 'UploadState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadStateDataImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadStateDataImplCopyWith<_$UploadStateDataImpl> get copyWith =>
      __$$UploadStateDataImplCopyWithImpl<_$UploadStateDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(UploadModel data) data,
    required TResult Function(String msg) error,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(UploadModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(UploadModel data)? data,
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
    required TResult Function(_UploadStateInitial value) initial,
    required TResult Function(_UploadStateLoading value) loading,
    required TResult Function(_UploadStateData value) data,
    required TResult Function(_UploadStateError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UploadStateInitial value)? initial,
    TResult? Function(_UploadStateLoading value)? loading,
    TResult? Function(_UploadStateData value)? data,
    TResult? Function(_UploadStateError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UploadStateInitial value)? initial,
    TResult Function(_UploadStateLoading value)? loading,
    TResult Function(_UploadStateData value)? data,
    TResult Function(_UploadStateError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _UploadStateData implements UploadState {
  const factory _UploadStateData(final UploadModel data) =
      _$UploadStateDataImpl;

  UploadModel get data;
  @JsonKey(ignore: true)
  _$$UploadStateDataImplCopyWith<_$UploadStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UploadStateErrorImplCopyWith<$Res> {
  factory _$$UploadStateErrorImplCopyWith(_$UploadStateErrorImpl value,
          $Res Function(_$UploadStateErrorImpl) then) =
      __$$UploadStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$UploadStateErrorImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$UploadStateErrorImpl>
    implements _$$UploadStateErrorImplCopyWith<$Res> {
  __$$UploadStateErrorImplCopyWithImpl(_$UploadStateErrorImpl _value,
      $Res Function(_$UploadStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$UploadStateErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UploadStateErrorImpl implements _UploadStateError {
  const _$UploadStateErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'UploadState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadStateErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadStateErrorImplCopyWith<_$UploadStateErrorImpl> get copyWith =>
      __$$UploadStateErrorImplCopyWithImpl<_$UploadStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(UploadModel data) data,
    required TResult Function(String msg) error,
  }) {
    return error(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(UploadModel data)? data,
    TResult? Function(String msg)? error,
  }) {
    return error?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(UploadModel data)? data,
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
    required TResult Function(_UploadStateInitial value) initial,
    required TResult Function(_UploadStateLoading value) loading,
    required TResult Function(_UploadStateData value) data,
    required TResult Function(_UploadStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_UploadStateInitial value)? initial,
    TResult? Function(_UploadStateLoading value)? loading,
    TResult? Function(_UploadStateData value)? data,
    TResult? Function(_UploadStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_UploadStateInitial value)? initial,
    TResult Function(_UploadStateLoading value)? loading,
    TResult Function(_UploadStateData value)? data,
    TResult Function(_UploadStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _UploadStateError implements UploadState {
  const factory _UploadStateError(final String msg) = _$UploadStateErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$UploadStateErrorImplCopyWith<_$UploadStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
