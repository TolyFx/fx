import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/menu_history_bloc.dart';
import '../bloc/menu_router_bloc.dart';
import '../data/repository.dart';

class MenuRouterScope extends StatelessWidget {
  final MenuRepository repository;
  final Widget child;

  const MenuRouterScope(
      {super.key, required this.repository, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MenuRouterBloc(repository: repository)..loadMenu(),
        ),
        BlocProvider(
          create: (_) => MenuHistoryBloc(repository: repository)..loadHistory(),
        ),
      ],
      child: child,
    );
  }
}
