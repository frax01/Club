import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchEventPage extends StatefulWidget {
  const MatchEventPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MatchEventPageState createState() => _MatchEventPageState();
}

class _MatchEventPageState extends State<MatchEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedTeam='';
  String matchType='';
  String opponentController = '';
  String locationController = '';
  TimeOfDay selectedTime = TimeOfDay.now();

  void updateMatchDetails() async {
    try {
      if (selectedTeam == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a team')));
        return;
      }
      if (opponentController == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an apponent')));
        return;
      }
      if (matchType == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a match')));
        return;
      }
      if (locationController == "") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a location')));
        return;
      }

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore.collection('football_match').where('team', isEqualTo: selectedTeam).get();
      String documentId = querySnapshot.docs.first.id;
          //.doc(_selected
      // Aggiorna i dati nel documento
      await FirebaseFirestore.instance
      .collection('football_match')
      .doc(documentId).update({
        'team': selectedTeam,
        'opponent': opponentController,
        'place': locationController,
        'time': selectedTime.format(context),
      });
      Navigator.pop(context);
    } catch (e) {
      print('Error updating user details: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: selectedTeam,
                onChanged: (value) {
                  setState(() {
                    selectedTeam = value!;
                    // Aggiorna il valore del controller in base alla selezione del team
                    //_locationController.text = _selectedTeam == 'Casa' ? 'CASA' : '';
                  });
                },
                items: ['', 'beginner', 'intermediate', 'advanced']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                decoration: InputDecoration(labelText: 'Select Team'),
              ),
              TextFormField(
                onChanged: (value) {
                  opponentController = value;
                },
                decoration: InputDecoration(labelText: 'Enter String'),
              ),
              DropdownButtonFormField<String>(
                value: matchType,
                onChanged: (value) {
                  setState(() {
                    matchType = value!;
                  });
                },
                items: ['', 'Casa', 'Fuori casa']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                decoration: InputDecoration(labelText: 'Match Type'),
              ),
              TextFormField(
                onChanged: (value) {
                  locationController = value;
                },
                decoration: InputDecoration(labelText: 'Enter location'),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Select Time: '),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedTimeNew = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );

                      if (selectedTimeNew != null && selectedTimeNew != selectedTime) {
                        setState(() {
                          selectedTime = selectedTimeNew;
                        });
                      }
                    },
                    child: Text(selectedTime.format(context)),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  updateMatchDetails();
                  },
                child: Text('Update Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
