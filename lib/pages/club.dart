import 'package:flutter/material.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({super.key, required this.title});

  final String title;

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  var section = 'CLUB';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        width: width>700? width/3 : width>400? width/2 : width/1.5,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Flexible(
                child: Image(
                  image: const AssetImage('images/photo.jpg'),
                  width: width/4,
                  height: height/4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Francesco ', style: TextStyle(fontSize: width>300? 18 : 14)),
                  Text('Martignoni', style: TextStyle(fontSize: width>300? 18 : 14)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Text('francescomartignoni1@gmail.com', textAlign: TextAlign.center, style: TextStyle(fontSize: width>500? 14 : width>300? 10 : 8)),
            ),
            DropdownButton(
              value: section,
              onChanged: (value) {
                setState(() {
                  section = value.toString();
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'CLUB',
                  child: Text('CLUB'),
                ),
                DropdownMenuItem(
                  value: 'FOOTBALL',
                  child: Text('FOOTBALL'),
                ),
              ],
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
              ),
              title: const Text('Home Page'),
              subtitle: const Text('Club'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.train,
              ),
              title: const Text('Trains'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}