// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_exceptions.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NetworkExceptions<T> {

 String? get message;
/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkExceptionsCopyWith<T, NetworkExceptions<T>> get copyWith => _$NetworkExceptionsCopyWithImpl<T, NetworkExceptions<T>>(this as NetworkExceptions<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkExceptions<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NetworkExceptions<$T>(message: $message)';
}


}

/// @nodoc
abstract mixin class $NetworkExceptionsCopyWith<T,$Res>  {
  factory $NetworkExceptionsCopyWith(NetworkExceptions<T> value, $Res Function(NetworkExceptions<T>) _then) = _$NetworkExceptionsCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$NetworkExceptionsCopyWithImpl<T,$Res>
    implements $NetworkExceptionsCopyWith<T, $Res> {
  _$NetworkExceptionsCopyWithImpl(this._self, this._then);

  final NetworkExceptions<T> _self;
  final $Res Function(NetworkExceptions<T>) _then;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = freezed,}) {
  return _then(_self.copyWith(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NetworkExceptions].
extension NetworkExceptionsPatterns<T> on NetworkExceptions<T> {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Timeout<T> value)?  timeout,TResult Function( BadResponse<T> value)?  badResponse,TResult Function( Cancel<T> value)?  cancel,TResult Function( ConnectionError<T> value)?  connectionError,TResult Function( Unknown<T> value)?  unknown,TResult Function( DefaultError<T> value)?  defaultError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Timeout() when timeout != null:
return timeout(_that);case BadResponse() when badResponse != null:
return badResponse(_that);case Cancel() when cancel != null:
return cancel(_that);case ConnectionError() when connectionError != null:
return connectionError(_that);case Unknown() when unknown != null:
return unknown(_that);case DefaultError() when defaultError != null:
return defaultError(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Timeout<T> value)  timeout,required TResult Function( BadResponse<T> value)  badResponse,required TResult Function( Cancel<T> value)  cancel,required TResult Function( ConnectionError<T> value)  connectionError,required TResult Function( Unknown<T> value)  unknown,required TResult Function( DefaultError<T> value)  defaultError,}){
final _that = this;
switch (_that) {
case Timeout():
return timeout(_that);case BadResponse():
return badResponse(_that);case Cancel():
return cancel(_that);case ConnectionError():
return connectionError(_that);case Unknown():
return unknown(_that);case DefaultError():
return defaultError(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Timeout<T> value)?  timeout,TResult? Function( BadResponse<T> value)?  badResponse,TResult? Function( Cancel<T> value)?  cancel,TResult? Function( ConnectionError<T> value)?  connectionError,TResult? Function( Unknown<T> value)?  unknown,TResult? Function( DefaultError<T> value)?  defaultError,}){
final _that = this;
switch (_that) {
case Timeout() when timeout != null:
return timeout(_that);case BadResponse() when badResponse != null:
return badResponse(_that);case Cancel() when cancel != null:
return cancel(_that);case ConnectionError() when connectionError != null:
return connectionError(_that);case Unknown() when unknown != null:
return unknown(_that);case DefaultError() when defaultError != null:
return defaultError(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? message)?  timeout,TResult Function( String? statusCode,  String? message,  T data)?  badResponse,TResult Function( String? message)?  cancel,TResult Function( String? message)?  connectionError,TResult Function( String? message)?  unknown,TResult Function( String? message)?  defaultError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Timeout() when timeout != null:
return timeout(_that.message);case BadResponse() when badResponse != null:
return badResponse(_that.statusCode,_that.message,_that.data);case Cancel() when cancel != null:
return cancel(_that.message);case ConnectionError() when connectionError != null:
return connectionError(_that.message);case Unknown() when unknown != null:
return unknown(_that.message);case DefaultError() when defaultError != null:
return defaultError(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? message)  timeout,required TResult Function( String? statusCode,  String? message,  T data)  badResponse,required TResult Function( String? message)  cancel,required TResult Function( String? message)  connectionError,required TResult Function( String? message)  unknown,required TResult Function( String? message)  defaultError,}) {final _that = this;
switch (_that) {
case Timeout():
return timeout(_that.message);case BadResponse():
return badResponse(_that.statusCode,_that.message,_that.data);case Cancel():
return cancel(_that.message);case ConnectionError():
return connectionError(_that.message);case Unknown():
return unknown(_that.message);case DefaultError():
return defaultError(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? message)?  timeout,TResult? Function( String? statusCode,  String? message,  T data)?  badResponse,TResult? Function( String? message)?  cancel,TResult? Function( String? message)?  connectionError,TResult? Function( String? message)?  unknown,TResult? Function( String? message)?  defaultError,}) {final _that = this;
switch (_that) {
case Timeout() when timeout != null:
return timeout(_that.message);case BadResponse() when badResponse != null:
return badResponse(_that.statusCode,_that.message,_that.data);case Cancel() when cancel != null:
return cancel(_that.message);case ConnectionError() when connectionError != null:
return connectionError(_that.message);case Unknown() when unknown != null:
return unknown(_that.message);case DefaultError() when defaultError != null:
return defaultError(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class Timeout<T> implements NetworkExceptions<T> {
  const Timeout({required this.message});
  

@override final  String? message;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeoutCopyWith<T, Timeout<T>> get copyWith => _$TimeoutCopyWithImpl<T, Timeout<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Timeout<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NetworkExceptions<$T>.timeout(message: $message)';
}


}

/// @nodoc
abstract mixin class $TimeoutCopyWith<T,$Res> implements $NetworkExceptionsCopyWith<T, $Res> {
  factory $TimeoutCopyWith(Timeout<T> value, $Res Function(Timeout<T>) _then) = _$TimeoutCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$TimeoutCopyWithImpl<T,$Res>
    implements $TimeoutCopyWith<T, $Res> {
  _$TimeoutCopyWithImpl(this._self, this._then);

  final Timeout<T> _self;
  final $Res Function(Timeout<T>) _then;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(Timeout<T>(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class BadResponse<T> implements NetworkExceptions<T> {
  const BadResponse({required this.statusCode, required this.message, required this.data});
  

 final  String? statusCode;
@override final  String? message;
 final  T data;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BadResponseCopyWith<T, BadResponse<T>> get copyWith => _$BadResponseCopyWithImpl<T, BadResponse<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BadResponse<T>&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,statusCode,message,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'NetworkExceptions<$T>.badResponse(statusCode: $statusCode, message: $message, data: $data)';
}


}

/// @nodoc
abstract mixin class $BadResponseCopyWith<T,$Res> implements $NetworkExceptionsCopyWith<T, $Res> {
  factory $BadResponseCopyWith(BadResponse<T> value, $Res Function(BadResponse<T>) _then) = _$BadResponseCopyWithImpl;
@override @useResult
$Res call({
 String? statusCode, String? message, T data
});




}
/// @nodoc
class _$BadResponseCopyWithImpl<T,$Res>
    implements $BadResponseCopyWith<T, $Res> {
  _$BadResponseCopyWithImpl(this._self, this._then);

  final BadResponse<T> _self;
  final $Res Function(BadResponse<T>) _then;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = freezed,Object? message = freezed,Object? data = freezed,}) {
  return _then(BadResponse<T>(
statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as String?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class Cancel<T> implements NetworkExceptions<T> {
  const Cancel({required this.message});
  

@override final  String? message;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CancelCopyWith<T, Cancel<T>> get copyWith => _$CancelCopyWithImpl<T, Cancel<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cancel<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NetworkExceptions<$T>.cancel(message: $message)';
}


}

/// @nodoc
abstract mixin class $CancelCopyWith<T,$Res> implements $NetworkExceptionsCopyWith<T, $Res> {
  factory $CancelCopyWith(Cancel<T> value, $Res Function(Cancel<T>) _then) = _$CancelCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$CancelCopyWithImpl<T,$Res>
    implements $CancelCopyWith<T, $Res> {
  _$CancelCopyWithImpl(this._self, this._then);

  final Cancel<T> _self;
  final $Res Function(Cancel<T>) _then;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(Cancel<T>(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ConnectionError<T> implements NetworkExceptions<T> {
  const ConnectionError({required this.message});
  

@override final  String? message;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionErrorCopyWith<T, ConnectionError<T>> get copyWith => _$ConnectionErrorCopyWithImpl<T, ConnectionError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionError<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NetworkExceptions<$T>.connectionError(message: $message)';
}


}

/// @nodoc
abstract mixin class $ConnectionErrorCopyWith<T,$Res> implements $NetworkExceptionsCopyWith<T, $Res> {
  factory $ConnectionErrorCopyWith(ConnectionError<T> value, $Res Function(ConnectionError<T>) _then) = _$ConnectionErrorCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$ConnectionErrorCopyWithImpl<T,$Res>
    implements $ConnectionErrorCopyWith<T, $Res> {
  _$ConnectionErrorCopyWithImpl(this._self, this._then);

  final ConnectionError<T> _self;
  final $Res Function(ConnectionError<T>) _then;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(ConnectionError<T>(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class Unknown<T> implements NetworkExceptions<T> {
  const Unknown({required this.message});
  

@override final  String? message;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownCopyWith<T, Unknown<T>> get copyWith => _$UnknownCopyWithImpl<T, Unknown<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unknown<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NetworkExceptions<$T>.unknown(message: $message)';
}


}

/// @nodoc
abstract mixin class $UnknownCopyWith<T,$Res> implements $NetworkExceptionsCopyWith<T, $Res> {
  factory $UnknownCopyWith(Unknown<T> value, $Res Function(Unknown<T>) _then) = _$UnknownCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$UnknownCopyWithImpl<T,$Res>
    implements $UnknownCopyWith<T, $Res> {
  _$UnknownCopyWithImpl(this._self, this._then);

  final Unknown<T> _self;
  final $Res Function(Unknown<T>) _then;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(Unknown<T>(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class DefaultError<T> implements NetworkExceptions<T> {
  const DefaultError({required this.message});
  

@override final  String? message;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DefaultErrorCopyWith<T, DefaultError<T>> get copyWith => _$DefaultErrorCopyWithImpl<T, DefaultError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DefaultError<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NetworkExceptions<$T>.defaultError(message: $message)';
}


}

/// @nodoc
abstract mixin class $DefaultErrorCopyWith<T,$Res> implements $NetworkExceptionsCopyWith<T, $Res> {
  factory $DefaultErrorCopyWith(DefaultError<T> value, $Res Function(DefaultError<T>) _then) = _$DefaultErrorCopyWithImpl;
@override @useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$DefaultErrorCopyWithImpl<T,$Res>
    implements $DefaultErrorCopyWith<T, $Res> {
  _$DefaultErrorCopyWithImpl(this._self, this._then);

  final DefaultError<T> _self;
  final $Res Function(DefaultError<T>) _then;

/// Create a copy of NetworkExceptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(DefaultError<T>(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
