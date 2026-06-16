import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/fetchBlocs/fetch_scoreboard_bloc.dart';
import '../../../../blocs/signalRBloc/subscribe_scoring_signalr_bloc.dart';
import '../../../../models/scoreboard_model.dart';
import '../../../../reusables/cached_image.dart';
import '../../../../reusables/colors.dart';
import 'score_widgets.dart';

// Root scoreboard entry that combines fetched data and live SignalR updates.
class ScoreDashboardNew2 extends StatelessWidget {
  const ScoreDashboardNew2({super.key, required this.eventId});
  final String eventId;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchScoreBoardBloc, FetchScoreBoardState>(
      builder: (context, fetchState) {
        final ScoreBoardModel? fetchData = fetchState is FetchScoreBoardSuccess ? fetchState.scoreBoard : null;

        return BlocBuilder<JoinMatchSignalRBloc, JoinMatchSignalRState>(
          builder: (context, signalRState) {
            final ScoreBoardModel? signalRData = signalRState is JoinMatchSignalRSuccess ? signalRState.scoreBoard : null;
            // when this card should start rendering live scoreboard data again.
            final ScoreBoardModel? currentData = signalRData ?? fetchData;

            if (currentData == null || int.parse(eventId) != currentData.matchId) {
              return const SizedBox.shrink();
            }
            final Inning currentInning = _getCurrentInning(currentData);
            final Inning? previousInning = _getPreviousInning(currentData);
            final List<String> orderedTeams = _scoreBoardTeamNames(currentData, currentInning);
            final String battingTeamName = currentInning.battingTeam.trim().isNotEmpty ? currentInning.battingTeam : orderedTeams.first;
            final String bowlingTeamName = currentInning.bowlingTeam.trim().isNotEmpty
                ? currentInning.bowlingTeam
                : orderedTeams.firstWhere(
                    (team) => team.toLowerCase() != battingTeamName.toLowerCase(),
                    orElse: () => battingTeamName,
                  );

            ///
            bool isBattingNow() {
              return currentInning.battingTeam.toLowerCase() == battingTeamName.toLowerCase();
            }

            return _ScoreDashboardNewCard(
              scoreBoard: currentData,
              currentInning: currentInning,
              previousInning: previousInning,
              battingTeamName: battingTeamName,
              bowlingTeamName: bowlingTeamName,
              isBattingNow: isBattingNow(),
            );
          },
        );
      },
    );
  }
}

// Main card shell that prepares player lines and composes header, timeline, and footer.
class _ScoreDashboardNewCard extends StatelessWidget {
  const _ScoreDashboardNewCard({
    required this.scoreBoard,
    required this.currentInning,
    required this.previousInning,
    required this.battingTeamName,
    required this.bowlingTeamName,
    required this.isBattingNow,
  });

  final ScoreBoardModel scoreBoard;
  final Inning currentInning;
  final Inning? previousInning;
  final String battingTeamName;
  final String bowlingTeamName;
  final bool isBattingNow;

