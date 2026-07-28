import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class Failure extends Equatable {
  final String? msg;
  const Failure({@required this.msg});

  @override
  List<Object?> get props => [msg];
}

// General failures
class CustomFailure extends Failure {
  @override
  final String msg;

  const CustomFailure({required this.msg});

  @override
  List<Object> get props => [msg];
}

class ServerFailure extends Failure {
  @override
  final String? msg;
  const ServerFailure({@required this.msg});

  @override
  List<Object?> get props => [msg];
}

class CacheFailure extends Failure {}
