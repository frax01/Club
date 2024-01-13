import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key, required this.title});

  final String title;

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
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
            FirebaseFirestore.instance.collection('club_trip').snapshots(),
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
              var tripData = documents[index].data() as Map<String, dynamic>;
              var title = tripData['title'] ?? '';
              var clubClass = tripData['selectedClass'] ?? '';
              var description = tripData['description'] ?? '';

              return TripBox(
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

class TripBox extends StatelessWidget {
  final String title;
  final String clubClass;
  final String description;

  TripBox({
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