  @override
  Widget build(BuildContext context) {
    final _PlayerLine striker = _buildBatterLine(
      batting: currentInning.batting,
      preferredName: scoreBoard.currentState.striker,
      fallbackIndex: 0,
    );
    final _PlayerLine nonStriker = _buildBatterLine(
      batting: currentInning.batting,
      preferredName: scoreBoard.currentState.nonStriker,
      fallbackIndex: 1,
    );
    final _PlayerLine bowler = _buildBowlerLine(
      bowling: currentInning.bowling,
      preferredName: scoreBoard.currentState.bowler,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10243A), Color(0xFF244867), Color(0xFF152434)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF78A6CC)),
        boxShadow: const [
          BoxShadow(color: Color(0x26162E45), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ScoreboardBackdropPainter(
                  leftAccent: _teamAccent(battingTeamName),
                  rightAccent: _teamAccent(bowlingTeamName),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ScoreHeader(
                  scoreBoard: scoreBoard,
                  currentInning: currentInning,
                  previousInning: previousInning,
                  battingTeamName: battingTeamName,
                  bowlingTeamName: bowlingTeamName,
                  isBattingNow: isBattingNow,
                ),
                const SizedBox(height: 4),
                _BallTimelineStrip(
                  balls: _recentBalls(currentInning.lastBalls),
                ),
                const SizedBox(height: 5),
                _ScoreFooter(
                  striker: striker,
                  nonStriker: nonStriker,
                  bowler: bowler,
                  scoreBoard: scoreBoard,
                  currentInning: currentInning,
                  previousInning: previousInning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Top row showing batting team on the left, current innings score in the center, and bowling team on the right.
class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({
    required this.scoreBoard,
    required this.currentInning,
    required this.previousInning,
    required this.battingTeamName,
    required this.bowlingTeamName,
    required this.isBattingNow,
  });

  final ScoreBoardModel scoreBoard;
  final Inning currentInning;
  final Inning? previousInning;
  final String battingTeamName;
  final String bowlingTeamName;
  final bool isBattingNow;
  @override
  Widget build(BuildContext context) {
    final String battingSubtitle = _teamScoreSubtitle(battingTeamName, currentInning, previousInning);
    final String bowlingSubtitle = _teamScoreSubtitle(bowlingTeamName, currentInning, previousInning);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.topLeft,
            child: _TeamIdentity(
              teamName: battingTeamName,
              logoUrl: _teamLogoUrl(scoreBoard, battingTeamName),
              accent: _teamAccent(battingTeamName),
              alignEnd: false,
              isBattingNow: isBattingNow,
              subtitle: battingSubtitle,
            ),
          ),
        ),
        Expanded(
          child: _CurrentInningScore(currentInning: currentInning),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: _TeamIdentity(
              teamName: bowlingTeamName,
              logoUrl: _teamLogoUrl(scoreBoard, bowlingTeamName),
              accent: _teamAccent(bowlingTeamName),
              alignEnd: true,
              isBattingNow: !isBattingNow,
              subtitle: bowlingSubtitle,
            ),
          ),
        ),
      ],
    );
  }
}

// Center score block for the currently active innings only.
class _CurrentInningScore extends StatelessWidget {
  const _CurrentInningScore({required this.currentInning});

  final Inning currentInning;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${currentInning.score.runs}/${currentInning.score.wickets}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFF6FBFF),
            fontSize: 20.5,
            fontWeight: FontWeight.w800,
            height: 1,
            shadows: [Shadow(color: Color(0x66111C28), blurRadius: 8, offset: Offset(0, 1))],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(${currentInning.score.overs})',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFD9E9F7),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}

// Team logo and short-name badge used on both left and right sides of the header.
class _TeamIdentity extends StatelessWidget {
  const _TeamIdentity({
    required this.teamName,
    required this.logoUrl,
    required this.accent,
    required this.alignEnd,
    required this.isBattingNow,
    this.subtitle,
  });

  final String teamName;
  final String logoUrl;
  final Color accent;
  final bool alignEnd;
  final bool isBattingNow;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: logoUrl.isEmpty
                    ? Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [accent.withValues(alpha: 0.95), accent.withValues(alpha: 0.45)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: const Color(0x55FFFFFF)),
                        ),
                        child: const Icon(Icons.sports_cricket, color: Colors.white, size: 20),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(4),
                        child: AssetsUrlImageWithProgress(imgUrl: logoUrl),
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              teamName,
              textAlign: alignEnd ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                color: Color(0xFFD6E8F6),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                textAlign: alignEnd ? TextAlign.right : TextAlign.left,
                style: const TextStyle(
                  color: Color(0xFFB8D4F0),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),

        /// ✅ LIVE BADGE FIXED HERE
        if (isBattingNow)
          Positioned(
            top: 0,
            right: -20,
            child: LivePulseBadge(
              alignEnd: false,
              child: const _AnimatedBattingDot(),
            ),
          ),
      ],
    );
  }
}

// Horizontal recent-ball strip that visually separates previous balls from the live over balls.
class _BallTimelineStrip extends StatelessWidget {
  const _BallTimelineStrip({
    required this.balls,
  });

  final List<LastBall> balls;

