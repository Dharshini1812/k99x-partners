// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'getmake_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GetMakeState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<MakeModel> data) data,
    required TResult Function(String msg) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<MakeModel> data)? data,
    TResult? Function(String msg)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<MakeModel> data)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GetMakeStateInitial value) initial,
    required TResult Function(_GetMakeStateLoading value) loading,
    required TResult Function(_GetMakeStateData value) data,
    required TResult Function(_GetMakeStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetMakeStateInitial value)? initial,
    TResult? Function(_GetMakeStateLoading value)? loading,
    TResult? Function(_GetMakeStateData value)? data,
    TResult? Function(_GetMakeStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetMakeStateInitial value)? initial,
    TResult Function(_GetMakeStateLoading value)? loading,
    TResult Function(_GetMakeStateData value)? data,
    TResult Function(_GetMakeStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetMakeStateCopyWith<$Res> {
  factory $GetMakeStateCopyWith(
          GetMakeState value, $Res Function(GetMakeState) then) =
      _$GetMakeStateCopyWithImpl<$Res, GetMakeState>;
}

/// @nodoc
class _$GetMakeStateCopyWithImpl<$Res, $Val extends GetMakeState>
    implements $GetMakeStateCopyWith<$Res> {
  _$GetMakeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$GetMakeStateInitialImplCopyWith<$Res> {
  factory _$$GetMakeStateInitialImplCopyWith(_$GetMakeStateInitialImpl value,
          $Res Function(_$GetMakeStateInitialImpl) then) =
      __$$GetMakeStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GetMakeStateInitialImplCopyWithImpl<$Res>
    extends _$GetMakeStateCopyWithImpl<$Res, _$GetMakeStateInitialImpl>
    implements _$$GetMakeStateInitialImplCopyWith<$Res> {
  __$$GetMakeStateInitialImplCopyWithImpl(_$GetMakeStateInitialImpl _value,
      $Res Function(_$GetMakeStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$GetMakeStateInitialImpl implements _GetMakeStateInitial {
  const _$GetMakeStateInitialImpl();

  @override
  String toString() {
    return 'GetMakeState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMakeStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<MakeModel> data) data,
    required TResult Function(String msg) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<MakeModel> data)? data,
    TResult? Function(String msg)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<MakeModel> data)? data,
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
    required TResult Function(_GetMakeStateInitial value) initial,
    required TResult Function(_GetMakeStateLoading value) loading,
    required TResult Function(_GetMakeStateData value) data,
    required TResult Function(_GetMakeStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetMakeStateInitial value)? initial,
    TResult? Function(_GetMakeStateLoading value)? loading,
    TResult? Function(_GetMakeStateData value)? data,
    TResult? Function(_GetMakeStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetMakeStateInitial value)? initial,
    TResult Function(_GetMakeStateLoading value)? loading,
    TResult Function(_GetMakeStateData value)? data,
    TResult Function(_GetMakeStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _GetMakeStateInitial implements GetMakeState {
  const factory _GetMakeStateInitial() = _$GetMakeStateInitialImpl;
}

/// @nodoc
abstract class _$$GetMakeStateLoadingImplCopyWith<$Res> {
  factory _$$GetMakeStateLoadingImplCopyWith(_$GetMakeStateLoadingImpl value,
          $Res Function(_$GetMakeStateLoadingImpl) then) =
      __$$GetMakeStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GetMakeStateLoadingImplCopyWithImpl<$Res>
    extends _$GetMakeStateCopyWithImpl<$Res, _$GetMakeStateLoadingImpl>
    implements _$$GetMakeStateLoadingImplCopyWith<$Res> {
  __$$GetMakeStateLoadingImplCopyWithImpl(_$GetMakeStateLoadingImpl _value,
      $Res Function(_$GetMakeStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$GetMakeStateLoadingImpl implements _GetMakeStateLoading {
  const _$GetMakeStateLoadingImpl();

  @override
  String toString() {
    return 'GetMakeState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMakeStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<MakeModel> data) data,
    required TResult Function(String msg) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<MakeModel> data)? data,
    TResult? Function(String msg)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<MakeModel> data)? data,
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
    required TResult Function(_GetMakeStateInitial value) initial,
    required TResult Function(_GetMakeStateLoading value) loading,
    required TResult Function(_GetMakeStateData value) data,
    required TResult Function(_GetMakeStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetMakeStateInitial value)? initial,
    TResult? Function(_GetMakeStateLoading value)? loading,
    TResult? Function(_GetMakeStateData value)? data,
    TResult? Function(_GetMakeStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetMakeStateInitial value)? initial,
    TResult Function(_GetMakeStateLoading value)? loading,
    TResult Function(_GetMakeStateData value)? data,
    TResult Function(_GetMakeStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _GetMakeStateLoading implements GetMakeState {
  const factory _GetMakeStateLoading() = _$GetMakeStateLoadingImpl;
}

/// @nodoc
abstract class _$$GetMakeStateDataImplCopyWith<$Res> {
  factory _$$GetMakeStateDataImplCopyWith(_$GetMakeStateDataImpl value,
          $Res Function(_$GetMakeStateDataImpl) then) =
      __$$GetMakeStateDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<MakeModel> data});
}

/// @nodoc
class __$$GetMakeStateDataImplCopyWithImpl<$Res>
    extends _$GetMakeStateCopyWithImpl<$Res, _$GetMakeStateDataImpl>
    implements _$$GetMakeStateDataImplCopyWith<$Res> {
  __$$GetMakeStateDataImplCopyWithImpl(_$GetMakeStateDataImpl _value,
      $Res Function(_$GetMakeStateDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$GetMakeStateDataImpl(
      null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<MakeModel>,
    ));
  }
}

/// @nodoc

class _$GetMakeStateDataImpl implements _GetMakeStateData {
  const _$GetMakeStateDataImpl(final List<MakeModel> data) : _data = data;

  final List<MakeModel> _data;
  @override
  List<MakeModel> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'GetMakeState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMakeStateDataImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMakeStateDataImplCopyWith<_$GetMakeStateDataImpl> get copyWith =>
      __$$GetMakeStateDataImplCopyWithImpl<_$GetMakeStateDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<MakeModel> data) data,
    required TResult Function(String msg) error,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<MakeModel> data)? data,
    TResult? Function(String msg)? error,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<MakeModel> data)? data,
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
    required TResult Function(_GetMakeStateInitial value) initial,
    required TResult Function(_GetMakeStateLoading value) loading,
    required TResult Function(_GetMakeStateData value) data,
    required TResult Function(_GetMakeStateError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetMakeStateInitial value)? initial,
    TResult? Function(_GetMakeStateLoading value)? loading,
    TResult? Function(_GetMakeStateData value)? data,
    TResult? Function(_GetMakeStateError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetMakeStateInitial value)? initial,
    TResult Function(_GetMakeStateLoading value)? loading,
    TResult Function(_GetMakeStateData value)? data,
    TResult Function(_GetMakeStateError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _GetMakeStateData implements GetMakeState {
  const factory _GetMakeStateData(final List<MakeModel> data) =
      _$GetMakeStateDataImpl;

  List<MakeModel> get data;
  @JsonKey(ignore: true)
  _$$GetMakeStateDataImplCopyWith<_$GetMakeStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetMakeStateErrorImplCopyWith<$Res> {
  factory _$$GetMakeStateErrorImplCopyWith(_$GetMakeStateErrorImpl value,
          $Res Function(_$GetMakeStateErrorImpl) then) =
      __$$GetMakeStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$GetMakeStateErrorImplCopyWithImpl<$Res>
    extends _$GetMakeStateCopyWithImpl<$Res, _$GetMakeStateErrorImpl>
    implements _$$GetMakeStateErrorImplCopyWith<$Res> {
  __$$GetMakeStateErrorImplCopyWithImpl(_$GetMakeStateErrorImpl _value,
      $Res Function(_$GetMakeStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$GetMakeStateErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$GetMakeStateErrorImpl implements _GetMakeStateError {
  const _$GetMakeStateErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'GetMakeState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetMakeStateErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetMakeStateErrorImplCopyWith<_$GetMakeStateErrorImpl> get copyWith =>
      __$$GetMakeStateErrorImplCopyWithImpl<_$GetMakeStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<MakeModel> data) data,
    required TResult Function(String msg) error,
  }) {
    return error(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<MakeModel> data)? data,
    TResult? Function(String msg)? error,
  }) {
    return error?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<MakeModel> data)? data,
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
    required TResult Function(_GetMakeStateInitial value) initial,
    required TResult Function(_GetMakeStateLoading value) loading,
    required TResult Function(_GetMakeStateData value) data,
    required TResult Function(_GetMakeStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GetMakeStateInitial value)? initial,
    TResult? Function(_GetMakeStateLoading value)? loading,
    TResult? Function(_GetMakeStateData value)? data,
    TResult? Function(_GetMakeStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GetMakeStateInitial value)? initial,
    TResult Function(_GetMakeStateLoading value)? loading,
    TResult Function(_GetMakeStateData value)? data,
    TResult Function(_GetMakeStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _GetMakeStateError implements GetMakeState {
  const factory _GetMakeStateError(final String msg) = _$GetMakeStateErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$GetMakeStateErrorImplCopyWith<_$GetMakeStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
