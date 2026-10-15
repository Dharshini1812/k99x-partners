// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_events_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LiveEventState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(EventResponseModel events) data,
    required TResult Function(String msg) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(EventResponseModel events)? data,
    TResult? Function(String msg)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(EventResponseModel events)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LiveEventStateInitial value) initial,
    required TResult Function(_LiveEventStateLoading value) loading,
    required TResult Function(_LiveEventStateData value) data,
    required TResult Function(_LiveEventStateError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LiveEventStateInitial value)? initial,
    TResult? Function(_LiveEventStateLoading value)? loading,
    TResult? Function(_LiveEventStateData value)? data,
    TResult? Function(_LiveEventStateError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LiveEventStateInitial value)? initial,
    TResult Function(_LiveEventStateLoading value)? loading,
    TResult Function(_LiveEventStateData value)? data,
    TResult Function(_LiveEventStateError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveEventStateCopyWith<$Res> {
  factory $LiveEventStateCopyWith(
          LiveEventState value, $Res Function(LiveEventState) then) =
      _$LiveEventStateCopyWithImpl<$Res, LiveEventState>;
}

/// @nodoc
class _$LiveEventStateCopyWithImpl<$Res, $Val extends LiveEventState>
    implements $LiveEventStateCopyWith<$Res> {
  _$LiveEventStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LiveEventStateInitialImplCopyWith<$Res> {
  factory _$$LiveEventStateInitialImplCopyWith(
          _$LiveEventStateInitialImpl value,
          $Res Function(_$LiveEventStateInitialImpl) then) =
      __$$LiveEventStateInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LiveEventStateInitialImplCopyWithImpl<$Res>
    extends _$LiveEventStateCopyWithImpl<$Res, _$LiveEventStateInitialImpl>
    implements _$$LiveEventStateInitialImplCopyWith<$Res> {
  __$$LiveEventStateInitialImplCopyWithImpl(_$LiveEventStateInitialImpl _value,
      $Res Function(_$LiveEventStateInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LiveEventStateInitialImpl implements _LiveEventStateInitial {
  const _$LiveEventStateInitialImpl();

  @override
  String toString() {
    return 'LiveEventState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveEventStateInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(EventResponseModel events) data,
    required TResult Function(String msg) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(EventResponseModel events)? data,
    TResult? Function(String msg)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(EventResponseModel events)? data,
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
    required TResult Function(_LiveEventStateInitial value) initial,
    required TResult Function(_LiveEventStateLoading value) loading,
    required TResult Function(_LiveEventStateData value) data,
    required TResult Function(_LiveEventStateError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LiveEventStateInitial value)? initial,
    TResult? Function(_LiveEventStateLoading value)? loading,
    TResult? Function(_LiveEventStateData value)? data,
    TResult? Function(_LiveEventStateError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LiveEventStateInitial value)? initial,
    TResult Function(_LiveEventStateLoading value)? loading,
    TResult Function(_LiveEventStateData value)? data,
    TResult Function(_LiveEventStateError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _LiveEventStateInitial implements LiveEventState {
  const factory _LiveEventStateInitial() = _$LiveEventStateInitialImpl;
}

/// @nodoc
abstract class _$$LiveEventStateLoadingImplCopyWith<$Res> {
  factory _$$LiveEventStateLoadingImplCopyWith(
          _$LiveEventStateLoadingImpl value,
          $Res Function(_$LiveEventStateLoadingImpl) then) =
      __$$LiveEventStateLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LiveEventStateLoadingImplCopyWithImpl<$Res>
    extends _$LiveEventStateCopyWithImpl<$Res, _$LiveEventStateLoadingImpl>
    implements _$$LiveEventStateLoadingImplCopyWith<$Res> {
  __$$LiveEventStateLoadingImplCopyWithImpl(_$LiveEventStateLoadingImpl _value,
      $Res Function(_$LiveEventStateLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LiveEventStateLoadingImpl implements _LiveEventStateLoading {
  const _$LiveEventStateLoadingImpl();

  @override
  String toString() {
    return 'LiveEventState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveEventStateLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(EventResponseModel events) data,
    required TResult Function(String msg) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(EventResponseModel events)? data,
    TResult? Function(String msg)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(EventResponseModel events)? data,
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
    required TResult Function(_LiveEventStateInitial value) initial,
    required TResult Function(_LiveEventStateLoading value) loading,
    required TResult Function(_LiveEventStateData value) data,
    required TResult Function(_LiveEventStateError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LiveEventStateInitial value)? initial,
    TResult? Function(_LiveEventStateLoading value)? loading,
    TResult? Function(_LiveEventStateData value)? data,
    TResult? Function(_LiveEventStateError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LiveEventStateInitial value)? initial,
    TResult Function(_LiveEventStateLoading value)? loading,
    TResult Function(_LiveEventStateData value)? data,
    TResult Function(_LiveEventStateError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _LiveEventStateLoading implements LiveEventState {
  const factory _LiveEventStateLoading() = _$LiveEventStateLoadingImpl;
}

/// @nodoc
abstract class _$$LiveEventStateDataImplCopyWith<$Res> {
  factory _$$LiveEventStateDataImplCopyWith(_$LiveEventStateDataImpl value,
          $Res Function(_$LiveEventStateDataImpl) then) =
      __$$LiveEventStateDataImplCopyWithImpl<$Res>;
  @useResult
  $Res call({EventResponseModel events});
}

/// @nodoc
class __$$LiveEventStateDataImplCopyWithImpl<$Res>
    extends _$LiveEventStateCopyWithImpl<$Res, _$LiveEventStateDataImpl>
    implements _$$LiveEventStateDataImplCopyWith<$Res> {
  __$$LiveEventStateDataImplCopyWithImpl(_$LiveEventStateDataImpl _value,
      $Res Function(_$LiveEventStateDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? events = null,
  }) {
    return _then(_$LiveEventStateDataImpl(
      null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as EventResponseModel,
    ));
  }
}

/// @nodoc

class _$LiveEventStateDataImpl implements _LiveEventStateData {
  const _$LiveEventStateDataImpl(this.events);

  @override
  final EventResponseModel events;

  @override
  String toString() {
    return 'LiveEventState.data(events: $events)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveEventStateDataImpl &&
            (identical(other.events, events) || other.events == events));
  }

  @override
  int get hashCode => Object.hash(runtimeType, events);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveEventStateDataImplCopyWith<_$LiveEventStateDataImpl> get copyWith =>
      __$$LiveEventStateDataImplCopyWithImpl<_$LiveEventStateDataImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(EventResponseModel events) data,
    required TResult Function(String msg) error,
  }) {
    return data(events);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(EventResponseModel events)? data,
    TResult? Function(String msg)? error,
  }) {
    return data?.call(events);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(EventResponseModel events)? data,
    TResult Function(String msg)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(events);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_LiveEventStateInitial value) initial,
    required TResult Function(_LiveEventStateLoading value) loading,
    required TResult Function(_LiveEventStateData value) data,
    required TResult Function(_LiveEventStateError value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LiveEventStateInitial value)? initial,
    TResult? Function(_LiveEventStateLoading value)? loading,
    TResult? Function(_LiveEventStateData value)? data,
    TResult? Function(_LiveEventStateError value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LiveEventStateInitial value)? initial,
    TResult Function(_LiveEventStateLoading value)? loading,
    TResult Function(_LiveEventStateData value)? data,
    TResult Function(_LiveEventStateError value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class _LiveEventStateData implements LiveEventState {
  const factory _LiveEventStateData(final EventResponseModel events) =
      _$LiveEventStateDataImpl;

  EventResponseModel get events;
  @JsonKey(ignore: true)
  _$$LiveEventStateDataImplCopyWith<_$LiveEventStateDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LiveEventStateErrorImplCopyWith<$Res> {
  factory _$$LiveEventStateErrorImplCopyWith(_$LiveEventStateErrorImpl value,
          $Res Function(_$LiveEventStateErrorImpl) then) =
      __$$LiveEventStateErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String msg});
}

/// @nodoc
class __$$LiveEventStateErrorImplCopyWithImpl<$Res>
    extends _$LiveEventStateCopyWithImpl<$Res, _$LiveEventStateErrorImpl>
    implements _$$LiveEventStateErrorImplCopyWith<$Res> {
  __$$LiveEventStateErrorImplCopyWithImpl(_$LiveEventStateErrorImpl _value,
      $Res Function(_$LiveEventStateErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = null,
  }) {
    return _then(_$LiveEventStateErrorImpl(
      null == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LiveEventStateErrorImpl implements _LiveEventStateError {
  const _$LiveEventStateErrorImpl(this.msg);

  @override
  final String msg;

  @override
  String toString() {
    return 'LiveEventState.error(msg: $msg)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveEventStateErrorImpl &&
            (identical(other.msg, msg) || other.msg == msg));
  }

  @override
  int get hashCode => Object.hash(runtimeType, msg);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveEventStateErrorImplCopyWith<_$LiveEventStateErrorImpl> get copyWith =>
      __$$LiveEventStateErrorImplCopyWithImpl<_$LiveEventStateErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(EventResponseModel events) data,
    required TResult Function(String msg) error,
  }) {
    return error(msg);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(EventResponseModel events)? data,
    TResult? Function(String msg)? error,
  }) {
    return error?.call(msg);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(EventResponseModel events)? data,
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
    required TResult Function(_LiveEventStateInitial value) initial,
    required TResult Function(_LiveEventStateLoading value) loading,
    required TResult Function(_LiveEventStateData value) data,
    required TResult Function(_LiveEventStateError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_LiveEventStateInitial value)? initial,
    TResult? Function(_LiveEventStateLoading value)? loading,
    TResult? Function(_LiveEventStateData value)? data,
    TResult? Function(_LiveEventStateError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_LiveEventStateInitial value)? initial,
    TResult Function(_LiveEventStateLoading value)? loading,
    TResult Function(_LiveEventStateData value)? data,
    TResult Function(_LiveEventStateError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _LiveEventStateError implements LiveEventState {
  const factory _LiveEventStateError(final String msg) =
      _$LiveEventStateErrorImpl;

  String get msg;
  @JsonKey(ignore: true)
  _$$LiveEventStateErrorImplCopyWith<_$LiveEventStateErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