  @override
  Widget build(BuildContext context) {
    if (balls.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<LastBall> displayBalls = _recentBalls(balls);
    if (displayBalls.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<_OverGroup> groups = <_OverGroup>[];
    for (final ball in displayBalls) {
      final int over = _parseOverNumber(ball.overBall);
      if (groups.isEmpty || groups.last.over != over) {
        groups.add(_OverGroup(over: over, balls: <LastBall>[ball]));
      } else {
        groups.last.balls.add(ball);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int gi = 0; gi < groups.length; gi++) ...[
            for (int bi = 0; bi < groups[gi].balls.length; bi++) ...[
              _buildBallChip(groups[gi].balls[bi].ball),
              if (bi < groups[gi].balls.length - 1) const SizedBox(width: 6),
            ],
            const SizedBox(width: 6),
            _OverLabel(over: groups[gi].over),
            if (gi < groups.length - 1) const SizedBox(width: 14),
          ],
        ],
      ),
    );
  }
}

class _OverGroup {
  final int over;
  final List<LastBall> balls;

  _OverGroup({required this.over, required this.balls});
}

class _OverLabel extends StatelessWidget {
  const _OverLabel({
    required this.over,
  });

  final int over;

  @override
  Widget build(BuildContext context) {
    String label = '${over + 1}th';
    if (over == 1) label = '1st';
    if (over == 2) label = '2nd';
    if (over == 3) label = '3rd';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2B3B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A90E2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// Bottom section that shows batters on the left, match message in the center, and bowler/previous innings on the right.
class _ScoreFooter extends StatelessWidget {
  const _ScoreFooter({
    required this.striker,
    required this.nonStriker,
    required this.bowler,
    required this.scoreBoard,
    required this.currentInning,
    required this.previousInning,
  });

  final _PlayerLine striker;
  final _PlayerLine nonStriker;
  final _PlayerLine bowler;
  final ScoreBoardModel scoreBoard;
  final Inning currentInning;
  final Inning? previousInning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FooterPlayer(name: striker.name, stats: striker.stats, iconType: _FooterIconType.bat),
                _FooterPlayer(name: nonStriker.name, stats: nonStriker.stats, iconType: _FooterIconType.wait),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  _MatchMessage(scoreBoard: scoreBoard, currentInning: currentInning),
                  _TossMessage(
                    tossWinner: scoreBoard.toss.tossWinner,
                    tossDecision: scoreBoard.toss.tossDecision,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (previousInning != null)
                  _CompletedInningScore(
                    teamName: previousInning!.battingTeam,
                    inning: previousInning!,
                  ),
                _FooterPlayer(
                  name: bowler.name,
                  stats: bowler.stats,
                  alignEnd: true,
                  iconType: _FooterIconType.ball,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Centered live match status text such as chase equation, result, or match state.
class _MatchMessage extends StatelessWidget {
  const _MatchMessage({
    required this.scoreBoard,
    required this.currentInning,
  });

  final ScoreBoardModel scoreBoard;
  final Inning currentInning;

  @override
  Widget build(BuildContext context) {
    return Text(
      _buildMatchMessageText(scoreBoard, currentInning),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFFF8FCFF),
        fontSize: 13,
        fontWeight: FontWeight.w800,
        height: 1.2,
        shadows: [Shadow(color: Color(0x99101828), blurRadius: 5, offset: Offset(0, 1))],
      ),
    );
  }
}

class _TossMessage extends StatefulWidget {
  const _TossMessage({
    required this.tossWinner,
    required this.tossDecision,
  });

  final String tossWinner;
  final String tossDecision;

  @override
  State<_TossMessage> createState() => _TossMessageState();
}

class _TossMessageState extends State<_TossMessage> {
  bool _visible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _visible && widget.tossWinner.trim().isNotEmpty && widget.tossDecision.trim().isNotEmpty
          ? Text(
              "Toss Wins  ${widget.tossWinner} Decided to ${widget.tossDecision}",
              key: const ValueKey('tossMessage'),
              style: const TextStyle(color: Color(0xFF9EB7FF), fontSize: 10, fontWeight: FontWeight.w600),
            )
          : const SizedBox.shrink(),
    );
  }
}

// Compact score summary for the already completed innings shown in the right footer area.
class _CompletedInningScore extends StatelessWidget {
  const _CompletedInningScore({
    required this.teamName,
    required this.inning,
  });

