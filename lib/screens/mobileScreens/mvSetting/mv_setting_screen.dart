import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/fetchBlocs/fetch_fav_stake_bloc.dart';
import '../../../reusables/colors.dart';
import 'default_stakes_screen.dart';

class MvSettingScreen extends StatefulWidget {
  const MvSettingScreen({super.key});

  @override
  State<MvSettingScreen> createState() => _MvSettingScreenState();
}

class _MvSettingScreenState extends State<MvSettingScreen> {
  Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
  }

  @override
  void initState() {
    context.read<FetchFavStakeBloc>().add(FetchFavStake());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchFavStakeBloc, FetchFavStakeState>(
      builder: (context, fss) {
        return Scaffold(
          backgroundColor: white,
          body: SafeArea(
              child: MvDefaultStakesScreen(
            key: Key("value_update${DateTime.now().toIso8601String()}"),
            favStakeData: fss is FetchFavStakeSuccess ? fss.favStakeData : null,
          )),
        );
      },
    );
  }
}
