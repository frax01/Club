import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UpdateEventPage extends StatefulWidget {
  const UpdateEventPage(
      {Key? key, required this.documentId, required this.Option, required this.section})
      : super(key: key);

  final String section;
  final String documentId;
  final String Option;
  //final String title = 'Update Event';

  @override
  _UpdateEventPageState createState() => _UpdateEventPageState();
}

class _UpdateEventPageState extends State<UpdateEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String title = '';
  String selectedOption = '';
  String imagePath = '';
  String selectedClass = '';
  String description = '';
  String startDate = '';
  String endDate = '';

  Future<void> _startDate(BuildContext context) async {
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
  }

  Future<void> _endDate(BuildContext context) async {
    if (startDate == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select the startDate first')));
      return;
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
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('${widget.section}_${widget.Option}')
        .doc(widget.documentId)
        .get();

    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    setState(() {
      titleController.text = data['title'];
      title = titleController.text;
      selectedOption = widget.Option;
      selectedClass = data['selectedClass'];
      descriptionController.text = data['description'];
      startDate = data['startDate'] ?? '';
      endDate = data['endDate'] ?? '';
    });
  }

  Future<void> updateClubDetails() async {
    try {
      if (title == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a title')));
        return;
      }
      //if (selectedOption == "") {
      //  ScaffoldMessenger.of(context).showSnackBar(
      //      const SnackBar(content: Text('Please select an option')));
      //  return;
      //}
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
          .collection('${widget.section}_${widget.Option}')
          .doc(widget.documentId)
          .delete();

      await FirebaseFirestore.instance.collection('${widget.section}_$selectedOption').add({
        'title': title,
        'selectedOption': selectedOption,
        'selectedClass': selectedClass,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
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
              TextField(
                controller: TextEditingController(text: selectedOption),
                decoration: InputDecoration(hintText: 'Seleziona un\'opzione'),
                enabled: false, // This makes the TextField not editable
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
              ...(widget.Option == 'weekend' || widget.Option == 'extra')
                  ? [
                      ElevatedButton(
                        onPressed: () => _startDate(context),
                        child: Text('$startDate'),
                      ),
                    ]
                  : (widget.Option == 'trip' || widget.Option == 'summer' || widget.Option == 'tournament')
                      ? [
                          ElevatedButton(
                            onPressed: () => _startDate(context),
                            child: Text('$startDate'),
                          ),
                          ElevatedButton(
                            onPressed: () => _endDate(context),
                            child: Text('$endDate'),
                          ),
                        ]
                      : [],
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

//import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:intl/intl.dart';
//
//class MatchEventPage extends StatefulWidget {
//  const MatchEventPage({Key? key, required this.title}) : super(key: key);
//
//  final String title;
//
//  @override
//  _MatchEventPageState createState() => _MatchEventPageState();
//}
//
//class _MatchEventPageState extends State<MatchEventPage> {
//  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//  String selectedTeam = '';
//  String matchType = '';
//  String selectedMatch = '';
//  String locationController = '';
//  TimeOfDay selectedTime = TimeOfDay.now();
//  String date = '';
//
//  List<Map<String, String>> beginnerMatches = [];
//  List<Map<String, String>> intermediateMatches = [];
//  List<Map<String, String>> advancedMatches = [];
//
//  //  @override
//  //void initState() {
//  //  super.initState();
//  //  loadMatches();
//  //}
//  void loadMatches() async {
//    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//        .collection('football_calendar')
//        .get();
//
//    for (var doc in querySnapshot.docs) {
//      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//      List<Map<String, String>> matches = List<Map<String, String>>.from(
//        (data['matches'] as List).map(
//          (item) => Map<String, String>.from(item as Map)
//        )
//      );
//
//      switch (data['team']) {
//        case 'beginner':
//          beginnerMatches.addAll(matches);
//          break;
//        case 'intermediate':
//          intermediateMatches.addAll(matches);
//          break;
//        case 'advanced':
//          advancedMatches.addAll(matches);
//          break;
//      }
//    }
//  }
//
//  List<Map<String, String>> getSelectedTeamMatches() {
//    switch (selectedTeam) {
//      case 'beginner':
//        return beginnerMatches;
//      case 'intermediate':
//        return intermediateMatches;
//      case 'advanced':
//        return advancedMatches;
//      default:
//        return [];
//    }
//  }
//
//  Future<void> _date(BuildContext context) async {
//    final DateTime? picked = await showDatePicker(
//      context: context,
//      initialDate: DateTime.now(),
//      firstDate: DateTime.now(),
//      lastDate: DateTime.now().add(const Duration(days: 365)),
//    );
//    if (picked != null && picked != DateTime.now()) {
//      setState(() {
//        date = DateFormat('dd-MM-yyyy').format(picked);
//      });
//    }
//  }
//
//  void updateMatchDetails() async {
//    try {
//      if (selectedTeam == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a team')));
//        return;
//      }
//      if (selectedMatch == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select an apponent')));
//        return;
//      }
//      if (matchType == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a match')));
//        return;
//      }
//      if (locationController == "") {
//        ScaffoldMessenger.of(context).showSnackBar(
//            const SnackBar(content: Text('Please select a location')));
//        return;
//      }
//
//      FirebaseFirestore firestore = FirebaseFirestore.instance;
//      QuerySnapshot querySnapshot = await firestore
//          .collection('football_match')
//          .where('team', isEqualTo: selectedTeam)
//          .get();
//      String documentId = querySnapshot.docs.first.id;
//      //.doc(_selected
//      // Aggiorna i dati nel documento
//      await FirebaseFirestore.instance
//          .collection('football_match')
//          .doc(documentId)
//          .update({
//        'team': selectedTeam,
//        'opponent': selectedMatch,
//        'place': locationController,
//        'date': date,
//        'time': selectedTime.format(context),
//      });
//      Navigator.pop(context);
//    } catch (e) {
//      print('Error updating user details: $e');
//    }
//  }
//
//  Future<List<Map<String, String>>> getMatches() async {
//    List<Map<String, String>> calendar = [];
//    if (selectedTeam != '') {
//      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//          .collection('football_calendar')
//          .where('team', isEqualTo: selectedTeam)
//          .get();
//
//      for (var doc in querySnapshot.docs) {
//        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//        List<Map<String, String>> matches = List<Map<String, String>>.from(
//          (data['matches'] as List).map(
//            (item) => Map<String, String>.from(item as Map)
//          )
//        );
//        print("c${matches}");
//        calendar.addAll(matches);
//      }
//    }
//    return calendar;
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Match Event'),
//      ),
//      body: Padding(
//        padding: const EdgeInsets.all(16.0),
//        child: Form(
//          key: _formKey,
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.stretch,
//            children: [
//              DropdownButtonFormField<String>(
//                value: selectedTeam,
//                onChanged: (value) {
//                  setState(() {
//                    selectedTeam = value!;
//                    print(selectedTeam);
//                    // Aggiorna il valore del controller in base alla selezione del team
//                    //_locationController.text = _selectedTeam == 'Casa' ? 'CASA' : '';
//                  });
//                },
//                items: ['', 'beginner', 'intermediate', 'advanced']
//                    .map<DropdownMenuItem<String>>(
//                      (String value) => DropdownMenuItem<String>(
//                        value: value,
//                        child: Text(value),
//                      ),
//                    )
//                    .toList(),
//                decoration: InputDecoration(labelText: 'Select Team'),
//              ),
//              //DropdownButtonFormField<String>(
//              //  value: selectedMatch,
//              //  onChanged: (value) {
//              //    setState(() {
//              //      selectedMatch = value!;
//              //    });
//              //  },
//              //  items: ['']
//              //    .map<DropdownMenuItem<String>>(
//              //      (String value) => DropdownMenuItem<String>(
//              //        value: value,
//              //        child: Text(''),
//              //      ),
//              //    )
//              //    .toList()
//              //    ..addAll(
//              //      getSelectedTeamMatches()
//              //          .map<DropdownMenuItem<String>>(
//              //            (match) => DropdownMenuItem<String>(
//              //              value: '${match.keys.first} vs ${match.values.first}',
//              //              child: Text('${match.keys.first} vs ${match.values.first}'),
//              //            ),
//              //          )
//              //          .toList(),
//              //    ),),
//              DropdownButtonFormField<String>(
//                value: matchType,
//                onChanged: (value) {
//                  setState(() {
//                    matchType = value!;
//                  });
//                },
//                items: ['', 'Casa', 'Fuori casa']
//                    .map<DropdownMenuItem<String>>(
//                      (String value) => DropdownMenuItem<String>(
//                        value: value,
//                        child: Text(value),
//                      ),
//                    )
//                    .toList(),
//                decoration: InputDecoration(labelText: 'Match Type'),
//              ),
//              TextFormField(
//                onChanged: (value) {
//                  locationController = value;
//                },
//                decoration: InputDecoration(labelText: 'Enter location'),
//              ),
//              SizedBox(height: 16.0),
//              ElevatedButton(
//                onPressed: () => _date(context),
//                child: Text('$date'),
//              ),
//              SizedBox(height: 16.0),
//              Row(
//                children: [
//                  Text('Select Time: '),
//                  ElevatedButton(
//                    onPressed: () async {
//                      final selectedTimeNew = await showTimePicker(
//                        context: context,
//                        initialTime: selectedTime,
//                      );
//
//                      if (selectedTimeNew != null &&
//                          selectedTimeNew != selectedTime) {
//                        setState(() {
//                          selectedTime = selectedTimeNew;
//                        });
//                      }
//                    },
//                    child: Text(selectedTime.format(context)),
//                  ),
//                ],
//              ),
//              SizedBox(height: 16.0),
//              ElevatedButton(
//                onPressed: () async {
//                  updateMatchDetails();
//                },
//                child: Text('Update Data'),
//              ),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//}
//