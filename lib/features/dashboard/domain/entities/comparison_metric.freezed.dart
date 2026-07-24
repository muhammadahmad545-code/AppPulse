// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comparison_metric.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ComparisonMetric {

 String get label; Duration get current; Duration get previous;
/// Create a copy of ComparisonMetric
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparisonMetricCopyWith<ComparisonMetric> get copyWith => _$ComparisonMetricCopyWithImpl<ComparisonMetric>(this as ComparisonMetric, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparisonMetric&&(identical(other.label, label) || other.label == label)&&(identical(other.current, current) || other.current == current)&&(identical(other.previous, previous) || other.previous == previous));
}


@override
int get hashCode => Object.hash(runtimeType,label,current,previous);

@override
String toString() {
  return 'ComparisonMetric(label: $label, current: $current, previous: $previous)';
}


}

/// @nodoc
abstract mixin class $ComparisonMetricCopyWith<$Res>  {
  factory $ComparisonMetricCopyWith(ComparisonMetric value, $Res Function(ComparisonMetric) _then) = _$ComparisonMetricCopyWithImpl;
@useResult
$Res call({
 String label, Duration current, Duration previous
});




}
/// @nodoc
class _$ComparisonMetricCopyWithImpl<$Res>
    implements $ComparisonMetricCopyWith<$Res> {
  _$ComparisonMetricCopyWithImpl(this._self, this._then);

  final ComparisonMetric _self;
  final $Res Function(ComparisonMetric) _then;

/// Create a copy of ComparisonMetric
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? current = null,Object? previous = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as Duration,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

}


/// Adds pattern-matching-related methods to [ComparisonMetric].
extension ComparisonMetricPatterns on ComparisonMetric {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComparisonMetric value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComparisonMetric() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComparisonMetric value)  $default,){
final _that = this;
switch (_that) {
case _ComparisonMetric():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComparisonMetric value)?  $default,){
final _that = this;
switch (_that) {
case _ComparisonMetric() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  Duration current,  Duration previous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComparisonMetric() when $default != null:
return $default(_that.label,_that.current,_that.previous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  Duration current,  Duration previous)  $default,) {final _that = this;
switch (_that) {
case _ComparisonMetric():
return $default(_that.label,_that.current,_that.previous);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  Duration current,  Duration previous)?  $default,) {final _that = this;
switch (_that) {
case _ComparisonMetric() when $default != null:
return $default(_that.label,_that.current,_that.previous);case _:
  return null;

}
}

}

/// @nodoc


class _ComparisonMetric extends ComparisonMetric {
  const _ComparisonMetric({required this.label, required this.current, required this.previous}): super._();
  

@override final  String label;
@override final  Duration current;
@override final  Duration previous;

/// Create a copy of ComparisonMetric
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComparisonMetricCopyWith<_ComparisonMetric> get copyWith => __$ComparisonMetricCopyWithImpl<_ComparisonMetric>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComparisonMetric&&(identical(other.label, label) || other.label == label)&&(identical(other.current, current) || other.current == current)&&(identical(other.previous, previous) || other.previous == previous));
}


@override
int get hashCode => Object.hash(runtimeType,label,current,previous);

@override
String toString() {
  return 'ComparisonMetric(label: $label, current: $current, previous: $previous)';
}


}

/// @nodoc
abstract mixin class _$ComparisonMetricCopyWith<$Res> implements $ComparisonMetricCopyWith<$Res> {
  factory _$ComparisonMetricCopyWith(_ComparisonMetric value, $Res Function(_ComparisonMetric) _then) = __$ComparisonMetricCopyWithImpl;
@override @useResult
$Res call({
 String label, Duration current, Duration previous
});




}
/// @nodoc
class __$ComparisonMetricCopyWithImpl<$Res>
    implements _$ComparisonMetricCopyWith<$Res> {
  __$ComparisonMetricCopyWithImpl(this._self, this._then);

  final _ComparisonMetric _self;
  final $Res Function(_ComparisonMetric) _then;

/// Create a copy of ComparisonMetric
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? current = null,Object? previous = null,}) {
  return _then(_ComparisonMetric(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as Duration,previous: null == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
