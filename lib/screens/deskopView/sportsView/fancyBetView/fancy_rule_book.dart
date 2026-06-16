import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../reusables/colors.dart';

class FancyRulesDialog extends StatelessWidget {
  const FancyRulesDialog({super.key});
  static const String rules = '''<ol>
            <li>Once all session/fancy bets are completed and settled there will be no reversal even if the Match is
                Tied or is Abandoned.<ul>TEST MATCH RULE - 1.2 Middle session and Session is not completed due to
                    Innings declared or all out so that particular over considered as completed and remaining over
                    counted in next team Innings for ex:- In case of Innings declared or all out In 131.5th over
                    Considered as 132 over completed remaining 1 over counted for 133 over middle session and 3 over
                    counted for 135 over session from next team Innings and One over session and Only over session is
                    not completed due to innings declared so that Particular over session bets will be deleted and all
                    out considered as valid for ex:- In case of Innings declared In 131.5th over so 132 over will be
                    deleted and if all out then 132 over and Only 132 over&nbsp;will&nbsp;be&nbsp;Valid.</ul>
            </li>
            <li>Advance Session or Player Runs and all Fancy Bets are only valid for 20/50 overs full match each side.
                (Please Note this condition is applied only in case of Advance Fancy Bets only).<ul>&bull; Adv Session
                    Markets is Valid Only for First Innings of the Match</ul>
            </li>
            <li>All advance fancy bets market will be suspended 60 mins prior to match and will be settled.</li>
            <li>Under the rules of Session/Fancy Bets if a market gets Suspended for any reason whatsoever and does not
                resume then all previous Bets will remain Valid and become HAAR/JEET bets.</li>
            <li>Incomplete Session/Fancy Bet will be cancelled but Complete Session will be settled.</li>
            <li>In the case of Running Match getting Cancelled/ No Result/ Abandoned but the session is complete it will
                still be settled. Player runs / fall of wicket will be also settled at the figures where match gets
                stopped due to rain for the inning (D/L) , cancelled , abandoned , no result.</li>
            <li>If a player gets Retired Hurt and one ball is completed after you place your bets then all the betting
                till then is and will remain valid.
                We Consider Retired Out as Retired Hurt</li>
            <li>Should a Technical Glitch in Software occur, we will not be held responsible for any losses.</li>
            <li>Should there be a power failure or a problem with the Internet connection at our end and session/fancy
                market does not get suspended then our decision on the outcome is final.</li>
            <li>All decisions relating to settlement of wrong market being offered will be taken by management.
                Management will consider all actual facts and decision taken will be full in final.</li>
            <li>Any bets which are deemed of being suspicious, including bets which have been placed from the stadium or
                from a source at the stadium maybe voided at anytime. The decision of whether to void the particular bet
                in question or to void the entire market will remain at the discretion of Company. The final decision of
                whether bets are suspicious will be taken by Company and that decision will be full and final.</li>
            <li>Any sort of cheating bet , any sort of Matching (Passing of funds), Court Siding (Ghaobaazi on
                commentary), Sharpening, Commission making is not allowed in Company, If any company User is caught in
                any of such act then all the funds belonging that account would be seized and confiscated. No argument
                or claim in that context would be entertained and the decision made by company management will stand as
                final authority.</li>
            <li>Fluke hunting/Seeking is prohibited in Company , All the fluke bets will be reversed. Cricket commentary
                is just an additional feature and facility for company user but company is not responsible for any delay
                or mistake in commentary.</li>
            <li>Valid for only 1st inning.<ul>&bull; Highest Inning Run :- This fancy is valid only for first inning of the
                    match.</ul>
                <ul>&bull; Lowest Inning Run :- This fancy is valid only for first inning of the match.</ul>
            </li>
            <li>If any fancy value gets passed, we will settle that market after that match gets over. For example :- If
                any market value is ( 22-24 ) and incase the result is 23 than that market will be continued, but if the
                result is 24 or above then we will settle that market. This rule is for the following market.<ul>&bull; Total
                    Sixes In Single Match</ul>
                <ul>&bull; Total Fours In Single Match</ul>
                <ul>&bull; Highest Inning Run</ul>
                <ul>&bull; Highest Over Run In Single Match</ul>
                <ul>&bull; Highest Individual Score By Batsman</ul>
                <ul>&bull; Highest Individual Wickets By Bowler</ul>
            </li>
            <li>If any fancy value gets passed, we will settle that market after that match gets over. For example :- If
                any market value is ( 22-24 ) and incase the result is 23 than that market will be continued, but if the
                result is 22 or below then we will settle that market. This rule is for the following market.<ul>&bull;
                    Lowest Inning Run</ul>
                <ul>&bull; Fastest Fifty</ul>
                <ul>&bull; Fastest Century</ul>
            </li>
            <li>If any case wrong rate has been given in fancy ,that particular bets will be cancelled (Wrong
                Commentary).</li>
            <li>In case customer make bets in wrong fancy we are not liable to delete, no changes will be made and bets
                will be considered as confirm bet.</li>
            <li>Dot Ball Market Rules<ul>Wides Ball - Not Count</ul>
                <ul>No Ball - Not Count</ul>
                <ul>Leg Bye - Not Count as A Dot Ball</ul>
                <ul>Bye Run - Not Count as A Dot Ball</ul>
                <ul>Out - Catch Out, Bowled, Stumped, Run Out &amp; LBW Not Count&nbsp;as&nbsp;A&nbsp;Dot&nbsp;Ball</ul>
            </li>
            <li>Bookmaker Rules<ul>&bull; Due to any reason any team will be getting advantage or disadvantage we are not
                    concerned.</ul>
                <ul>&bull; We will simply compare both teams 25 overs score higher score team will be declared winner in ODI.
                </ul>
                <ul>&bull; We will simply compare both teams 10 overs higher score team will be declared winner in T20
                    matches.</ul>
            </li>
            <li>Penalty Runs - Any Penalty Runs Awarded in the Match (In Any Running Fancy or ADV Fancy) Will Not be
                Counted While Settling in our Exchange. Exception - Penalty runs will be counted on new offered fancy
                after getting penalty runs in running match .. for example if penalty given at 8th over and we offered
                new 15 over market after 8th over ..we will include penalty on that particular&nbsp;market&nbsp;.</li>
            <li>CHECK SCORE OF VIRTUAL CRICKET ON https://sportcenter.sir.sportradar.com/simulated-reality/cricket</li>
            <li>Comparison Market<ul>In Comparison Market We Don&apos;t Consider Tie or Equal Runs on Both the Innings While
                    Settling . Second Batting Team Must need to Surpass 1st Batting&apos;s team Total to win otherwise on
                    Equal Score or Below We declare 1st Batting Team as Winner .</ul>
            </li>
            <li>Boundary :-<ul>&bull; Player Boundaries Fancy:- We will only consider Direct Fours and Sixes hit by BAT.</ul>
                <ul>&bull; Boundary win rules :- When ball crosses the boundary and the stream shows this, it is considered
                    as boundary win. Regardless of whether the site shows the scores as 4 runs or a single, it will
                    consider as boundary.</ul>
            </li>
            <li>BOWLER RUN SESSION RULE :-<ul>IF BOWLER BOWL 1.1 OVER,THEN VALID ( FOR BOWLER 2 OVER RUNS SESSION )</ul>
                <ul>IF BOWLER BOWL 2.1 OVER,THEN VALID ( FOR BOWLER 3 OVER RUNS SESSION )</ul>
                <ul>IF BOWLER BOWL 3.1 OVER,THEN VALID ( FOR BOWLER 4 OVER RUNS SESSION )</ul>
                <ul>IF BOWLER BOWL 4.1 OVER,THEN VALID ( FOR BOWLER 5 OVER RUNS SESSION )</ul>
                <ul>IF BOWLER BOWL 9.1 OVER,THEN VALID ( FOR BOWLER 10 OVER RUNS SESSION )</ul>
            </li>
            <li>Total Match Playing Over ADV :- We Will Settle this Market after Whole Match gets Completed<ul>Criteria
                    :- We Will Count Only Round- Off Over For Both the Innings While Settling (For Ex :- If 1st Batting
                    team gets all out at 17.3 , 18.4 or 19.5 we Will Count Such Overs as 17, 18 and 19 Respectively and
                    if Match gets Ended at 17.2 , 18.3 or 19.3 Overs then we will Count that as 17 , 18 and 19 Over
                    Respectively... and this Will Remain Same For Both the Innings ..</ul>
                <ul>If over Reduces because of rain (either in 1st or 2nd innings), whole market will get voided</ul>
            </li>
            <li>3 WKT OR MORE BY BOWLER IN MATCH ADV :-<ul>We Will Settle this Market after Whole Match gets Completed .
                </ul>
                <ul>In Case Of Rain or if Over Gets Reduced then this Market Will get Voided</ul>
            </li>
            <li>KHADDA :-<ul>ADV Khadda Fancy is Valid Only for First Innings of the Match</ul>
                <ul>In Case of Rain or If Over Gets Reduced then this Market Will get Voided</ul>
                <ul>Incomplete Session Bet will be Cancelled but Complete Session Will be Settled</ul>
            </li>
            <li>LOTTERY :-<ul>In Case of Rain or If Over Gets Reduced then this Market Will get Voided</ul>
                <ul>Incomplete Session Bet will be Cancelled but Complete Session Will be Settled</ul>
                <ul>Criteria :- We will Only Count Last Digit of Sessions Total while settling ..For Example if in 6
                    Overs Market the Score is 37 ...so we will Settle the Market for 6 Over Lottery @ 7</ul>
            </li>
            <li>Any cricket event which is being held behind closed doors in that if any players found to be taking
                advantage of groundline in fancy bets in such cases bets can be voided after the market ends . Company
                decision to be final .</li>
            <li>Session Odd-Even Rule:-<ul>We Will Settle the Session ODD-EVEN Market only if the Over is Completed, But
                    If that Over is Not Completed then we will Void that &quot;Session Total Odd&quot; Market.</ul>
            </li>
            <li>Company reserves the right to void any bets (only winning bets) of any event at any point of the match
                if the company believes there is any cheating/wrong doing in that particular event by the players
                (either batsman/bowler)</li>
            <li>In the live match if the match scoreboard change or the TV&apos;s scoreboard have any issues, example
                (scoreboard not showing , team score change at any point), we will declare the result of the fancy based
                on the rate that we are offering in the live match. The final decision of the result will be taken by
                the company and that decision will be full and final.</li>
            <li>If there is a super over then the match odds of the Super Over will be settled after the Final result of
                winner team is declared but in case of Bookmaker we will Settle or Void the Particular super over
                Bookmaker Based upon that Particular Markets Result</li>
            <li>Total Match 30s: In this market, If player&apos;s score between 30 to 49 Runs that will be considered in this
                Market. If a player reached 50 or above, they aren&apos;t considerd in this event.</li>
            <li>Total Match Fifty - In this market, If player&apos;s score between 50 to 99 Runs that will be considered in
                this Market. If a player reached 100 or above, they aren&apos;t considerd in this event.</li>
            <li>We wont consider Retired hurt/Out of any player as a Wicket ..bets will remain valid and gets settled
                once wicket falls ..for e.g if wicket market is running and player gets retired out/hurt then we will
                wait for another player to get out for&nbsp;the&nbsp;settlement</li>
            <li>TOTAL OVER RUNS Rule :-<ul>&bull;If over Reduces because of rain (either in 1st or 2nd innings), whole market
                    will get voided</ul>
                <ul>&bull;Penalty runs will be counted&nbsp;in&nbsp;this&nbsp;market</ul>
            </li>
            <li>Total Match Four Hitters : Number of Batsman hitting Fours in full match.</li>
            <li>Total Match Six Hitters : Number of Batsman hitting Sixes in full match.</li>
            <li>Total Match Wicket Takers : Number of bowlers taking wickets in full match.</li>
            <li>Total No Boundaries overs : In this market, we do not consider boundaries resulting from wide balls,
                overthrow boundaries, leg byes etc.</li>
        </ol>''';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Center(
                child: Text(
                  'Rules of Fancy Bets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: black),
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 420,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Html(
                    data: rules,
                    style: {
                      'body': Style(fontSize: FontSize(13), lineHeight: LineHeight(1.4), color: secondaryTextClr),
                      'li': Style(fontSize: FontSize(13), lineHeight: LineHeight(1.4), color: secondaryTextClr),
                      'ul': Style(fontSize: FontSize(13), lineHeight: LineHeight(1.4), color: secondaryTextClr),
                      'ol': Style(fontSize: FontSize(13), lineHeight: LineHeight(1.4), color: secondaryTextClr),
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade300, foregroundColor: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK', style: TextStyle(color: black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showFancyRulesDialog(BuildContext context) {
  showDialog(context: context, builder: (ctx) => const FancyRulesDialog());
}
