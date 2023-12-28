import 'package:flutter/material.dart';

class ClubButton extends StatefulWidget {
  const ClubButton({super.key});

  @override
  State<ClubButton> createState() => ClubButtonState();
}

class ClubButtonState extends State<ClubButton> {

  void _clubPage() {
    setState(() {
      Navigator.pushNamed(context, '/club');
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    var appBarHeight = AppBar().preferredSize.height;
    return GestureDetector(
      onTap: _clubPage,
      child: Column(
        children: <Widget>[
          Image(
            image: const AssetImage('images/Tiber.jpg'),
            height: height / 2 - appBarHeight,
            width: width / 2,
          ),
        ],
      ),
    );
  }
}

class FootballButton extends StatefulWidget {
  const FootballButton({super.key});

  @override
  State<FootballButton> createState() => FootballButtonState();
}

class FootballButtonState extends State<FootballButton> {

  void _footballPage() {
    setState(() {
      Navigator.pushNamed(context, '/football');
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    var appBarHeight = AppBar().preferredSize.height;
    return GestureDetector(
      onTap: _footballPage,
      child: Column(
        children: <Widget>[
          Image(
            image: const AssetImage('images/CC.jpeg'),
            height: height / 2 - appBarHeight,
            width: width / 2,
          ),
        ],
      ),
    );
  }
}
