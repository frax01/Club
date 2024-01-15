import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubEventPage extends StatefulWidget {
  const ClubEventPage(
      {Key? key, required this.documentId, required this.Option})
      : super(key: key);

  final String documentId;
  final String Option;
  //final String title = 'Club Event';

  @override
  _ClubEventPageState createState() => _ClubEventPageState();
}

class _ClubEventPageState extends State<ClubEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String title = '';
  String selectedOption = '';
  String imagePath = '';
  String selectedClass = '';
  String description = '';

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('club_${widget.Option}')
        .doc(widget.documentId)
        .get();

    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    setState(() {
      titleController.text = data['title'];
      title = titleController.text;
      selectedOption = data['selectedOption'];
      selectedClass = data['selectedClass'];
      descriptionController.text = data['description'];
    });
  }

  Future<void> updateClubDetails() async {
    try {
      if (title == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a title')));
        return;
      }
      if (selectedOption == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an option')));
        return;
      }
      if (selectedClass == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a class')));
        return;
      }

      //FirebaseFirestore firestore = FirebaseFirestore.instance;
      //QuerySnapshot querySnapshot = await firestore.collection('club_$selectedOption').where('title', isEqualTo: title).get();
      //String documentId = querySnapshot.docs.first.id;
      //.doc(_selected
      // Aggiorna i dati nel documento
      await FirebaseFirestore.instance
          .collection('club_${widget.Option}')
          .doc(widget.documentId)
          .delete();

      await FirebaseFirestore.instance
          .collection('club_$selectedOption')
          .add({
        'title': title,
        'selectedOption': selectedOption,
        'selectedClass': selectedClass,
        'description': description,
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error updating user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: titleController,
                onChanged: (value) {
                  title = value;
                },
                decoration: InputDecoration(labelText: 'Titolo'),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                  });
                },
                items: ['', 'weekend', 'trip', 'summer', 'extra']
                    .map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                hint: Text('Seleziona un\'opzione'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  //String imageUrl = await event.uploadImage();
                  //// Aggiorna il percorso dell'immagine nel tuo oggetto evento
                  //setState(() {
                  //  event.imagePath = imageUrl;
                  //});
                  // Implementa la logica per caricare un'immagine
                  // Puoi utilizzare il pacchetto image_picker per questo
                  // https://pub.dev/packages/image_picker
                  // Aggiorna il percorso dell'immagine nel tuo oggetto evento
                },
                child: Text('Carica Immagine'),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedClass,
                onChanged: (value) {
                  setState(() {
                    selectedClass = value!;
                  });
                },
                items: [
                  '',
                  '1st',
                  '2nd',
                  '3rd',
                  '1st hs',
                  '2nd hs',
                  '3rd hs',
                  '4th hs',
                  '5th hs'
                ].map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                hint: Text('Seleziona un\'opzione'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: descriptionController,
                onChanged: (value) {
                  description = value;
                },
                decoration: InputDecoration(labelText: 'Testo'),
                maxLines: null,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await updateClubDetails();
                  }
                },
                child: Text('Crea'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
