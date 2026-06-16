import 'package:http/http.dart' as http;
import '../../../models/scoreboard_model.dart';
import '../../apiHandlers/api_constants.dart';

class ScoreBoardApiRepository {
  ///
  Future<ScoreBoardModel> fetchScoreBoard(int matchId) async {
    try {
      final response = await http.get(Uri.parse("${ScoringApiConstants.criScore}$matchId"));

      if (response.statusCode == 200) {
        return scoreBoardModelFromJson(response.body);
      } else {
        throw Exception('Failed to load scoreboard: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
