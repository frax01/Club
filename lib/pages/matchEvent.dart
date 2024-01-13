import 'package:flutter/material.dart';

class MatchEventPage extends StatefulWidget {
  const MatchEventPage({super.key, required this.title});

  final String title;

  @override
  _MatchEventPageState createState() => _MatchEventPageState();
}

class _MatchEventPageState extends State<MatchEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedTeam;
  String _matchType = 'Casa';
  String _selectedLocation = '';

  TextEditingController _teamController = TextEditingController();
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
                  });
                },
                items: ['beginner', 'intermediate', 'advanced', 'expert']
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
                  hintText: _matchType == 'Casa' ? 'CASA' : 'Fuori casa',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Effettua l'aggiornamento o l'inserimento nel database
                    // Aggiorna la tabella football_match con i dati inseriti
                    // Usa _selectedTeam, il valore del text field, _matchType, _selectedLocation e _selectedTime
                    // Puoi usare FirebaseFirestore per interagire con Firestore
                  }
                },
                child: Text('Insert Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
