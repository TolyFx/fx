import 'dart:async';

import 'package:flutter/material.dart';

abstract class LoginFlow {
  FutureOr<bool> run(BuildContext context);
}