  final String teamName;
  final Inning inning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            teamName,
            style: const TextStyle(
              color: Color(0xFFB8D4F0),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${inning.score.runs}/${inning.score.wickets}',
            style: const TextStyle(
              color: Color(0xFFF3FAFF),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${inning.score.overs})',
            style: const TextStyle(
              color: Color(0xFFDBECFF),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable player row for striker, non-striker, and bowler details in the footer.
class _FooterPlayer extends StatelessWidget {
  const _FooterPlayer({
    required this.name,
    required this.stats,
    this.alignEnd = false,
    this.iconType = _FooterIconType.none,
  });

  final String name;
  final String stats;
  final bool alignEnd;
  final _FooterIconType iconType;

  @override
  Widget build(BuildContext context) {
    final MainAxisAlignment mainAxisAlignment = alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start;
    final TextAlign textAlign = alignEnd ? TextAlign.right : TextAlign.left;
    final IconData? iconData = switch (iconType) {
      _FooterIconType.bat => Icons.sports_cricket,
      _FooterIconType.ball => Icons.sports_baseball,
      _FooterIconType.wait => Icons.donut_large,
      _FooterIconType.none => null,
    };
    final Color iconColor = iconType == _FooterIconType.ball || iconType == _FooterIconType.wait ? const Color(0xFF9EB7FF) : const Color(0xFFF4B95D);

    return name.isEmpty || name == '-'
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: mainAxisAlignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!alignEnd && iconData != null) ...[
                  Icon(iconData, size: 13, color: iconColor),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: textAlign,
                        style: const TextStyle(
                          color: Color(0xFFF3FAFF),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          shadows: [Shadow(color: Color(0x66111C28), blurRadius: 5, offset: Offset(0, 1))],
                        ),
                      ),
                      if (stats.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          stats,
                          textAlign: textAlign,
                          style: const TextStyle(
                            color: Color(0xFFDBECFF),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (alignEnd && iconData != null) ...[
                  const SizedBox(width: 6),
                  Transform.rotate(
                    angle: iconType == _FooterIconType.bat ? -0.4 : 0,
                    child: Icon(iconData, size: 13, color: iconColor),
                  ),
                ],
              ],
            ),
          );
  }
}

// Normalizes scoreboard ball history and returns the latest 12 balls in display order.
// Input is expected newest-first from the API, so we take the first 12 and reverse them for left-to-right rendering.
List<LastBall> _recentBalls(List<LastBall> lastBalls) {
  final List<LastBall> validBalls = lastBalls.where((ball) => ball.ball.trim().isNotEmpty).toList();
  if (validBalls.length <= 12) {
    return validBalls;
  }

  return validBalls.sublist(0, 12);
}

int _parseOverNumber(String overBall) {
  final String normalized = overBall.trim();
  if (normalized.isEmpty) return 0;
  final parts = normalized.split('.');
  return int.tryParse(parts.first) ?? 0;
}

// Builds the center footer message with chase info first, then result, then generic match status.
String _buildMatchMessageText(ScoreBoardModel scoreBoard, Inning currentInning) {
  final Target? target = currentInning.target;
  if (target != null && target.runsToWin > 0 && target.ballsRemaining > 0 && !scoreBoard.result.status.toLowerCase().contains("completed")) {
    return '${currentInning.battingTeam.toUpperCase()} need ${target.runsToWin} runs in ${target.ballsRemaining} balls.';
  }
  if (scoreBoard.result.status.isNotEmpty) {
    return scoreBoard.result.status.toLowerCase().contains("completed") ? "${scoreBoard.result.winner} win by ${scoreBoard.result.winBy}" : scoreBoard.result.status;
  }

  if (scoreBoard.matchStatus.isNotEmpty) {
    return scoreBoard.matchStatus;
  }

  return '${currentInning.battingTeam.toUpperCase()} vs ${currentInning.bowlingTeam.toUpperCase()}';
}

// Extracts the two display team names, falling back to inning teams when team-map data is incomplete.
List<String> _scoreBoardTeamNames(ScoreBoardModel scoreBoard, Inning currentInning) {
  final List<String> teams = scoreBoard.teams.keys.where((team) => team.trim().isNotEmpty).toList();
  if (teams.length >= 2) {
    return teams.take(2).toList();
  }

  final List<String> fallbackTeams = <String>[];
  if (currentInning.battingTeam.trim().isNotEmpty) {
    fallbackTeams.add(currentInning.battingTeam);
  }
  if (currentInning.bowlingTeam.trim().isNotEmpty && !fallbackTeams.contains(currentInning.bowlingTeam)) {
    fallbackTeams.add(currentInning.bowlingTeam);
  }

  return fallbackTeams;
}

// Resolves the correct team logo URL from the scoreboard logo payload.
String _teamLogoUrl(ScoreBoardModel scoreBoard, String teamName) {
  if (scoreBoard.teamsLogo.teamA.name == teamName) {
    return scoreBoard.teamsLogo.teamA.logo;
  }
  if (scoreBoard.teamsLogo.teamB.name == teamName) {
    return scoreBoard.teamsLogo.teamB.logo;
  }
  return '';
}

String _teamScoreSubtitle(String teamName, Inning currentInning, Inning? previousInning) {
  final String normalizedTeamName = teamName.trim().toLowerCase();
  if (normalizedTeamName == currentInning.battingTeam.trim().toLowerCase()) {
    return '${currentInning.score.runs}/${currentInning.score.wickets} (${currentInning.score.overs})';
  }

  if (previousInning != null && normalizedTeamName == previousInning.battingTeam.trim().toLowerCase()) {
    return '${previousInning.score.runs}/${previousInning.score.wickets} (${previousInning.score.overs})';
  }

  return 'Yet to bat';
}

// Convenience helper used where the active batting team name is needed outside the card layout.
String currentBattingTeamName(ScoreBoardModel scoreBoard) {
  final Inning inning = _getCurrentInning(scoreBoard);
  return inning.battingTeam.toLowerCase();
}

// Picks the striker/non-striker line from batting data using preferred live names with sensible fallbacks.
_PlayerLine _buildBatterLine({
  required List<Batting> batting,
  required String? preferredName,
  required int fallbackIndex,
}) {
  final String normalizedPreferredName = preferredName?.trim() ?? '';

  if (normalizedPreferredName.isNotEmpty) {
    for (final Batting batter in batting) {
      if (batter.name.toLowerCase() == normalizedPreferredName.toLowerCase()) {
        return _PlayerLine(
          name: batter.name,
          stats: '${batter.runs} (${batter.balls})${batter.strikeRate > 0 ? '  SR ${batter.strikeRate.toStringAsFixed(1)}' : ''}',
        );
      }
    }

    return _PlayerLine(name: normalizedPreferredName, stats: '');
  }

  if (batting.length > fallbackIndex) {
    final Batting batter = batting[fallbackIndex];
    return _PlayerLine(
      name: batter.name,
      stats: '${batter.runs} (${batter.balls})${batter.strikeRate > 0 ? '  SR ${batter.strikeRate.toStringAsFixed(1)}' : ''}',
    );
  }

  if (batting.isNotEmpty) {
    final Batting batter = batting.first;
    return _PlayerLine(
      name: batter.name,
      stats: '${batter.runs} (${batter.balls})',
    );
  }

  return const _PlayerLine(name: '-', stats: '');
}

// Picks the current bowler line from bowling data using live state first and list fallback second.
_PlayerLine _buildBowlerLine({
  required List<Bowling> bowling,
  required String? preferredName,
}) {
  final String normalizedPreferredName = preferredName?.trim() ?? '';

  if (normalizedPreferredName.isNotEmpty) {
    for (final Bowling bowler in bowling) {
      if (bowler.name.toLowerCase() == normalizedPreferredName.toLowerCase()) {
        return _PlayerLine(
          name: bowler.name,
          stats: '${bowler.runs}/${bowler.wickets} (${bowler.overs})',
        );
      }
    }
    return _PlayerLine(name: normalizedPreferredName, stats: '');
  }

  if (bowling.isNotEmpty) {
    final Bowling bowler = bowling.first;
    return _PlayerLine(
      name: bowler.name,
      stats: '${bowler.runs}/${bowler.wickets} (${bowler.overs})',
    );
  }

  return const _PlayerLine(name: '-', stats: '');
}

// Renders one colored chip for a single ball outcome in the timeline.
Widget _buildBallChip(String ball) {
  final _BallStyle style = _getBallStyle(ball);
  return Container(
    width: 26,
    height: 26,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: style.background,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0x33D7ECFF)),
    ),
    child: Text(
      style.text,
      style: TextStyle(
        color: style.foreground,
        fontSize: style.text.length > 1 ? 7.5 : 10.5,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    ),
  );
}

