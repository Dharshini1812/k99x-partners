// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_kyc_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AddKycState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(KycSubmitResponse data) data,
    required TResult Function(String msg) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(KycSubmitResponse data)? data,
    TResult? Function(String msg)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(KycSubmitResponse data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_AddKycStateInitial value) initial,
    required TResult Function(_AddKycStateLoading value) loading,
    required TResult Function(_AddKycStateData value) data,
    required TResult Function(_AddKycStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddKycStateInitial value)? initial,
    TResult? Function(_AddKycStateLoading value)? loading,
    TResult? Function(_AddKycStateData value)? data,
    TResult? Function(_AddKycStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddKycStateInitial value)? initial,
    TResult Function(_AddKycStateLoading value)? loading,
    TResult Function(_AddKycStateData value)? data,
    TResult Function(_AddKycStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddKycStateCopyWith<$Res> {
  factory $AddKycStateCopyWith(
          AddKycState value, $Res Function(AddKycState) then) =
      _$AddKycStateCopyWithImpl<$Res, AddKycState>;
}

/// @nodoc
class _$AddKycStateCopyWithImpl<$Res, $Val extends AddKycState>
    implements $AddKycStateCopyWith<$Res> {
  _$AddKycStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AddKycStateInitialImplCopyWith<$Res> {
  factory _$$AddKycStateInitialImplCopyWith(_$AddKycStateInitialImpl value,
          $Res Function(_$AddKycStateInitialImpl) then) =
      __$$AddKycStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AddKycStateInitialImplCopyWithImpl<$Res>
    extends _$AddKycStateCopyWithImpl<$Res, _$AddKycStateInitialImpl>
    implements _$$AddKycStateInitialImplCopyWith<$Res> {
  __$$AddKycStateInitialImplCopyWithImpl(_$AddKycStateInitialImpl _value,
      $Res Function(_$AddKycStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AddKycStateInitialImpl implements _AddKycStateInitial {
  const _$AddKycStateInitialImpl();

  @override
  String toString() {
    return 'AddKycState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AddKycStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(KycSubmitResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(KycSubmitResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(KycSubmitResponse data)? data,
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
    required TResult Function(_AddKycStateInitial value) initial,
    required TResult Function(_AddKycStateLoading value) loading,
    required TResult Function(_AddKycStateData value) data,
    required TResult Function(_AddKycStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddKycStateInitial value)? initial,
    TResult? Function(_AddKycStateLoading value)? loading,
    TResult? Function(_AddKycStateData value)? data,
    TResult? Function(_AddKycStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddKycStateInitial value)? initial,
    TResult Function(_AddKycStateLoading value)? loading,
    TResult Function(_AddKycStateData value)? data,
    TResult Function(_AddKycStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _AddKycStateInitial implements AddKycState {
  const factory _AddKycStateInitial() = _$AddKycStateInitialImpl;
}

/// @nodoc
abstract class _$$AddKycStateLoadingImplCopyWith<$Res> {
  factory _$$AddKycStateLoadingImplCopyWith(_$AddKycStateLoadingImpl value,
          $Res Function(_$AddKycStateLoadingImpl) then) =
      __$$AddKycStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AddKycStateLoadingImplCopyWithImpl<$Res>
    extends _$AddKycStateCopyWithImpl<$Res, _$AddKycStateLoadingImpl>
    implements _$$AddKycStateLoadingImplCopyWith<$Res> {
  __$$AddKycStateLoadingImplCopyWithImpl(_$AddKycStateLoadingImpl _value,
      $Res Function(_$AddKycStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AddKycStateLoadingImpl implements _AddKycStateLoading {
  const _$AddKycStateLoadingImpl();

  @override
  String toString() {
    return 'AddKycState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AddKycStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(KycSubmitResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(KycSubmitResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(KycSubmitResponse data)? data,
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
    required TResult Function(_AddKycStateInitial value) initial,
    required TResult Function(_AddKycStateLoading value) loading,
    required TResult Function(_AddKycStateData value) data,
    required TResult Function(_AddKycStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddKycStateInitial value)? initial,
    TResult? Function(_AddKycStateLoading value)? loading,
    TResult? Function(_AddKycStateData value)? data,
    TResult? Function(_AddKycStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddKycStateInitial value)? initial,
    TResult Function(_AddKycStateLoading value)? loading,
    TResult Function(_AddKycStateData value)? data,
    TResult Function(_AddKycStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _AddKycStateLoading implements AddKycState {
  const factory _AddKycStateLoading() = _$AddKycStateLoadingImpl;
}

/// @nodoc
abstract class _$$AddKycStateDataImplCopyWith<$Res> {
  factory _$$AddKycStateDataImplCopyWith(_$AddKycStateDataImpl value,
          $Res Function(_$AddKycStateDataImpl) then) =
      __$$AddKycStateDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({KycSubmitResponse data});
}

/// @nodoc
class __$$AddKycStateDataImplCopyWithImpl<$Res>
    extends _$AddKycStateCopyWithImpl<$Res, _$AddKycStateDataImpl>
    implements _$$AddKycStateDataImplCopyWith<$Res> {
  __$$AddKycStateDataImplCopyWithImpl(
      _$AddKycStateDataImpl _value, $Res Function(_$AddKycStateDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$AddKycStateDataImpl(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as KycSubmitResponse,
    ));
  }
}

/// @nodoc

class _$AddKycStateDataImpl implements _AddKycStateData {
  const _$AddKycStateDataImpl(this.data);

  @override
  final KycSubmitResponse data;

  @override
  String toString() {
    return 'AddKycState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddKycStateDataImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddKycStateDataImplCopyWith<_$AddKycStateDataImpl> get copyWith =>
      __$$AddKycStateDataImplCopyWithImpl<_$AddKycStateDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(KycSubmitResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(KycSubmitResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(KycSubmitResponse data)? data,
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
    required TResult Function(_AddKycStateInitial value) initial,
    required TResult Function(_AddKycStateLoading value) loading,
    required TResult Function(_AddKycStateData value) data,
    required TResult Function(_AddKycStateError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddKycStateInitial value)? initial,
    TResult? Function(_AddKycStateLoading value)? loading,
    TResult? Function(_AddKycStateData value)? data,
    TResult? Function(_AddKycStateError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddKycStateInitial value)? initial,
    TResult Function(_AddKycStateLoading value)? loading,
    TResult Function(_AddKycStateData value)? data,
    TResult Function(_AddKycStateError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _AddKycStateData implements AddKycState {
  const factory _AddKycStateData(final KycSubmitResponse data) =
      _$AddKycStateDataImpl;

  KycSubmitResponse get data;
  @JsonKey(ignore: true)
  _$$AddKycStateDataImplCopyWith<_$AddKycStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AddKycStateErrorImplCopyWith<$Res> {
  factory _$$AddKycStateErrorImplCopyWith(_$AddKycStateErrorImpl value,
          $Res Function(_$AddKycStateErrorImpl) then) =
      __$$AddKycStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$AddKycStateErrorImplCopyWithImpl<$Res>
    extends _$AddKycStateCopyWithImpl<$Res, _$AddKycStateErrorImpl>
    implements _$$AddKycStateErrorImplCopyWith<$Res> {
  __$$AddKycStateErrorImplCopyWithImpl(_$AddKycStateErrorImpl _value,
      $Res Function(_$AddKycStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$AddKycStateErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AddKycStateErrorImpl implements _AddKycStateError {
  const _$AddKycStateErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'AddKycState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddKycStateErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddKycStateErrorImplCopyWith<_$AddKycStateErrorImpl> get copyWith =>
      __$$AddKycStateErrorImplCopyWithImpl<_$AddKycStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(KycSubmitResponse data) data,
    required TResult Function(String msg) error,
  }) {
    return error(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(KycSubmitResponse data)? data,
    TResult? Function(String msg)? error,
  }) {
    return error?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(KycSubmitResponse data)? data,
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
    required TResult Function(_AddKycStateInitial value) initial,
    required TResult Function(_AddKycStateLoading value) loading,
    required TResult Function(_AddKycStateData value) data,
    required TResult Function(_AddKycStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_AddKycStateInitial value)? initial,
    TResult? Function(_AddKycStateLoading value)? loading,
    TResult? Function(_AddKycStateData value)? data,
    TResult? Function(_AddKycStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_AddKycStateInitial value)? initial,
    TResult Function(_AddKycStateLoading value)? loading,
    TResult Function(_AddKycStateData value)? data,
    TResult Function(_AddKycStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _AddKycStateError implements AddKycState {
  const factory _AddKycStateError(final String msg) = _$AddKycStateErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$AddKycStateErrorImplCopyWith<_$AddKycStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
