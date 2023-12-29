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
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              underline: Container(
                height: 0.5,
                color: Colors.black,
              ),
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
                Icons.home_filled,
              ),
              title: const Text('Home Page'),
              subtitle: Text('Club', style: TextStyle(fontSize: width>700? 12 : width>500? 14 : width>400? 11 : width>330? 12 : 10)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.calendar_month_outlined,
              ),
              title: const Text('Saturday'),
              subtitle: Text('Look at the program', style: TextStyle(fontSize: width>700? 12 : width>500? 14 : width>400? 11 : width>330? 12 : 10)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.holiday_village_outlined,
              ),
              title: const Text('Trips'),
              subtitle: Text('Where does your class go?', style: TextStyle(fontSize: width>700? 12 : width>500? 14 : width>400? 11 : width>330? 12 : 10)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.sunny,
              ),
              title: const Text('Summer'),
              subtitle: Text('The best period of the year', style: TextStyle(fontSize: width>700? 12 : width>500? 14 : width>400? 11 : width>330? 12 : 10)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.plus_one_outlined,
              ),
              title: const Text('Extra'),
              subtitle: Text('What are you waiting for?', style: TextStyle(fontSize: width>700? 12 : width>500? 14 : width>400? 11 : width>330? 12 : 10)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.chat,
              ),
              title: const Text('Chat & Contacts'),
              subtitle: Text('Do you need more information?', style: TextStyle(fontSize: width>700? 12 : width>500? 14 : width>400? 11 : width>330? 12 : 10)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
              ),
              title: const Text('Settings'),
              subtitle: Text('Account management', style: TextStyle(fontSize: width>700? 12 : width>500? 14 : width>400? 11 : width>330? 12 : 10)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.code,
              ),
              title: const Text('Code generation'),
              subtitle: Text('Accept new users', style: TextStyle(fontSize: width>700? 12 : width>500? 14 : width>400? 11 : width>330? 12 : 10)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.mode,
              ),
              title: const Text('Page modifier'),
              subtitle: Text('Create a new program!', style: TextStyle(fontSize: width>700? 12 : width>500? 14 : width>400? 11 : width>330? 12 : 10)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
              ),
              title: const Text('Logout'),
              subtitle: Text('We will miss you...', style: TextStyle(fontSize: width>700? 12 : width>500? 14 : width>400? 11 : width>330? 12 : 10)),
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