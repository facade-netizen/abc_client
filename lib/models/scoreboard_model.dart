import 'dart:convert';

/// ================= ROOT =================
ScoreBoardModel scoreBoardModelFromJson(String str) => ScoreBoardModel.fromJson(json.decode(str));

class ScoreBoardModel {
  final int matchId;
  final String matchStatus;
  final Map<String, dynamic> teams;
  final CurrentState currentState;
  final List<Inning> innings;
  final Result result;
  final TeamsLogo teamsLogo;
  final Toss toss;

  ScoreBoardModel({
    required this.matchId,
    required this.matchStatus,
    required this.teams,
    required this.currentState,
    required this.innings,
    required this.result,
    required this.teamsLogo,
    required this.toss,
  });

  factory ScoreBoardModel.fromJson(Map<String, dynamic> json) {
    return ScoreBoardModel(
      matchId: json["matchId"] ?? 0,
      matchStatus: json["matchStatus"] ?? "",
      teams: Map<String, dynamic>.from(json['teams'] ?? {}),
      currentState: CurrentState.fromJson(json["currentState"] ?? {}),
      innings: (json["innings"] as List? ?? []).map((x) => Inning.fromJson(x)).toList(),
      toss: Toss.fromJson(json["toss"] ?? {}),
      result: Result.fromJson(json["result"] ?? {}),
      teamsLogo: TeamsLogo.fromJson(json['teamslogo'] ?? {}),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreBoardModel &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          matchStatus == other.matchStatus &&
          innings.length == other.innings.length &&
          currentState.currentOver == other.currentState.currentOver &&
          currentState.currentBall == other.currentState.currentBall;

  @override
  int get hashCode => matchId.hashCode ^ matchStatus.hashCode ^ currentState.currentOver.hashCode ^ currentState.currentBall.hashCode;
}

class Toss {
  final int id;
  final int matchId;
  final int tossWinnerTeamId;
  final String tossDecision;
  final String tossWinner;
  final int tossBattingTeamId;
  final int tossBowlingTeamId;

  Toss({
    required this.id,
    required this.matchId,
    required this.tossWinnerTeamId,
    required this.tossDecision,
    required this.tossWinner,
    required this.tossBattingTeamId,
    required this.tossBowlingTeamId,
  });

  factory Toss.fromJson(Map<String, dynamic> json) {
    return Toss(
      id: json['id'] as int,
      matchId: json['matchId'] as int,
      tossWinnerTeamId: json['tossWinnerTeamId'] as int,
      tossDecision: json['tossDecision'] as String,
      tossWinner: json['tossWinner'] as String,
      tossBattingTeamId: json['tossBattingTeamId'] as int,
      tossBowlingTeamId: json['tossBowlingTeamId'] as int,
    );
  }
}

/// ================= CURRENT STATE =================
class CurrentState {
  final int innings;
  final String? striker;
  final String? nonStriker;
  final String? bowler;
  final int currentOver;
  final int currentBall;

  CurrentState({
    required this.innings,
    this.striker,
    this.nonStriker,
    this.bowler,
    required this.currentOver,
    required this.currentBall,
  });

  factory CurrentState.fromJson(Map<String, dynamic> json) {
    return CurrentState(
      innings: json["innings"] ?? 0,
      striker: json["striker"],
      nonStriker: json["nonStriker"],
      bowler: json["bowler"],
      currentOver: json["currentOver"] ?? 0,
      currentBall: json["currentBall"] ?? 0,
    );
  }
}

/// ================= INNING =================
class Inning {
  final int inningsNumber;
  final String battingTeam;
  final String bowlingTeam;
  final ScoreBoardScore score;
  final List<Batting> batting;
  final List<Bowling> bowling;
  final ScoreBoardExtras extras;
  final List<LastBall> lastBalls;
  final Target? target;
  final bool isCompleted;

  Inning({
    required this.inningsNumber,
    required this.battingTeam,
    required this.bowlingTeam,
    required this.score,
    required this.batting,
    required this.bowling,
    required this.extras,
    required this.lastBalls,
    this.target,
    required this.isCompleted,
  });

  factory Inning.fromJson(Map<String, dynamic> json) {
    return Inning(
      inningsNumber: json["inningsNumber"] ?? 0,
      battingTeam: json["battingTeam"] ?? "",
      bowlingTeam: json["bowlingTeam"] ?? "",
      score: ScoreBoardScore.fromJson(json["score"] ?? {}),
      batting: (json["batting"] as List? ?? []).map((x) => Batting.fromJson(x)).toList(),
      bowling: (json["bowling"] as List? ?? []).map((x) => Bowling.fromJson(x)).toList(),
      extras: ScoreBoardExtras.fromJson(json["extras"] ?? {}),
      lastBalls: (json["lastBalls"] as List? ?? []).map((x) => LastBall.fromJson(x)).toList(),
      target: json["target"] != null ? Target.fromJson(json["target"]) : null,
      isCompleted: json["isCompleted"] ?? false,
    );
  }
}

/// ================= SCORE =================
class ScoreBoardScore {
  final int runs;
  final int wickets;
  final int balls;
  final String overs;

  ScoreBoardScore({
    required this.runs,
    required this.wickets,
    required this.balls,
    required this.overs,
  });

  factory ScoreBoardScore.fromJson(Map<String, dynamic> json) {
    return ScoreBoardScore(
      runs: json["runs"] ?? 0,
      wickets: json["wickets"] ?? 0,
      balls: json["balls"] ?? 0,
      overs: json["overs"]?.toString() ?? "0.0",
    );
  }
}

/// ================= BATTING =================
class Batting {
  final String name;
  final int runs;
  final int balls;
  final double strikeRate;
  final String status;

  Batting({
    required this.name,
    required this.runs,
    required this.balls,
    required this.strikeRate,
    required this.status,
  });

  factory Batting.fromJson(Map<String, dynamic> json) {
    return Batting(
      name: json["name"] ?? "",
      runs: json["runs"] ?? 0,
      balls: json["balls"] ?? 0,
      strikeRate: (json["strikeRate"] ?? 0).toDouble(),
      status: json["status"] ?? "",
    );
  }
}

/// ================= BOWLING =================
class Bowling {
  final String name;
  final String overs;
  final int balls;
  final int runs;
  final int wickets;
  final double economy;

  Bowling({
    required this.name,
    required this.overs,
    required this.balls,
    required this.runs,
    required this.wickets,
    required this.economy,
  });

  factory Bowling.fromJson(Map<String, dynamic> json) {
    return Bowling(
      name: json["name"] ?? "",
      overs: json["overs"] ?? "0.0",
      balls: json["balls"] ?? 0,
      runs: json["runs"] ?? 0,
      wickets: json["wickets"] ?? 0,
      economy: (json["economy"] ?? 0).toDouble(),
    );
  }
}

/// ================= EXTRAS =================
class ScoreBoardExtras {
  final int wide;
  final int noBall;
  final int bye;
  final int legBye;

  ScoreBoardExtras({
    required this.wide,
    required this.noBall,
    required this.bye,
    required this.legBye,
  });

  factory ScoreBoardExtras.fromJson(Map<String, dynamic> json) {
    return ScoreBoardExtras(
      wide: json["wide"] ?? 0,
      noBall: json["noBall"] ?? 0,
      bye: json["bye"] ?? 0,
      legBye: json["legBye"] ?? 0,
    );
  }
}

class LastBall {
  final String overBall;
  final String ball;

  LastBall({
    required this.overBall,
    required this.ball,
  });

  factory LastBall.fromJson(Map<String, dynamic> json) {
    return LastBall(
      overBall: json['overBall'] ?? "",
      ball: json['ball'] ?? "",
    );
  }
}

/// ================= TARGET =================
class Target {
  final int runsToWin;
  final int ballsRemaining;
  final double requiredRunRate;

  Target({
    required this.runsToWin,
    required this.ballsRemaining,
    required this.requiredRunRate,
  });

  factory Target.fromJson(Map<String, dynamic> json) {
    return Target(
      runsToWin: json["runsToWin"] ?? 0,
      ballsRemaining: json["ballsRemaining"] ?? 0,
      requiredRunRate: (json["requiredRunRate"] ?? 0).toDouble(),
    );
  }
}

/// ================= RESULT =================
class Result {
  final String? winner;
  final String? winBy;
  final String status;

  Result({
    this.winner,
    this.winBy,
    required this.status,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      winner: json["winner"],
      winBy: json["winBy"],
      status: json["status"] ?? "",
    );
  }
}

/// ================= TEAMS LOGO =================
class TeamsLogo {
  final TeamLogo teamA;
  final TeamLogo teamB;

  TeamsLogo({
    required this.teamA,
    required this.teamB,
  });

  factory TeamsLogo.fromJson(Map<String, dynamic> json) {
    return TeamsLogo(
      teamA: TeamLogo.fromJson(json['teamA'] ?? {}),
      teamB: TeamLogo.fromJson(json['teamB'] ?? {}),
    );
  }
}

class TeamLogo {
  final String name;
  final String logo;

  TeamLogo({
    required this.name,
    required this.logo,
  });

  factory TeamLogo.fromJson(Map<String, dynamic> json) {
    return TeamLogo(
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}
/*
/// ================= DUMMY DATA FOR TESTING =================
final dummyScoreBoardModel = ScoreBoardModel(
  matchId: 35452229,
  matchStatus: 'In Progress',
  teams: {
    'Rajasthan Royals': {
      'players': [
        {'name': 'Sanju Samson', 'role': 'Captain/WK', 'runs': 45, 'balls': 32, 'status': 'Out'},
        {'name': 'Jos Buttler', 'role': 'Batsman', 'runs': 68, 'balls': 42, 'status': 'Not Out'},
        {'name': 'Yashasvi Jaiswal', 'role': 'Batsman', 'runs': 12, 'balls': 8, 'status': 'Out'},
      ],
    },
    'Mumbai Indians': {
      'players': [
        {'name': 'Rohit Sharma', 'role': 'Captain/Batsman', 'runs': 34, 'balls': 28, 'status': 'Out'},
        {'name': 'Ishan Kishan', 'role': 'WK/Batsman', 'runs': 52, 'balls': 38, 'status': 'Not Out'},
        {'name': 'Suryakumar Yadav', 'role': 'Batsman', 'runs': 27, 'balls': 15, 'status': 'Out'},
      ],
    },
  },
  currentState: CurrentState(
    innings: 2,
    striker: 'Ishan Kishan',
    nonStriker: 'Rohit Sharma',
    bowler: 'Trent Boult',
    currentOver: 8,
    currentBall: 1,
  ),
  innings: [
    Inning(
      inningsNumber: 1,
      battingTeam: 'Rajasthan Royals',
      bowlingTeam: 'Mumbai Indians',
      score: ScoreBoardScore(
        runs: 156,
        wickets: 4,
        balls: 74,
        overs: '12.3',
      ),
      batting: [
        Batting(name: 'Jos Buttler', runs: 68, balls: 42, strikeRate: 161.90, status: 'Not Out'),
        Batting(name: 'Sanju Samson', runs: 45, balls: 32, strikeRate: 140.62, status: 'Out'),
        Batting(name: 'Yashasvi Jaiswal', runs: 12, balls: 8, strikeRate: 150.00, status: 'Out'),
        Batting(name: 'Riyan Parag', runs: 18, balls: 12, strikeRate: 150.00, status: 'Not Out'),
        Batting(name: 'Dhruv Jurel', runs: 8, balls: 6, strikeRate: 133.33, status: 'Out'),
      ],
      bowling: [
        Bowling(name: 'Jasprit Bumrah', overs: '3.0', balls: 18, runs: 28, wickets: 2, economy: 9.33),
        Bowling(name: 'Trent Boult', overs: '3.0', balls: 18, runs: 35, wickets: 1, economy: 11.67),
        Bowling(name: 'Piyush Chawla', overs: '2.0', balls: 12, runs: 22, wickets: 0, economy: 11.00),
        Bowling(name: 'Hardik Pandya', overs: '2.0', balls: 12, runs: 30, wickets: 1, economy: 15.00),
        Bowling(name: 'Gerald Coetzee', overs: '2.0', balls: 12, runs: 41, wickets: 0, economy: 20.50),
      ],
      extras: ScoreBoardExtras(wide: 5, noBall: 2, bye: 1, legBye: 3),
      lastBalls: [
        '6',
        'W',
        '2',
        '1',
        '4',
        '2',
        'W',
        '6',
        '1',
        '2',
        '4',
        '6',
      ],
      target: null,
      isCompleted: true,
    ),
    Inning(
      inningsNumber: 2,
      battingTeam: 'Mumbai Indians',
      bowlingTeam: 'Rajasthan Royals',
      score: ScoreBoardScore(runs: 89, wickets: 3, balls: 43, overs: '8.1'),
      batting: [
        Batting(name: 'Ishan Kishan', runs: 52, balls: 38, strikeRate: 136.84, status: 'Not Out'),
        Batting(name: 'Rohit Sharma', runs: 34, balls: 28, strikeRate: 121.43, status: 'Out'),
        Batting(name: 'Suryakumar Yadav', runs: 27, balls: 15, strikeRate: 180.00, status: 'Out'),
        Batting(name: 'Hardik Pandya', runs: 15, balls: 10, strikeRate: 150.00, status: 'Not Out'),
      ],
      bowling: [
        Bowling(name: 'Trent Boult', overs: '2.0', balls: 12, runs: 18, wickets: 1, economy: 9.00),
        Bowling(name: 'Ravichandran Ashwin', overs: '2.0', balls: 12, runs: 25, wickets: 1, economy: 12.50),
        Bowling(name: 'Yuzvendra Chahal', overs: '2.0', balls: 12, runs: 22, wickets: 1, economy: 11.00),
        Bowling(name: 'Sandeep Sharma', overs: '1.0', balls: 6, runs: 15, wickets: 0, economy: 15.00),
      ],
      extras: ScoreBoardExtras(wide: 3, noBall: 1, bye: 0, legBye: 2),
      lastBalls: ['1', '2', '4', 'WD', 'WD', 'WD', 'NB', 'NB', '1', '6', '2', '1'],
      target: Target(runsToWin: 68, ballsRemaining: 78, requiredRunRate: 5.23),
      isCompleted: false,
    ),
  ],
  result: Result(winner: null, winBy: null, status: 'In Progress - RR need 68 runs in 13 overs'),
  teamsLogo: TeamsLogo(
    teamA: TeamLogo(name: 'Rajasthan Royals', logo: 'https://cricscore.devacms.com/Teamslogo/RR.png'),
    teamB: TeamLogo(name: 'Mumbai Indians', logo: 'https://cricscore.devacms.com/Teamslogo/MI.png'),
  ),
);
*/