// Maps each ball outcome to its visual treatment so wickets, boundaries, and extras stand out.
_BallStyle _getBallStyle(String ball) {
  switch (ball) {
    case 'W':
      return const _BallStyle(
        text: 'W',
        background: Color(0xFFBC2E2E),
        foreground: Colors.white,
      );
    case '4':
      return const _BallStyle(
        text: '4',
        background: Color(0xFF1E8E3E),
        foreground: Colors.white,
      );
    case '6':
      return const _BallStyle(
        text: '6',
        background: Color(0xFF1E8E3E),
        foreground: Colors.white,
      );
    case 'NB':
      return const _BallStyle(
        text: 'NB',
        background: Color(0xFF996515),
        foreground: Colors.white,
      );
    case 'WD':
      return const _BallStyle(
        text: 'WD',
        background: Color(0xFF2C6DB3),
        foreground: Colors.white,
      );
    default:
      return _BallStyle(
        text: ball,
        background: const Color(0xFF23415E),
        foreground: const Color(0xFFF4FAFF),
      );
  }
}

// Returns the active innings based on the scoreboard current-state pointer.
Inning _getCurrentInning(ScoreBoardModel scoreBoard) {
  if (scoreBoard.innings.isEmpty) {
    throw StateError('No innings available in score board.');
  }

  if (scoreBoard.currentState.innings <= 1) {
    return scoreBoard.innings.first;
  }

  final int currentIndex = scoreBoard.currentState.innings - 1;
  if (currentIndex >= 0 && currentIndex < scoreBoard.innings.length) {
    return scoreBoard.innings[currentIndex];
  }

  return scoreBoard.innings.last;
}

