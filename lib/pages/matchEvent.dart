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
  String? _selectedTeam;
  String? _matchType;
  TextEditingController _opponentController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

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
                value: _selectedTeam,
                onChanged: (value) {
                  setState(() {
                    _selectedTeam = value;
                    // Aggiorna il valore del controller in base alla selezione del team
                    //_locationController.text = _selectedTeam == 'Casa' ? 'CASA' : '';
                  });
                },
                items: ['beginner', 'intermediate', 'advanced']
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
                controller: _opponentController,
                decoration: InputDecoration(labelText: 'Enter String'),
              ),
              DropdownButtonFormField<String>(
                value: _matchType,
                onChanged: (value) {
                  setState(() {
                    _matchType = value!;
                    if (_matchType == 'Fuori casa') {
                      _locationController.text = '';
                    }
                    if (_matchType == 'Casa') {
                      _locationController.text = 'CASA';
                    }
                  });
                },
                items: ['Casa', 'Fuori casa']
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
                controller: _locationController,
                enabled: _matchType == 'Fuori casa',
                readOnly: _matchType == 'Casa',
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: _matchType == 'Casa' ? 'CASA' : 'Inserisci indirizzo',
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Select Time: '),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );

                      if (selectedTime != null && selectedTime != _selectedTime) {
                        setState(() {
                          _selectedTime = selectedTime;
                        });
                      }
                    },
                    child: Text(_selectedTime.format(context)),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Ottieni un riferimento al documento nella collezione 'football_match'
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    QuerySnapshot querySnapshot = await firestore.collection('football_match').where('team', isEqualTo: _selectedTeam).get();
                    String documentId = querySnapshot.docs.first.id;
                        //.doc(_selectedTeam);

                    // Aggiorna i dati nel documento
                    await FirebaseFirestore.instance
                    .collection('football_match')
                    .doc(documentId).update({
                      'team': _selectedTeam,
                      'opponent': _opponentController.text,
                      'place': _locationController.text,
                      'time': _selectedTime.format(context),
                    });

                    // Mostra un messaggio di successo o effettua altre azioni post-aggiornamento
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Dati aggiornati con successo'),
                      ),
                    );
                  }
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
