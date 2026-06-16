import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/event_with_type_model.dart';
import '../../../reusables/colors.dart';
import '../../../reusables/formatters.dart';
import '../../../reusables/game_tag.dart';

List<String> buildEventTags(Event event) {
  final List<String> tags = [];

  final bool isLive = event.inPlay;
  // Session tag (ALWAYS visible)

  if (isLive) {
    tags.add('In-Play');
  }
  
  if (event.openDate.isNotEmpty && !isLive) {
    tags.add(formatUtcToLocal(event.openDate));
  }
  // Play tag
  if (isLive) {
    tags.add('Play');
  }

  // Fancy market
  if (event.fancyMarket) {
    tags.add('F');
  }

  // Bookmaker market
  if (event.bookMakerMarket) {
    tags.add('B');
  }

  // Premium
  if (event.premiumMatch) {
    tags.add('P');
  }

  // Esport / Game title
  if (event.eSportMarket) {
    tags.add('Soccer');
  }

  return tags;
}

class TagSelector extends StatelessWidget {
  final String label;
  final bool isLive;

  const TagSelector({super.key, required this.label, this.isLive = false});
  @override
  Widget build(BuildContext context) {
    if (label == 'P') {
      return const PTag();
    } else if (label == 'Play') {
      return const PlayTag();
    } else if (label == 'Soccer' || label == 'Cricket') {
      return GameTitleTag(gameTitle: label);
    } else if (label == 'F') {
      return const FBTag(isFTag: true);
    } else if (label == 'B') {
      return const FBTag(isFTag: false);
    } else {
      return TextOnlyTag(title: label, isLive: isLive);
    }
  }
}

class GameTitleTag extends StatelessWidget {
  final String gameTitle;
  const GameTitleTag({super.key, required this.gameTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: grey),
      ),
      child: Row(
        children: [
          ClipPath(
            clipper: SlantedTagClipper(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 11, vertical: 2),
              decoration: BoxDecoration(color: Color(0xff1F5172)),
              child: Text(
                'E',
                style: TextStyle(color: white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            gameTitle,
            style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}

class FBTag extends StatelessWidget {
  final bool isFTag;
  const FBTag({super.key, required this.isFTag});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
            color: green,
          ),
          child: Center(child: Icon(Icons.alarm, color: white, size: 18)),
        ),
        Container(
          width: 30,
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
            color: isFTag ? cyan : blueShade,
          ),
          child: Center(
            child: Text(
              isFTag ? 'F' : 'B',
              style: isFTag ? GoogleFonts.russoOne(fontSize: 15, color: cyanShade1) : TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: white),
            ),
          ),
        ),
      ],
    );
  }
}

class TextOnlyTag extends StatelessWidget {
  final String title;
  final bool isLive;
  const TextOnlyTag({super.key, required this.title, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(color: isLive ? green : black));
  }
}

class SlantedTagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0); // top-left
    path.lineTo(size.width, 0); // top-right (slant start)
    path.lineTo(size.width - 8, size.height); // bottom-right slant
    path.lineTo(0, size.height); // bottom-left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
