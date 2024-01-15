import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key, required this.title});

  final String title;

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {

  bool imageUploaded = false;

  Future<String> uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    // Seleziona un'immagine dalla galleria
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      throw Exception('No image selected');
    }

    // Crea un riferimento a Firebase Storage
    final Reference ref = FirebaseStorage.instance.ref().child('club_image/${DateTime.now().toIso8601String()}');

    // Carica l'immagine su Firebase Storage
    final UploadTask uploadTask = ref.putData(await image.readAsBytes());

    // Attendi il completamento del caricamento
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

    // Ottieni l'URL dell'immagine caricata
    final String imageUrl = await snapshot.ref.getDownloadURL();

    print(imageUrl);

    setState(() {
      imageUploaded = true;
    });

    return imageUrl;
  }

  Future<void> deleteImage() async {
    // Ottieni il riferimento all'immagine
    final Reference ref = FirebaseStorage.instance.ref().child(imagePath);
    // Elimina l'immagine
    await ref.delete();
    // Imposta imageUploaded a false e imagePath a stringa vuota
    setState(() {
      imageUploaded = false;
      imagePath = '';
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String title = '';
  String selectedOption = '';
  String imagePath = '';
  String selectedClass = '';
  String description = '';

  Future<void> createEvent() async {
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

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('club_$selectedOption').add({
        'title': title,
        'selectedOption': selectedOption,
        'imagePath': imagePath,
        'selectedClass': selectedClass,
        'description': description,
      });
      print('Evento creato con successo!');
      Navigator.pop(context);
    } catch (e) {
      print('Errore durante la creazione dell\'evento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
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
                onPressed: imageUploaded ? null : () async {
                  String imageUrl = await uploadImage();
                  setState(() {
                    imagePath = imageUrl;
                  });
                },
                child: Text(imageUploaded ? 'Immagine caricata' : 'Carica Immagine'),
              ),
              if (imageUploaded) ...[
                ElevatedButton(
                  onPressed: () async {
                    // Mostra un dialogo di conferma prima di eliminare l'immagine
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Conferma'),
                          content: Text('Sei sicuro di voler eliminare l\'immagine?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Annulla'),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: Text('Elimina'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true) {
                      await deleteImage();
                    }
                  },
                  child: Text('Elimina Immagine'),
                ),
              ],
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
                    await createEvent();
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
