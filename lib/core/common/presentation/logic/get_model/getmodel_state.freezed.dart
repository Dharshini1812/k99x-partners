// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'getmodel_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GetModelState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ModelModel> data) data,
    required TResult Function(String msg) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ModelModel> data)? data,
    TResult? Function(String msg)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ModelModel> data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GetModelStateInitial value) initial,
    required TResult Function(_GetModelStateLoading value) loading,
    required TResult Function(_GetModelStateData value) data,
    required TResult Function(_GetModelStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetModelStateInitial value)? initial,
    TResult? Function(_GetModelStateLoading value)? loading,
    TResult? Function(_GetModelStateData value)? data,
    TResult? Function(_GetModelStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetModelStateInitial value)? initial,
    TResult Function(_GetModelStateLoading value)? loading,
    TResult Function(_GetModelStateData value)? data,
    TResult Function(_GetModelStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetModelStateCopyWith<$Res> {
  factory $GetModelStateCopyWith(
          GetModelState value, $Res Function(GetModelState) then) =
      _$GetModelStateCopyWithImpl<$Res, GetModelState>;
}

/// @nodoc
class _$GetModelStateCopyWithImpl<$Res, $Val extends GetModelState>
    implements $GetModelStateCopyWith<$Res> {
  _$GetModelStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$GetModelStateInitialImplCopyWith<$Res> {
  factory _$$GetModelStateInitialImplCopyWith(_$GetModelStateInitialImpl value,
          $Res Function(_$GetModelStateInitialImpl) then) =
      __$$GetModelStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GetModelStateInitialImplCopyWithImpl<$Res>
    extends _$GetModelStateCopyWithImpl<$Res, _$GetModelStateInitialImpl>
    implements _$$GetModelStateInitialImplCopyWith<$Res> {
  __$$GetModelStateInitialImplCopyWithImpl(_$GetModelStateInitialImpl _value,
      $Res Function(_$GetModelStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$GetModelStateInitialImpl implements _GetModelStateInitial {
  const _$GetModelStateInitialImpl();

  @override
  String toString() {
    return 'GetModelState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetModelStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ModelModel> data) data,
    required TResult Function(String msg) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ModelModel> data)? data,
    TResult? Function(String msg)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ModelModel> data)? data,
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
    required TResult Function(_GetModelStateInitial value) initial,
    required TResult Function(_GetModelStateLoading value) loading,
    required TResult Function(_GetModelStateData value) data,
    required TResult Function(_GetModelStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetModelStateInitial value)? initial,
    TResult? Function(_GetModelStateLoading value)? loading,
    TResult? Function(_GetModelStateData value)? data,
    TResult? Function(_GetModelStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetModelStateInitial value)? initial,
    TResult Function(_GetModelStateLoading value)? loading,
    TResult Function(_GetModelStateData value)? data,
    TResult Function(_GetModelStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _GetModelStateInitial implements GetModelState {
  const factory _GetModelStateInitial() = _$GetModelStateInitialImpl;
}

/// @nodoc
abstract class _$$GetModelStateLoadingImplCopyWith<$Res> {
  factory _$$GetModelStateLoadingImplCopyWith(_$GetModelStateLoadingImpl value,
          $Res Function(_$GetModelStateLoadingImpl) then) =
      __$$GetModelStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GetModelStateLoadingImplCopyWithImpl<$Res>
    extends _$GetModelStateCopyWithImpl<$Res, _$GetModelStateLoadingImpl>
    implements _$$GetModelStateLoadingImplCopyWith<$Res> {
  __$$GetModelStateLoadingImplCopyWithImpl(_$GetModelStateLoadingImpl _value,
      $Res Function(_$GetModelStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$GetModelStateLoadingImpl implements _GetModelStateLoading {
  const _$GetModelStateLoadingImpl();

  @override
  String toString() {
    return 'GetModelState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetModelStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ModelModel> data) data,
    required TResult Function(String msg) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ModelModel> data)? data,
    TResult? Function(String msg)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ModelModel> data)? data,
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
    required TResult Function(_GetModelStateInitial value) initial,
    required TResult Function(_GetModelStateLoading value) loading,
    required TResult Function(_GetModelStateData value) data,
    required TResult Function(_GetModelStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetModelStateInitial value)? initial,
    TResult? Function(_GetModelStateLoading value)? loading,
    TResult? Function(_GetModelStateData value)? data,
    TResult? Function(_GetModelStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetModelStateInitial value)? initial,
    TResult Function(_GetModelStateLoading value)? loading,
    TResult Function(_GetModelStateData value)? data,
    TResult Function(_GetModelStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _GetModelStateLoading implements GetModelState {
  const factory _GetModelStateLoading() = _$GetModelStateLoadingImpl;
}

/// @nodoc
abstract class _$$GetModelStateDataImplCopyWith<$Res> {
  factory _$$GetModelStateDataImplCopyWith(_$GetModelStateDataImpl value,
          $Res Function(_$GetModelStateDataImpl) then) =
      __$$GetModelStateDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<ModelModel> data});
}

/// @nodoc
class __$$GetModelStateDataImplCopyWithImpl<$Res>
    extends _$GetModelStateCopyWithImpl<$Res, _$GetModelStateDataImpl>
    implements _$$GetModelStateDataImplCopyWith<$Res> {
  __$$GetModelStateDataImplCopyWithImpl(_$GetModelStateDataImpl _value,
      $Res Function(_$GetModelStateDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$GetModelStateDataImpl(
      null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<ModelModel>,
    ));
  }
}

/// @nodoc

class _$GetModelStateDataImpl implements _GetModelStateData {
  const _$GetModelStateDataImpl(final List<ModelModel> data) : _data = data;

  final List<ModelModel> _data;
  @override
  List<ModelModel> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'GetModelState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetModelStateDataImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetModelStateDataImplCopyWith<_$GetModelStateDataImpl> get copyWith =>
      __$$GetModelStateDataImplCopyWithImpl<_$GetModelStateDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ModelModel> data) data,
    required TResult Function(String msg) error,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ModelModel> data)? data,
    TResult? Function(String msg)? error,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ModelModel> data)? data,
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
    required TResult Function(_GetModelStateInitial value) initial,
    required TResult Function(_GetModelStateLoading value) loading,
    required TResult Function(_GetModelStateData value) data,
    required TResult Function(_GetModelStateError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetModelStateInitial value)? initial,
    TResult? Function(_GetModelStateLoading value)? loading,
    TResult? Function(_GetModelStateData value)? data,
    TResult? Function(_GetModelStateError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetModelStateInitial value)? initial,
    TResult Function(_GetModelStateLoading value)? loading,
    TResult Function(_GetModelStateData value)? data,
    TResult Function(_GetModelStateError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _GetModelStateData implements GetModelState {
  const factory _GetModelStateData(final List<ModelModel> data) =
      _$GetModelStateDataImpl;

  List<ModelModel> get data;
  @JsonKey(ignore: true)
  _$$GetModelStateDataImplCopyWith<_$GetModelStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetModelStateErrorImplCopyWith<$Res> {
  factory _$$GetModelStateErrorImplCopyWith(_$GetModelStateErrorImpl value,
          $Res Function(_$GetModelStateErrorImpl) then) =
      __$$GetModelStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$GetModelStateErrorImplCopyWithImpl<$Res>
    extends _$GetModelStateCopyWithImpl<$Res, _$GetModelStateErrorImpl>
    implements _$$GetModelStateErrorImplCopyWith<$Res> {
  __$$GetModelStateErrorImplCopyWithImpl(_$GetModelStateErrorImpl _value,
      $Res Function(_$GetModelStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$GetModelStateErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetModelStateErrorImpl implements _GetModelStateError {
  const _$GetModelStateErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'GetModelState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetModelStateErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetModelStateErrorImplCopyWith<_$GetModelStateErrorImpl> get copyWith =>
      __$$GetModelStateErrorImplCopyWithImpl<_$GetModelStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ModelModel> data) data,
    required TResult Function(String msg) error,
  }) {
    return error(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ModelModel> data)? data,
    TResult? Function(String msg)? error,
  }) {
    return error?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ModelModel> data)? data,
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
    required TResult Function(_GetModelStateInitial value) initial,
    required TResult Function(_GetModelStateLoading value) loading,
    required TResult Function(_GetModelStateData value) data,
    required TResult Function(_GetModelStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetModelStateInitial value)? initial,
    TResult? Function(_GetModelStateLoading value)? loading,
    TResult? Function(_GetModelStateData value)? data,
    TResult? Function(_GetModelStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetModelStateInitial value)? initial,
    TResult Function(_GetModelStateLoading value)? loading,
    TResult Function(_GetModelStateData value)? data,
    TResult Function(_GetModelStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _GetModelStateError implements GetModelState {
  const factory _GetModelStateError(final String msg) =
      _$GetModelStateErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$GetModelStateErrorImplCopyWith<_$GetModelStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
