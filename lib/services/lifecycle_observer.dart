import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/signalRBloc/signalr_hub_listener_bloc.dart';
import '../localDb/token/login_token_box.dart';
import '../localDb/token/login_token_model.dart';

class LifeCycleObserver extends StatefulWidget {
  const LifeCycleObserver({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  State<LifeCycleObserver> createState() => _LifeCycleObserverState();
}

class _LifeCycleObserverState extends State<LifeCycleObserver> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    SaveLoginTokenModel? savedData = SaveTokenBox.loginTokenBox.fetchLoginToken;
    if (savedData != null && savedData.userId != null) {
      if (state == AppLifecycleState.resumed) {
        if (kDebugMode) debugPrint("Resumed");
        if (mounted) {
          context.read<SignalRHubListenerBloc>().add(SignalRHubListener());
        }
      } else if (state == AppLifecycleState.detached) {
        if (kDebugMode) debugPrint("stoped");
      } else {
        if (kDebugMode) debugPrint("Break");
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

/// Custom [BlocObserver] that observes all bloc and cubit state changes.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log(change.currentState.toString().split('\'')[1], name: "[Current bloc state ] >> ");
  }
}