// Returns the previous innings only when the match is currently in the second innings.
Inning? _getPreviousInning(ScoreBoardModel scoreBoard) {
  if (scoreBoard.innings.length < 2) {
    return null;
  }

  final int currentInningIndex = scoreBoard.currentState.innings - 1;

  // If current inning is second inning, return first inning
  if (currentInningIndex == 1 && scoreBoard.innings.isNotEmpty) {
    return scoreBoard.innings[0];
  }

  return null;
}

// Provides a team-specific accent color used by logos, background paint, and fallback visuals.
Color _teamAccent(String teamName) {
  final String key = teamName.toLowerCase();
  if (key.contains('bangalore') || key == 'rcb') {
    return const Color(0xFFB88A2F);
  }
  if (key.contains('chennai') || key == 'csk') {
    return const Color(0xFFEB8A13);
  }
  if (key.contains('mumbai')) {
    return const Color(0xFF3A6AD6);
  }
  if (key.contains('kolkata')) {
    return const Color(0xFF6C3AA8);
  }
  if (key.contains('delhi')) {
    return const Color(0xFF2C66C7);
  }
  return const Color(0xFF3D4C66);
}

// Visual style token for each timeline ball chip.
class _BallStyle {
  final String text;
  final Color background;
  final Color foreground;

  const _BallStyle({
    required this.text,
    required this.background,
    required this.foreground,
  });
}

// Small data holder for footer player name and stats text.
class _PlayerLine {
  final String name;
  final String stats;

  const _PlayerLine({
    required this.name,
    required this.stats,
  });
}

// Footer icon variants used to distinguish batters, bowlers, and non-strikers.
enum _FooterIconType { bat, ball, wait, none }

class _AnimatedBattingDot extends StatefulWidget {
  const _AnimatedBattingDot();

  @override
  State<_AnimatedBattingDot> createState() => _AnimatedBattingDotState();
}

class _AnimatedBattingDotState extends State<_AnimatedBattingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.55, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF1E8E3E),
            shape: BoxShape.circle,
            border: Border.all(color: white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x551E8E3E),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
