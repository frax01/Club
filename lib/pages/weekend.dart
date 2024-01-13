import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeekendPage extends StatefulWidget {
  const WeekendPage({super.key, required this.title});

  final String title;

  @override
  _WeekendPageState createState() => _WeekendPageState();
}

class _WeekendPageState extends State<WeekendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('club_weekend').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

          // Estrai la lista dei documenti da Firestore
          List<DocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var weekendData = documents[index].data() as Map<String, dynamic>;
              var title = weekendData['title'] ?? '';
              var clubClass = weekendData['selectedClass'] ?? '';
              var description = weekendData['description'] ?? '';

              return WeekendBox(
                title: title,
                clubClass: clubClass,
                description: description,
              );
            },
          );
        },
      ),
    );
  }
}

class WeekendBox extends StatelessWidget {
  final String title;
  final String clubClass;
  final String description;

  WeekendBox({
    required this.title,
    required this.clubClass,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Title: $title', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Club Class: $clubClass'),
          Text('Description: $description'),
        ],
      ),
    );
  }
}
