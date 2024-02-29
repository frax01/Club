import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:club/pages/main/login.dart';
import 'package:club/pages/football/football.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:club/pages/main/setting.dart';
import 'package:club/pages/club/box.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({super.key, required this.title, required this.document});

  final Map document;
  final String title;

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  String section = 'CLUB';
  String _selectedLevel = 'weekend';
  bool imageUploaded = false;

  _saveLastPage(String page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastPage', page);
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

  Map<String, dynamic> allPrefs = prefs.getKeys().fold<Map<String, dynamic>>(
    {},
    (Map<String, dynamic> acc, String key) {
      acc[key] = prefs.get(key);
      return acc;
    },
  );

  print("SharedPreferences: $allPrefs");

    await FirebaseAuth.instance.signOut();
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const Login(title: 'Tiber Club')));
    });
  }

  Future<String> _startDate(BuildContext context, String startDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        startDate = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
    return startDate;
  }

  Future<String> _endDate(
      BuildContext context, String startDate, String endDate) async {
    if (startDate == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select the startDate first')));
      return '';
    } else {
      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
      DateTime date = inputFormat.parse(startDate);
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      String formattedStartDate = outputFormat.format(date);
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(formattedStartDate),
        firstDate: DateTime.parse(formattedStartDate),
        lastDate:
            DateTime.parse(formattedStartDate).add(const Duration(days: 365)),
      );
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          endDate = DateFormat('dd-MM-yyyy').format(picked);
        });
      }
    }
    return endDate;
  }

  Future<String> deleteImage(String imagePath) async {
    // Ottieni il riferimento all'immagine
    final Reference ref = FirebaseStorage.instance.ref().child(imagePath);
    // Elimina l'immagine
    await ref.delete();
    // Imposta imageUploaded a false e imagePath a stringa vuota
    setState(() {
      imageUploaded = false;
      imagePath = '';
    });
    return imagePath;
  }

  Future<String> uploadImage() async {
    final ImagePicker picker = ImagePicker();
    // Seleziona un'immagine dalla galleria
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      throw Exception('No image selected');
    }

    // Crea un riferimento a Firebase Storage
    final Reference ref = FirebaseStorage.instance
        .ref()
        .child('users/${DateTime.now().toIso8601String()}');
    //.child('${section}_image/${DateTime.now().toIso8601String()}');

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

  Future<void> createEvent(String event, String imagePath, String clubClass,
      String startDate, String endDate, String description) async {
    try {
      if (event == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a title')));
        return;
      }
      if (clubClass == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a class')));
        return;
      }
      if ((_selectedLevel == 'weekend' || _selectedLevel == 'extra') &&
          startDate == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a date')));
        return;
      }
      if ((_selectedLevel == 'trip') && (startDate == "" || endDate == "")) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please select the start and the end date')));
        return;
      }
      if (description == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a description')));
        return;
      }
      if (imagePath == '') {
        imagePath = 'images/$_selectedLevel/default.jpg';
      }
      print("section: ${section.toLowerCase()}");

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore
          .collection('${section.toLowerCase()}_$_selectedLevel')
          .add({
        'title': event,
        'selectedOption': _selectedLevel,
        'imagePath': imagePath,
        'selectedClass': clubClass,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
      });
      print('Evento creato con successo!');
      Navigator.pop(context);
    } catch (e) {
      print('Errore durante la creazione dell\'evento: $e');
    }
  }

  Future<void> _showAddEvent(String level) async {
    String event = '';
    String imagePath = '';
    String clubClass = '';
    //String soccer_class = '';
    String startDate = '';
    String endDate = '';
    String description = '';
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(level),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Titolo'),
                    onChanged: (value) {
                      setState(() {
                        event = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: clubClass,
                    onChanged: (value) {
                      setState(() {
                        clubClass = value!;
                      });
                    },
                    items: ['', '1° media', '2° media', '3° media']
                        .map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    hint: const Text('Seleziona una classe'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: imageUploaded
                        ? null
                        : () async {
                            String imageUrl = await uploadImage();
                            setState(() {
                              imagePath = imageUrl;
                            });
                          },
                    child: Text(imageUploaded
                        ? 'Immagine caricata'
                        : 'Carica Immagine'),
                  ),
                  const SizedBox(height: 16.0),
                  if (imageUploaded) ...[
                    ElevatedButton(
                      onPressed: () async {
                        // Mostra un dialogo di conferma prima di eliminare l'immagine
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Conferma'),
                              content: const Text(
                                  'Sei sicuro di voler eliminare l\'immagine?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Annulla'),
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context).pop(false);
                                    });
                                  },
                                ),
                                TextButton(
                                  child: const Text('Elimina'),
                                  onPressed: () {
                                    setState(() {
                                      imageUploaded = false;
                                      Navigator.of(context).pop(true);
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          await deleteImage(imagePath);
                        }
                      },
                      child: const Text('Elimina Immagine'),
                    ),
                  ],
                  const SizedBox(height: 16.0),
                  ...(_selectedLevel == 'weekend' || _selectedLevel == 'extra')
                      ? [
                          ElevatedButton(
                            onPressed: () async {
                              startDate = await _startDate(context, startDate);
                            },
                            child: const Text('Date'),
                          ),
                        ]
                      : (_selectedLevel == 'trip' ||
                              _selectedLevel == 'tournament')
                          ? [
                              ElevatedButton(
                                onPressed: () async {
                                  startDate =
                                      await _startDate(context, startDate);
                                },
                                child: const Text('Start date'),
                              ),
                              const SizedBox(height: 16.0),
                              ElevatedButton(
                                onPressed: () async {
                                  endDate = await _endDate(
                                      context, startDate, endDate);
                                },
                                child: const Text('End date'),
                              ),
                            ]
                          : [],
                  const SizedBox(height: 16.0),
                  TextFormField(
                    onChanged: (value) {
                      description = value;
                    },
                    decoration: const InputDecoration(labelText: 'Descrizione'),
                    maxLines: null,
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Annulla'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await createEvent(event, imagePath, clubClass,
                              startDate, endDate, description);
                        },
                        child: const Text('Crea'),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    print("title: ${widget.title}");
    print("document: ${widget.document}");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
          child: Box(
        level: _selectedLevel,
        clubClass: widget.document['club_class'],
        section: section.toLowerCase(),
      )),
      drawer: Drawer(
        width: width > 700
            ? width / 3
            : width > 400
                ? width / 2
                : width / 1.5,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image(
                image: const AssetImage('images/logo.png'),
                width: width > 700 ? width / 4 : width / 8,
                height: height / 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${widget.document['name']} ',
                      style: TextStyle(fontSize: width > 300 ? 18 : 14)),
                  Text('${widget.document['surname']}',
                      style: TextStyle(fontSize: width > 300 ? 18 : 14))
                ],
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Text('${widget.document['club_class']}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: width > 500
                            ? 14
                            : width > 300
                                ? 10
                                : 8))),
            Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: Text('${widget.document['email']}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: width > 500
                            ? 14
                            : width > 300
                                ? 10
                                : 8))),
            DropdownButton(
              value: section,
              onChanged: (value) {
                if (widget.document['soccer_class'] != '') {
                  setState(() {
                    section = value.toString();
                    if (section == 'FOOTBALL') {
                      _saveLastPage('FootballPage');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FootballPage(
                                    title: 'Tiber Club',
                                    document: widget.document,
                                  )));
                    }
                  });
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Non fai ancora parte di una squadra')),
                  );
                }
              },
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              underline: Container(
                height: 0.5,
                color: Colors.black,
              ),
              items: const [
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
                Icons.settings,
              ),
              title: const Text('Settings'),
              subtitle: Text('Account management',
                  style: TextStyle(
                      fontSize: width > 700
                          ? 12
                          : width > 500
                              ? 14
                              : width > 400
                                  ? 11
                                  : width > 330
                                      ? 12
                                      : 10)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(
                              id: widget.document['id'],
                            )));
              },
            ),
            widget.document['status'] == 'Admin'
                ? ListTile(
                    leading: const Icon(
                      Icons.code,
                    ),
                    title: const Text('Incoming requests'),
                    subtitle: Text('Accept new users',
                        style: TextStyle(
                            fontSize: width > 700
                                ? 12
                                : width > 500
                                    ? 14
                                    : width > 400
                                        ? 11
                                        : width > 330
                                            ? 12
                                            : 10)),
                    onTap: () {
                      Navigator.pushNamed(context, '/acceptance');
                    },
                  )
                : Container(),
            ListTile(
              leading: const Icon(
                Icons.logout,
              ),
              title: const Text('Logout'),
              subtitle: Text('We will miss you...',
                  style: TextStyle(
                      fontSize: width > 700
                          ? 12
                          : width > 500
                              ? 14
                              : width > 400
                                  ? 11
                                  : width > 330
                                      ? 12
                                      : 10)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () async {
                            await _logout();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: widget.document['status'] == 'Admin'
          ? FloatingActionButton(
              onPressed: () {
                _showAddEvent(_selectedLevel);
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 130, 16, 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  _selectedLevel = 'weekend';
                });
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.calendar_month_outlined, color: Colors.white),
                  Text('Weekend', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedLevel = 'trip';
                });
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.calendar_month_outlined, color: Colors.white),
                  Text('Trip', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedLevel = 'extra';
                });
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.calendar_month_outlined, color: Colors.white),
                  Text('Extra', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//class Box extends StatefulWidget {
//
//  const Box({
//    required this.level,
//    required this.clubClass,
//    required this.section,
//  });
//
//  final String level;
//  final String clubClass;
//  final String section;
//
//  @override
//  State<Box> createState() => _BoxState();
//}
//
//class _BoxState extends State<Box> {
//  List<Map<String, dynamic>> documents = [];
//  String? title;
//  String? startDate;
//  String? imagePath;
//  String? description;
//  bool imageUploaded = true;
//
//  Future<void> _fetchData() async {
//    CollectionReference users = FirebaseFirestore.instance.collection('club_${widget.level}');
//    QuerySnapshot querySnapshot = await users.where('selectedClass', isEqualTo: widget.clubClass).get();
//    print(querySnapshot.docs);
//    if (querySnapshot.docs.isNotEmpty) {
//      documents = querySnapshot.docs.map((doc) => {
//        'id': doc.id, // Here is how you get the document ID
//        ...doc.data() as Map<String, dynamic>
//      }).toList();   
//    }
//    return Future.value();
//  }
//
//    Future<String> _startDate(BuildContext context, String startDate) async {
//    final DateTime? picked = await showDatePicker(
//      context: context,
//      initialDate: DateTime.now(),
//      firstDate: DateTime.now(),
//      lastDate: DateTime.now().add(const Duration(days: 365)),
//    );
//    if (picked != null) { // && picked != DateTime.now()
//      setState(() {
//        startDate = DateFormat('dd-MM-yyyy').format(picked);
//      });
//    }
//    return startDate;
//  }
//
//  Future<String> _endDate(BuildContext context, String startDate, String endDate) async {
//    if (startDate == "") {
//      ScaffoldMessenger.of(context).showSnackBar(
//          const SnackBar(content: Text('Please select the startDate first')));
//      return '';
//    } else {
//      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
//      DateTime date = inputFormat.parse(startDate);
//      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
//      String formattedStartDate = outputFormat.format(date);
//      final DateTime? picked = await showDatePicker(
//        context: context,
//        initialDate: DateTime.parse(formattedStartDate),
//        firstDate: DateTime.parse(formattedStartDate),
//        lastDate:
//            DateTime.parse(formattedStartDate).add(const Duration(days: 365)),
//      );
//      if (picked != null && picked != DateTime.now()) {
//        setState(() {
//          endDate = DateFormat('dd-MM-yyyy').format(picked);
//        });
//      }
//    }
//    return endDate;
//  }
//
//  Future<Map> loadBoxData(String id) async {
//    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
//        .collection('${widget.section}_${widget.level}')
//        .doc(id)
//        .get();
//
//    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
//    Map<String, dynamic> editData = {};
//    setState(() {
//      editData = { 
//        'id': documentSnapshot.id,
//        'title': data['title'],
//        'imagePath': data['imagePath'],
//        'selectedLevel': widget.level,
//        'selectedClass': data['selectedClass'],
//        'description': data['description'],
//        'startDate': data['startDate'] ?? '',
//        'endDate': data['endDate'] ?? '',
//      };
//    });
//    return editData;
//  }
//
//  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//  Future<void> deleteDocument(String collection, String docId) async {
//    await _firestore.collection(collection).doc(docId).delete();
//  }
//
//  Future<String> deleteImage(String imagePath) async {
//    // Ottieni il riferimento all'immagine
//    final Reference ref = FirebaseStorage.instance.ref().child(imagePath); //il problema è che l'immagine che eliminiamo (images/...) non esiste nel firebase, va prima caricata correttamente
//    // Elimina l'immagine
//    await ref.delete();
//    // Imposta imageUploaded a false e imagePath a stringa vuota
//    setState(() {
//      imageUploaded = false;
//      imagePath = '';
//    });
//    return imagePath;
//  }
//
//  Future<void> _showEditDialog(String level, Map<dynamic, dynamic> data) async {
//    print(data);
//    final TextEditingController titleController = TextEditingController();
//    final TextEditingController descriptionController = TextEditingController();
//    String newTitle = data['title'];
//    //String selectedOption = data['selectedLevel'];
//    String imagePath = data['imagePath'];
//    String selectedClass = data['selectedClass'];
//    String description = data['description'];
//    String startDate = data['startDate'] ?? '';
//    String endDate = data['endDate'] ?? '';
//    print('1');
//
//    titleController.text = data['title'];
//    descriptionController.text = data['description'];
//    return showDialog<void>(
//      context: context,
//      builder: (BuildContext context) {
//        return StatefulBuilder(
//          builder: (context, setState) {
//            return AlertDialog(
//              title: Text('${level}'),
//              content: Column(
//            mainAxisSize: MainAxisSize.min,
//            children: [
//              TextFormField(
//                controller: titleController,
//                onChanged: (value) {
//                  newTitle = value;
//                },
//                decoration: InputDecoration(labelText: 'Titolo'),
//              ),
//              SizedBox(height: 16.0),
//              DropdownButtonFormField<String>(
//                value: data['selectedClass'],
//                onChanged: (value) {
//                  setState(() {
//                    selectedClass = value!;
//                  });
//                },
//                items: [
//                  '',
//                  '1° media',
//                  '2° media',
//                  '3° media'
//                ].map((String option) {
//                  return DropdownMenuItem<String>(
//                    value: option,
//                    child: Text(option),
//                  );
//                }).toList(),
//                hint: Text('Seleziona un\'opzione'),
//              ),
//              SizedBox(height: 16.0),
//                  ElevatedButton(
//                    onPressed: imageUploaded
//                        ? null
//                        : () async {
//                            String imageUrl = await uploadImage();
//                            setState(() {
//                              imagePath = imageUrl;
//                            });
//                          },
//                    child: Text(
//                        imageUploaded ? 'Immagine caricata' : 'Carica Immagine'),
//                  ),
//                  SizedBox(height: 16.0),
//               //  if (imageUploaded) ...[
//               //ElevatedButton(
//               //  onPressed: () async {
//               //    // Mostra un dialogo di conferma prima di eliminare l'immagine
//               //    bool? confirm = await showDialog<bool>(
//               //      context: context,
//               //      builder: (BuildContext context) {
//               //        return AlertDialog(
//               //          title: Text('Conferma'),
//               //          content: Text(
//               //              'Sei sicuro di voler eliminare l\'immagine?'),
//               //          actions: <Widget>[
//               //            TextButton(
//               //              child: Text('Annulla'),
//               //              onPressed: () {
//               //                setState(() {
//               //                  Navigator.of(context).pop(false);
//               //                });
//               //              },
//               //            ),
//               //            TextButton(
//               //              child: Text('Elimina'),
//               //              onPressed: () {
//               //                setState(() {
//               //                  imageUploaded = false;
//               //                });
//               //                Navigator.of(context).pop(true);
//               //              },
//               //            ),
//               //          ],
//               //        );
//               //      },
//               //    );
//               //    if (confirm == true) {
//               //      await deleteImage(imagePath);
//               //      //print(level);
//               //    }
//               //  },
//               //  child: Text('Elimina Immagine'),
//               //),
//              SizedBox(height: 16.0),
//              ...(level == 'weekend' || level == 'extra')
//                  ? [
//                      ElevatedButton(
//                        onPressed: () async {
//                          String newDate = await _startDate(context, data['startDate']);
//                          setState(() {
//                            startDate = newDate;
//                          });
//                        },
//                        child: Text('$startDate'),
//                      ),
//                    ]
//                  : (level == 'trip' || level == 'tournament')
//                      ? [
//                          ElevatedButton(
//                            onPressed: () async {
//                              String newDate = await _startDate(context, data['startDate']);
//                              setState(() {
//                                startDate = newDate;
//                              });
//                            },
//                            child: Text('$startDate'),
//                          ),
//                          ElevatedButton(
//                            onPressed: () async {
//                              String newDate = await _endDate(context, data['startDate'], data['endDate']);
//                              setState(() {
//                                endDate = newDate;
//                              });
//                            },
//                            child: Text('$endDate'),
//                          ),
//                        ]
//                      : [],
//              SizedBox(height: 16.0),
//              TextFormField(
//                controller: descriptionController,
//                onChanged: (value) {
//                  description = value;
//                },
//                decoration: InputDecoration(labelText: 'Testo'),
//                maxLines: null,
//              ),
//              SizedBox(height: 16.0),
//              ElevatedButton(
//                onPressed: () async {
//                  await updateClubDetails(data['id'], newTitle, imagePath, selectedClass, startDate, endDate, description);
//                },
//                child: Text('Crea'),
//              ),
//            ]//]
//          ),
//            );
//          },
//        );
//      }
//    );
//  }
//
//  Future<void> updateClubDetails(String id, String newTitle, String imagePath, String selectedClass, String startDate, String endDate, String description) async {
//    try {
//      if (title == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a title')));
//        return;
//      }
//      if (selectedClass == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a class')));
//        return;
//      }
//
//      await FirebaseFirestore.instance
//          .collection('${widget.section}_${widget.level}')
//          .doc(id)
//          .delete();
//      await FirebaseFirestore.instance.collection('${widget.section}_${widget.level}').add({
//        'title': newTitle,
//        'imagePath': imagePath,
//        'selectedClass': selectedClass,
//        'selectedOption': widget.level,
//        'description': description,
//        'startDate': startDate,
//        'endDate': endDate,
//      });
//      Navigator.pop(context);
//    } catch (e) {
//      print('Error updating user details: $e');
//    }
//  }
//
//  Future<String> uploadImage() async {
//    final ImagePicker _picker = ImagePicker();
//    // Seleziona un'immagine dalla galleria
//    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//
//    if (image == null) {
//      throw Exception('No image selected');
//    }
//
//    // Crea un riferimento a Firebase Storage
//    final Reference ref = FirebaseStorage.instance
//        .ref()
//        .child('users/${DateTime.now().toIso8601String()}');
//        //.child('${section}_image/${DateTime.now().toIso8601String()}');
//
//    // Carica l'immagine su Firebase Storage
//    final UploadTask uploadTask = ref.putData(await image.readAsBytes());
//
//    // Attendi il completamento del caricamento
//    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
//
//    // Ottieni l'URL dell'immagine caricata
//    final String imageUrl = await snapshot.ref.getDownloadURL();
//
//    print(imageUrl);
//
//    setState(() {
//      imageUploaded = true;
//    });
//
//    return imageUrl;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return FutureBuilder(
//      future: _fetchData(),
//      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
//        if (snapshot.connectionState == ConnectionState.waiting) {
//          return CircularProgressIndicator();
//        } else {
//          documents.sort((a, b) => (a['startDate'] as String).compareTo(b['startDate'] as String));
//          return ListView.builder(
//            itemCount: documents.length,
//            itemBuilder: (context, index) {
//              var document = documents[index];
//              var id = document['id'];
//              var title = document['title'];
//              var level = document['selectedOption'];
//              var startDate = document['startDate'];
//              //var imagePath = document['imagePath'];
//              var description = document['description'];
//              return Container(
//                margin: EdgeInsets.all(10.0),
//                padding: EdgeInsets.all(15.0),
//                decoration: BoxDecoration(
//                  border: Border.all(),
//                  borderRadius: BorderRadius.circular(10.0),
//                ),
//                child: Row(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: [
//                    Expanded(
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: [
//                          Text('Title: $title', style: TextStyle(fontWeight: FontWeight.bold)),
//                          Text('StartDate: $startDate'),
//                          Text('Club Class: ${widget.clubClass}'),
//                          if(document['endDate']!='') Text('EndDate: ${document['endDate']}'),
//                          Image(
//                            image: NetworkImage('images/$level/default.jpg'), //dovrebbe essere '${document['imagePath']}', ma non carica bene...
//                            height: 100,
//                            width:100,
//                          ),
//                          Text('Description: $description'),
//                        ],
//                      ),
//                    ),
//                    Column(
//                      children: [
//                        IconButton(
//                          icon: const Icon(Icons.edit),
//                          onPressed: () async {
//                            Map<dynamic, dynamic> data = {};
//                            data = await loadBoxData(id);
//                            _showEditDialog(widget.level, data);
//                          },
//                        ),
//                        IconButton(
//                          icon: Icon(Icons.delete),
//                          onPressed: () async {
//                            bool? shouldDelete = await showDialog(
//                              context: context,
//                              builder: (BuildContext context) {
//                                return AlertDialog(
//                                  title: Text('Confirm'),
//                                  content: Text(
//                                      'Are you sure you want to delete this item?'),
//                                  actions: <Widget>[
//                                    TextButton(
//                                      child: Text('Cancel'),
//                                      onPressed: () {
//                                        Navigator.of(context).pop(false);
//                                      },
//                                    ),
//                                    TextButton(
//                                      child: Text('Delete'),
//                                      onPressed: () {
//                                        Navigator.of(context).pop(true);
//                                      },
//                                    ),
//                                  ],
//                                );
//                              },
//                            );
//                            if (shouldDelete == true) {
//                              setState(() {
//                                deleteDocument('${widget.section}_${widget.level}', id);
//                              });
//                            }
//                          },
//                        ),
//                      ],
//                    ),
//                  ],
//                ),
//              );
//            },
//          );
//        }
//      },
//    );
//  }
//}

//import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:club/pages/main/login.dart';
//import 'package:club/pages/football/football.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:intl/intl.dart';
//import 'package:club/pages/main/setting.dart';
//
//class ClubPage extends StatefulWidget {
//  const ClubPage(
//    {super.key, 
//    required this.title,
//    required this.document});
//
//  final Map document;
//  final String title;
//
//  @override
//  State<ClubPage> createState() => _ClubPageState();
//}
//
//class _ClubPageState extends State<ClubPage> {
//  String section = 'CLUB';
//  String _selectedLevel = 'weekend';
//  bool imageUploaded = false;
//
//  _saveLastPage(String page) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString('lastPage', page);
//  }
//
//  Future<void> _logout() async {
//    await FirebaseAuth.instance.signOut();
//    setState(() {
//      Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) => Login(title: 'Tiber Club', logout: true)));
//    });
//  }
//
//  Future<String> _startDate(BuildContext context, String startDate) async {
//    final DateTime? picked = await showDatePicker(
//      context: context,
//      initialDate: DateTime.now(),
//      firstDate: DateTime.now(),
//      lastDate: DateTime.now().add(const Duration(days: 365)),
//    );
//    if (picked != null && picked != DateTime.now()) {
//      setState(() {
//        startDate = DateFormat('dd-MM-yyyy').format(picked);
//      });
//    }
//    return startDate;
//  }
//
//  Future<String> _endDate(BuildContext context, String startDate, String endDate) async {
//    if (startDate == "") {
//      ScaffoldMessenger.of(context).showSnackBar(
//          const SnackBar(content: Text('Please select the startDate first')));
//      return '';
//    } else {
//      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
//      DateTime date = inputFormat.parse(startDate);
//      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
//      String formattedStartDate = outputFormat.format(date);
//      final DateTime? picked = await showDatePicker(
//        context: context,
//        initialDate: DateTime.parse(formattedStartDate),
//        firstDate: DateTime.parse(formattedStartDate),
//        lastDate: DateTime.parse(formattedStartDate).add(const Duration(days: 365)),
//      );
//      if (picked != null && picked != DateTime.now()) {
//        setState(() {
//          endDate = DateFormat('dd-MM-yyyy').format(picked);
//        });
//      }
//    }
//    return endDate;
//  }
//
//  Future<String> deleteImage(String imagePath) async {
//    // Ottieni il riferimento all'immagine
//    final Reference ref = FirebaseStorage.instance.ref().child(imagePath);
//    // Elimina l'immagine
//    await ref.delete();
//    // Imposta imageUploaded a false e imagePath a stringa vuota
//    setState(() {
//      imageUploaded = false;
//      imagePath = '';
//    });
//    return imagePath;
//  }
//
//  Future<String> uploadImage() async {
//    final ImagePicker _picker = ImagePicker();
//    // Seleziona un'immagine dalla galleria
//    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//
//    if (image == null) {
//      throw Exception('No image selected');
//    }
//
//    // Crea un riferimento a Firebase Storage
//    final Reference ref = FirebaseStorage.instance
//        .ref()
//        .child('users/${DateTime.now().toIso8601String()}');
//        //.child('${section}_image/${DateTime.now().toIso8601String()}');
//
//    // Carica l'immagine su Firebase Storage
//    final UploadTask uploadTask = ref.putData(await image.readAsBytes());
//
//    // Attendi il completamento del caricamento
//    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
//
//    // Ottieni l'URL dell'immagine caricata
//    final String imageUrl = await snapshot.ref.getDownloadURL();
//
//    print(imageUrl);
//
//    setState(() {
//      imageUploaded = true;
//    });
//
//    return imageUrl;
//  }
//
//  Future<void> createEvent(String event, String imagePath, String club_class, String startDate, String endDate, String description) async {
//    try {
//      if (event == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a title')));
//        return;
//      }
//      if (club_class == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a class')));
//        return;
//      }
//      if ((_selectedLevel == 'weekend' || _selectedLevel == 'extra') && startDate == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a date')));
//        return;
//      }
//      if ((_selectedLevel == 'trip') && (startDate == "" || endDate == "")) {
//        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//            content: Text('Please select the start and the end date')));
//        return;
//      }
//      if (description == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a description')));
//        return;
//      }
//      if (imagePath=='') {
//        imagePath='images/$_selectedLevel/default.jpg';
//      }
//
//      FirebaseFirestore firestore = FirebaseFirestore.instance;
//      await firestore.collection('${section.toLowerCase()}_${_selectedLevel}').add({
//        'title': event,
//        'selectedOption': _selectedLevel,
//        'imagePath': imagePath,
//        'selectedClass': club_class,
//        'description': description,
//        'startDate': startDate,
//        'endDate': endDate,
//      });
//      print('Evento creato con successo!');
//      Navigator.pop(context);
//    } catch (e) {
//      print('Errore durante la creazione dell\'evento: $e');
//    }
//  }
//
//  Future<void> _showAddEvent(String level) async {
//    String event = '';
//    String imagePath = '';
//    String club_class = '';
//    //String soccer_class = '';
//    String startDate = '';
//    String endDate = '';
//    String description = '';
//    return showDialog<void>(
//      context: context,
//      builder: (BuildContext context) {
//        return StatefulBuilder(
//          builder: (context, setState) {
//            return AlertDialog(
//              title: Text('$level'),
//              content: Column(
//                mainAxisSize: MainAxisSize.min,
//                children: [
//                  TextFormField(
//                    decoration: const InputDecoration(labelText: 'Titolo'),
//                    onChanged: (value) {
//                      setState(() {
//                        event = value;
//                      });
//                    },
//                  ),
//                  SizedBox(height: 16.0),
//                  DropdownButtonFormField<String>(
//                    value: club_class,
//                    onChanged: (value) {
//                      setState(() {
//                        club_class = value!;
//                      });
//                    },
//                    items: [
//                      '',
//                      '1° media',
//                      '2° media',
//                      '3° media'
//                    ].map((String option) {
//                      return DropdownMenuItem<String>(
//                        value: option,
//                        child: Text(option),
//                      );
//                    }).toList(),
//                    hint: Text('Seleziona una classe'),
//                  ),
//                  SizedBox(height: 16.0),
//                  ElevatedButton(
//                    onPressed: imageUploaded
//                        ? null
//                        : () async {
//                            String imageUrl = await uploadImage();
//                            setState(() {
//                              imagePath = imageUrl;
//                            });
//                          },
//                    child: Text(
//                        imageUploaded ? 'Immagine caricata' : 'Carica Immagine'),
//                  ),
//                  SizedBox(height: 16.0),
//                  if (imageUploaded) ...[
//                ElevatedButton(
//                  onPressed: () async {
//                    // Mostra un dialogo di conferma prima di eliminare l'immagine
//                    bool? confirm = await showDialog<bool>(
//                      context: context,
//                      builder: (BuildContext context) {
//                        return AlertDialog(
//                          title: Text('Conferma'),
//                          content: Text(
//                              'Sei sicuro di voler eliminare l\'immagine?'),
//                          actions: <Widget>[
//                            TextButton(
//                              child: Text('Annulla'),
//                              onPressed: () {
//                                setState(() {
//                                  Navigator.of(context).pop(false);
//                                });
//                              },
//                            ),
//                            TextButton(
//                              child: Text('Elimina'),
//                              onPressed: () {
//                                setState(() {
//                                  imageUploaded = false;
//                                  Navigator.of(context).pop(true);
//                                });
//                              },
//                            ),
//                          ],
//                        );
//                      },
//                    );
//                    if (confirm == true) {
//                      await deleteImage(imagePath);
//                    }
//                  },
//                  child: Text('Elimina Immagine'),
//                ),
//              ],
//              SizedBox(height: 16.0),
//              ...(_selectedLevel == 'weekend' || _selectedLevel == 'extra')
//              ? [
//                  ElevatedButton(
//                    onPressed: () async {
//                      startDate = await _startDate(context, startDate);
//                    },
//                    child: Text('Date'),
//                  ),
//                ]
//              : (_selectedLevel == 'trip' || _selectedLevel == 'tournament')
//              ? [
//                  ElevatedButton(
//                    onPressed: () async {
//                      startDate = await _startDate(context, startDate);
//                    },
//                    child: Text('Start date'),
//                  ),
//                  SizedBox(height: 16.0),
//                  ElevatedButton(
//                    onPressed: () async {
//                      endDate = await _endDate(context, startDate, endDate);
//                    },
//                    child: Text('End date'),
//                  ),
//                ]
//              : [],
//              SizedBox(height: 16.0),
//              TextFormField(
//                onChanged: (value) {
//                  description = value;
//                },
//                decoration: InputDecoration(labelText: 'Descrizione'),
//                maxLines: null,
//              ),
//              SizedBox(height: 16.0),
//              Row(
//                children: [
//                  ElevatedButton(
//                    onPressed: () async {
//                      Navigator.of(context).pop();
//                    },
//                    child: Text('Annulla'),
//                  ),
//                  ElevatedButton(
//                    onPressed: () async {
//                      await createEvent(event, imagePath, club_class, startDate, endDate, description);
//                    },
//                    child: Text('Crea'),
//                  ),
//                ],
//              )
//            ],
//          ),
//        );},
//        );
//      },
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    var size = MediaQuery.of(context).size;
//    var height = size.height;
//    var width = size.width;
//    return Scaffold(
//      appBar: AppBar(
//        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
//        backgroundColor: const Color.fromARGB(255, 130, 16, 8),
//        centerTitle: true,
//        iconTheme: const IconThemeData(color: Colors.white),
//      ),
//      body: Center(
//        child: Box(
//          level: _selectedLevel,
//          clubClass: widget.document['club_class'],
//          section: section.toLowerCase(),
//        )
//      ),
//      drawer: Drawer(
//        width: width > 700
//            ? width / 3
//            : width > 400
//                ? width / 2
//                : width / 1.5,
//        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//        child: ListView(
//          children: [
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Image(
//                image: const AssetImage('images/logo.png'),
//                width: width > 700 ? width / 4 : width / 8,
//                height: height / 4,
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: [
//                  Text('${widget.document['name']} ',
//                      style: TextStyle(fontSize: width > 300 ? 18 : 14)),
//                  Text('${widget.document['surname']}',
//                    style: TextStyle(fontSize: width > 300 ? 18 : 14))
//                ],
//              ),
//            ),
//            Padding(
//              padding:
//                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
//              child: 
//                Text('${widget.document['club_class']}',
//                    textAlign: TextAlign.center,
//                    style: TextStyle(
//                        fontSize: width > 500
//                            ? 14
//                            : width > 300
//                                ? 10
//                                : 8))
//            ),
//            Padding(
//              padding:
//                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
//              child: 
//                Text('${widget.document['email']}',
//                    textAlign: TextAlign.center,
//                    style: TextStyle(
//                        fontSize: width > 500
//                            ? 14
//                            : width > 300
//                                ? 10
//                                : 8))
//            ),
//            DropdownButton(
//              value: section,
//              onChanged: (value) {
//                if (widget.document['soccer_class'] != '') {
//                  setState(() {
//                    section = value.toString();
//                    if (section == 'FOOTBALL') {
//                      _saveLastPage('FootballPage');
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (context) => FootballPage(title: 'Tiber Club', document: widget.document,)));
//                                  }
//                  });
//                } else {
//                  Navigator.pop(context);
//                  ScaffoldMessenger.of(context).showSnackBar(
//                    SnackBar(
//                        content: Text('Non fai ancora parte di una squadra')),
//                  );
//                }
//              },
//              alignment: AlignmentDirectional.center,
//              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
//              underline: Container(
//                height: 0.5,
//                color: Colors.black,
//              ),
//              items: const [
//                DropdownMenuItem(
//                  value: 'CLUB',
//                  child: Text('CLUB'),
//                ),
//                DropdownMenuItem(
//                  value: 'FOOTBALL',
//                  child: Text('FOOTBALL'),
//                ),
//              ],
//            ),
//            ListTile(
//              leading: const Icon(
//                Icons.settings,
//              ),
//              title: const Text('Settings'),
//              subtitle: Text('Account management',
//                  style: TextStyle(
//                      fontSize: width > 700
//                          ? 12
//                          : width > 500
//                              ? 14
//                              : width > 400
//                                  ? 11
//                                  : width > 330
//                                      ? 12
//                                      : 10)),
//              onTap: () {
//                Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (context) => SettingsPage(id: widget.document['id'],)));
//              },
//            ),
//            widget.document['status'] == 'Admin'
//            ? ListTile(
//                leading: const Icon(
//                  Icons.code,
//                ),
//                title: const Text('Code generation'),
//                subtitle: Text('Accept new users',
//                    style: TextStyle(
//                        fontSize: width > 700
//                            ? 12
//                            : width > 500
//                                ? 14
//                                : width > 400
//                                    ? 11
//                                    : width > 330
//                                        ? 12
//                                        : 10)),
//                onTap: () {
//                  Navigator.pushNamed(context, '/acceptance');
//                },
//              )
//            : Container(),
//            widget.document['status'] == 'Admin'
//            ? ListTile(
//                leading: const Icon(
//                  Icons.mode,
//                ),
//                title: const Text('Page modifier'),
//                subtitle: Text('Create a new program!',
//                    style: TextStyle(
//                        fontSize: width > 700
//                            ? 12
//                            : width > 500
//                                ? 14
//                                : width > 400
//                                    ? 11
//                                    : width > 330
//                                        ? 12
//                                        : 10)),
//                onTap: () {
//                  Navigator.pushNamed(context, '/club_modifier');
//                },
//              )
//            : Container(),
//            ListTile(
//              leading: const Icon(
//                Icons.logout,
//              ),
//              title: const Text('Logout'),
//              subtitle: Text('We will miss you...',
//                  style: TextStyle(
//                      fontSize: width > 700
//                          ? 12
//                          : width > 500
//                              ? 14
//                              : width > 400
//                                  ? 11
//                                  : width > 330
//                                      ? 12
//                                      : 10)),
//              onTap: () {
//                showDialog(
//                  context: context,
//                  builder: (BuildContext context) {
//                    return AlertDialog(
//                      title: const Text('Logout'),
//                      content: const Text('Are you sure you want to logout?'),
//                      actions: <Widget>[
//                        TextButton(
//                          child: const Text('Cancel'),
//                          onPressed: () {
//                            Navigator.of(context).pop();
//                          },
//                        ),
//                        TextButton(
//                          child: const Text('Yes'),
//                          onPressed: () async {
//                            await _logout();
//                          },
//                        ),
//                      ],
//                    );
//                  },
//                );
//              },
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: widget.document['status'] == 'Admin'
//      ? FloatingActionButton(
//          onPressed: () {
//            _showAddEvent(_selectedLevel);
//          },
//          child: Icon(Icons.add),
//        )
//      : null,
//      bottomNavigationBar: BottomAppBar(
//        color: Color.fromARGB(255, 130, 16, 8),
//        child: Row(
//          mainAxisSize: MainAxisSize.max,
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          children: <Widget>[
//            InkWell(
//              onTap: () {
//                setState(() {
//                  _selectedLevel = 'weekend';
//                });
//              },
//              child: const Column(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                  Icon(Icons.calendar_month_outlined, color: Colors.white),
//                  Text('Weekend', style: TextStyle(color: Colors.white)),
//                ],
//              ),
//            ),
//            InkWell(
//               onTap: () {
//              setState(() {
//                _selectedLevel = 'trip';
//              });
//              },
//              child: const Column(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                  Icon(Icons.calendar_month_outlined, color: Colors.white),
//                  Text('Trip', style: TextStyle(color: Colors.white)),
//                ],
//              ),
//            ),
//            InkWell(
//              onTap: () {
//                setState(() {
//                _selectedLevel = 'extra';
//              });
//            },
//            child: const Column(
//              mainAxisSize: MainAxisSize.min,
//              children: <Widget>[
//                Icon(Icons.calendar_month_outlined, color: Colors.white),
//                Text('Extra', style: TextStyle(color: Colors.white)),
//              ],
//            ),
//          ),
//          ],
//        ),
//      ),
//    );
//  }
//}
//
//class Box extends StatefulWidget {
//
//  const Box({
//    required this.level,
//    required this.clubClass,
//    required this.section,
//  });
//
//  final String level;
//  final String clubClass;
//  final String section;
//
//  @override
//  State<Box> createState() => _BoxState();
//}
//
//class _BoxState extends State<Box> {
//  List<Map<String, dynamic>> documents = [];
//  String? title;
//  String? startDate;
//  String? imagePath;
//  String? description;
//  bool imageUploaded = true;
//
//  Future<void> _fetchData() async {
//    CollectionReference users = FirebaseFirestore.instance.collection('club_${widget.level}');
//    QuerySnapshot querySnapshot = await users.where('selectedClass', isEqualTo: widget.clubClass).get();
//    print(querySnapshot.docs);
//    if (querySnapshot.docs.isNotEmpty) {
//      documents = querySnapshot.docs.map((doc) => {
//        'id': doc.id, // Here is how you get the document ID
//        ...doc.data() as Map<String, dynamic>
//      }).toList();   
//    }
//    return Future.value();
//  }
//
//    Future<String> _startDate(BuildContext context, String startDate) async {
//    final DateTime? picked = await showDatePicker(
//      context: context,
//      initialDate: DateTime.now(),
//      firstDate: DateTime.now(),
//      lastDate: DateTime.now().add(const Duration(days: 365)),
//    );
//    if (picked != null) { // && picked != DateTime.now()
//      setState(() {
//        startDate = DateFormat('dd-MM-yyyy').format(picked);
//      });
//    }
//    return startDate;
//  }
//
//  Future<String> _endDate(BuildContext context, String startDate, String endDate) async {
//    if (startDate == "") {
//      ScaffoldMessenger.of(context).showSnackBar(
//          const SnackBar(content: Text('Please select the startDate first')));
//      return '';
//    } else {
//      DateFormat inputFormat = DateFormat('dd-MM-yyyy');
//      DateTime date = inputFormat.parse(startDate);
//      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
//      String formattedStartDate = outputFormat.format(date);
//      final DateTime? picked = await showDatePicker(
//        context: context,
//        initialDate: DateTime.parse(formattedStartDate),
//        firstDate: DateTime.parse(formattedStartDate),
//        lastDate:
//            DateTime.parse(formattedStartDate).add(const Duration(days: 365)),
//      );
//      if (picked != null && picked != DateTime.now()) {
//        setState(() {
//          endDate = DateFormat('dd-MM-yyyy').format(picked);
//        });
//      }
//    }
//    return endDate;
//  }
//
//  Future<Map> loadBoxData(String id) async {
//    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
//        .collection('${widget.section}_${widget.level}')
//        .doc(id)
//        .get();
//
//    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
//    Map<String, dynamic> editData = {};
//    setState(() {
//      editData = { 
//        'id': documentSnapshot.id,
//        'title': data['title'],
//        'imagePath': data['imagePath'],
//        'selectedLevel': widget.level,
//        'selectedClass': data['selectedClass'],
//        'description': data['description'],
//        'startDate': data['startDate'] ?? '',
//        'endDate': data['endDate'] ?? '',
//      };
//    });
//    return editData;
//  }
//
//  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//  Future<void> deleteDocument(String collection, String docId) async {
//    await _firestore.collection(collection).doc(docId).delete();
//  }
//
//  Future<String> deleteImage(String imagePath) async {
//    // Ottieni il riferimento all'immagine
//    final Reference ref = FirebaseStorage.instance.ref().child(imagePath); //il problema è che l'immagine che eliminiamo (images/...) non esiste nel firebase, va prima caricata correttamente
//    // Elimina l'immagine
//    await ref.delete();
//    // Imposta imageUploaded a false e imagePath a stringa vuota
//    setState(() {
//      imageUploaded = false;
//      imagePath = '';
//    });
//    return imagePath;
//  }
//
//  Future<void> _showEditDialog(String level, Map<dynamic, dynamic> data) async {
//    print(data);
//    final TextEditingController titleController = TextEditingController();
//    final TextEditingController descriptionController = TextEditingController();
//    String newTitle = data['title'];
//    //String selectedOption = data['selectedLevel'];
//    String imagePath = data['imagePath'];
//    String selectedClass = data['selectedClass'];
//    String description = data['description'];
//    String startDate = data['startDate'] ?? '';
//    String endDate = data['endDate'] ?? '';
//    print('1');
//
//    titleController.text = data['title'];
//    descriptionController.text = data['description'];
//    return showDialog<void>(
//      context: context,
//      builder: (BuildContext context) {
//        return StatefulBuilder(
//          builder: (context, setState) {
//            return AlertDialog(
//              title: Text('${level}'),
//              content: Column(
//            mainAxisSize: MainAxisSize.min,
//            children: [
//              TextFormField(
//                controller: titleController,
//                onChanged: (value) {
//                  newTitle = value;
//                },
//                decoration: InputDecoration(labelText: 'Titolo'),
//              ),
//              SizedBox(height: 16.0),
//              DropdownButtonFormField<String>(
//                value: data['selectedClass'],
//                onChanged: (value) {
//                  setState(() {
//                    selectedClass = value!;
//                  });
//                },
//                items: [
//                  '',
//                  '1° media',
//                  '2° media',
//                  '3° media'
//                ].map((String option) {
//                  return DropdownMenuItem<String>(
//                    value: option,
//                    child: Text(option),
//                  );
//                }).toList(),
//                hint: Text('Seleziona un\'opzione'),
//              ),
//              SizedBox(height: 16.0),
//                  ElevatedButton(
//                    onPressed: imageUploaded
//                        ? null
//                        : () async {
//                            String imageUrl = await uploadImage();
//                            setState(() {
//                              imagePath = imageUrl;
//                            });
//                          },
//                    child: Text(
//                        imageUploaded ? 'Immagine caricata' : 'Carica Immagine'),
//                  ),
//                  SizedBox(height: 16.0),
//               //  if (imageUploaded) ...[
//               //ElevatedButton(
//               //  onPressed: () async {
//               //    // Mostra un dialogo di conferma prima di eliminare l'immagine
//               //    bool? confirm = await showDialog<bool>(
//               //      context: context,
//               //      builder: (BuildContext context) {
//               //        return AlertDialog(
//               //          title: Text('Conferma'),
//               //          content: Text(
//               //              'Sei sicuro di voler eliminare l\'immagine?'),
//               //          actions: <Widget>[
//               //            TextButton(
//               //              child: Text('Annulla'),
//               //              onPressed: () {
//               //                setState(() {
//               //                  Navigator.of(context).pop(false);
//               //                });
//               //              },
//               //            ),
//               //            TextButton(
//               //              child: Text('Elimina'),
//               //              onPressed: () {
//               //                setState(() {
//               //                  imageUploaded = false;
//               //                });
//               //                Navigator.of(context).pop(true);
//               //              },
//               //            ),
//               //          ],
//               //        );
//               //      },
//               //    );
//               //    if (confirm == true) {
//               //      await deleteImage(imagePath);
//               //      //print(level);
//               //    }
//               //  },
//               //  child: Text('Elimina Immagine'),
//               //),
//              SizedBox(height: 16.0),
//              ...(level == 'weekend' || level == 'extra')
//                  ? [
//                      ElevatedButton(
//                        onPressed: () async {
//                          String newDate = await _startDate(context, data['startDate']);
//                          setState(() {
//                            startDate = newDate;
//                          });
//                        },
//                        child: Text('$startDate'),
//                      ),
//                    ]
//                  : (level == 'trip' || level == 'tournament')
//                      ? [
//                          ElevatedButton(
//                            onPressed: () async {
//                              String newDate = await _startDate(context, data['startDate']);
//                              setState(() {
//                                startDate = newDate;
//                              });
//                            },
//                            child: Text('$startDate'),
//                          ),
//                          ElevatedButton(
//                            onPressed: () async {
//                              String newDate = await _endDate(context, data['startDate'], data['endDate']);
//                              setState(() {
//                                endDate = newDate;
//                              });
//                            },
//                            child: Text('$endDate'),
//                          ),
//                        ]
//                      : [],
//              SizedBox(height: 16.0),
//              TextFormField(
//                controller: descriptionController,
//                onChanged: (value) {
//                  description = value;
//                },
//                decoration: InputDecoration(labelText: 'Testo'),
//                maxLines: null,
//              ),
//              SizedBox(height: 16.0),
//              ElevatedButton(
//                onPressed: () async {
//                  await updateClubDetails(data['id'], newTitle, imagePath, selectedClass, startDate, endDate, description);
//                },
//                child: Text('Crea'),
//              ),
//            ]//]
//          ),
//            );
//          },
//        );
//      }
//    );
//  }
//
//  Future<void> updateClubDetails(String id, String newTitle, String imagePath, String selectedClass, String startDate, String endDate, String description) async {
//    try {
//      if (title == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a title')));
//        return;
//      }
//      if (selectedClass == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a class')));
//        return;
//      }
//
//      await FirebaseFirestore.instance
//          .collection('${widget.section}_${widget.level}')
//          .doc(id)
//          .delete();
//      await FirebaseFirestore.instance.collection('${widget.section}_${widget.level}').add({
//        'title': newTitle,
//        'imagePath': imagePath,
//        'selectedClass': selectedClass,
//        'selectedOption': widget.level,
//        'description': description,
//        'startDate': startDate,
//        'endDate': endDate,
//      });
//      Navigator.pop(context);
//    } catch (e) {
//      print('Error updating user details: $e');
//    }
//  }
//
//  Future<String> uploadImage() async {
//    final ImagePicker _picker = ImagePicker();
//    // Seleziona un'immagine dalla galleria
//    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//
//    if (image == null) {
//      throw Exception('No image selected');
//    }
//
//    // Crea un riferimento a Firebase Storage
//    final Reference ref = FirebaseStorage.instance
//        .ref()
//        .child('users/${DateTime.now().toIso8601String()}');
//        //.child('${section}_image/${DateTime.now().toIso8601String()}');
//
//    // Carica l'immagine su Firebase Storage
//    final UploadTask uploadTask = ref.putData(await image.readAsBytes());
//
//    // Attendi il completamento del caricamento
//    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
//
//    // Ottieni l'URL dell'immagine caricata
//    final String imageUrl = await snapshot.ref.getDownloadURL();
//
//    print(imageUrl);
//
//    setState(() {
//      imageUploaded = true;
//    });
//
//    return imageUrl;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return FutureBuilder(
//      future: _fetchData(),
//      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
//        if (snapshot.connectionState == ConnectionState.waiting) {
//          return CircularProgressIndicator();
//        } else {
//          documents.sort((a, b) => (a['startDate'] as String).compareTo(b['startDate'] as String));
//          return ListView.builder(
//            itemCount: documents.length,
//            itemBuilder: (context, index) {
//              var document = documents[index];
//              var id = document['id'];
//              var title = document['title'];
//              var level = document['selectedOption'];
//              var startDate = document['startDate'];
//              //var imagePath = document['imagePath'];
//              var description = document['description'];
//              return Container(
//                margin: EdgeInsets.all(10.0),
//                padding: EdgeInsets.all(15.0),
//                decoration: BoxDecoration(
//                  border: Border.all(),
//                  borderRadius: BorderRadius.circular(10.0),
//                ),
//                child: Row(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: [
//                    Expanded(
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: [
//                          Text('Title: $title', style: TextStyle(fontWeight: FontWeight.bold)),
//                          Text('StartDate: $startDate'),
//                          Text('Club Class: ${widget.clubClass}'),
//                          if(document['endDate']!='') Text('EndDate: ${document['endDate']}'),
//                          Image(
//                            image: NetworkImage('images/$level/default.jpg'), //dovrebbe essere '${document['imagePath']}', ma non carica bene...
//                            height: 100,
//                            width:100,
//                          ),
//                          Text('Description: $description'),
//                        ],
//                      ),
//                    ),
//                    Column(
//                      children: [
//                        IconButton(
//                          icon: const Icon(Icons.edit),
//                          onPressed: () async {
//                            Map<dynamic, dynamic> data = {};
//                            data = await loadBoxData(id);
//                            _showEditDialog(widget.level, data);
//                          },
//                        ),
//                        IconButton(
//                          icon: Icon(Icons.delete),
//                          onPressed: () async {
//                            bool? shouldDelete = await showDialog(
//                              context: context,
//                              builder: (BuildContext context) {
//                                return AlertDialog(
//                                  title: Text('Confirm'),
//                                  content: Text(
//                                      'Are you sure you want to delete this item?'),
//                                  actions: <Widget>[
//                                    TextButton(
//                                      child: Text('Cancel'),
//                                      onPressed: () {
//                                        Navigator.of(context).pop(false);
//                                      },
//                                    ),
//                                    TextButton(
//                                      child: Text('Delete'),
//                                      onPressed: () {
//                                        Navigator.of(context).pop(true);
//                                      },
//                                    ),
//                                  ],
//                                );
//                              },
//                            );
//                            if (shouldDelete == true) {
//                              setState(() {
//                                deleteDocument('${widget.section}_${widget.level}', id);
//                              });
//                            }
//                          },
//                        ),
//                      ],
//                    ),
//                  ],
//                ),
//              );
//            },
//          );
//        }
//      },
//    );
//  }
//}