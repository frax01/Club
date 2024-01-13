import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExtraPage extends StatefulWidget {
  const ExtraPage({super.key, required this.title});

  final String title;

  @override
  _ExtraPageState createState() => _ExtraPageState();
}

class _ExtraPageState extends State<ExtraPage> {
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
            FirebaseFirestore.instance.collection('club_extra').snapshots(),
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
              var extraData = documents[index].data() as Map<String, dynamic>;
              var title = extraData['title'] ?? '';
              var clubClass = extraData['selectedClass'] ?? '';
              var description = extraData['description'] ?? '';

              return ExtraBox(
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

class ExtraBox extends StatelessWidget {
  final String title;
  final String clubClass;
  final String description;

  ExtraBox({
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
