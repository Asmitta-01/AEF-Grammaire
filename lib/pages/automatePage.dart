import 'package:first_project/classes/automate.dart';
import 'package:flutter/material.dart';

// export 'package:first_project/automate_page.dart';

class AutomatePage extends StatefulWidget {
  const AutomatePage({super.key, required this.title});
  final String title;

  @override
  State<AutomatePage> createState() => _AutomatePageState();
}

class _AutomatePageState extends State<AutomatePage> {
  final Automate _automate = Automate();

  bool _alphabetOk = false,
      _etatsOk = false,
      _etatInitOk = false,
      _etatFinauxOk = false,
      _transitionsOk = false;

  final _textFieldAlphController = TextEditingController(),
      _textFieldEtatsController = TextEditingController(),
      _textFieldEtatInitController = TextEditingController(),
      _textFieldEtatFinauxController = TextEditingController();

  var _alphErrorMsg,
      _etatsErrorMsg,
      _etatInitErrorMsg,
      _etatFinauxErrorMsg,
      _transitionsErrorMsg;

  void _changeAlphabetState([String text = '']) {
    setState(() {
      text = text.isEmpty ? _textFieldAlphController.text : text;
      var alphabet = text.replaceAll(' ', '').split(';').toSet();
      alphabet.remove('');
      if (_automate.X != alphabet) {
        String str = '';
        for (var element in alphabet) {
          str += '$element; ';
          if (element.length > 1) {
            _alphabetOk = false;
            _automate.X = {};
            _alphErrorMsg =
                "Un symbole de l'alphabet ne peut avoir plus d'un caractere";
            break;
          }
          _alphabetOk = true;
          _alphErrorMsg = null;
        }

        if (_alphabetOk) {
          _textFieldAlphController.text = str;
          _automate.X = alphabet;
        }
      } else {
        _alphabetOk = true;
      }
    });
  }

  void _changeEtatsState([String text = '']) {
    setState(() {
      text = text.isEmpty ? _textFieldEtatsController.text : text;
      var etatsPossibles = text.replaceAll(' ', '').split(';').toSet();
      etatsPossibles.remove('');
      if (_automate.Q != etatsPossibles) {
        String str = '';
        for (var element in etatsPossibles) {
          str += '$element; ';
          if (element.length > 1) {
            _etatsOk = false;
            _automate.Q = {};
            _etatsErrorMsg =
                "Un etat ne peut avoir plus d'un caractere (Contrainte personnelle)";
            break;
          }
          _etatsOk = true;
          _etatsErrorMsg = null;
        }

        if (_etatsOk) {
          _textFieldEtatsController.text = str;
          _automate.Q = etatsPossibles;
        }
      } else {
        _etatsOk = true;
      }
    });
  }

  void _changeEtatInitialState([String text = '']) {
    setState(() {
      text = text.isEmpty ? _textFieldEtatInitController.text : text;
      if (_automate.q0 != text) {
        if (!_automate.Q.contains(text)) {
          _etatInitOk = false;
          _automate.q0 = '';
          _etatInitErrorMsg =
              "Cet etat n'appartient pas a l'ensemble des etats possibles";
        } else {
          _etatInitOk = true;
          _etatInitErrorMsg = null;
          _automate.q0 = text;
        }
      } else {
        _etatInitOk = true;
      }
    });
  }

  void _changeEtatFinauxState([String text = '']) {
    setState(() {
      text = text.isEmpty ? _textFieldEtatFinauxController.text : text;
      var etatsFinaux = text.replaceAll(' ', '').split(';').toSet();
      etatsFinaux.remove('');
      if (_automate.F != etatsFinaux) {
        String str = '';
        if (_automate.Q.containsAll(etatsFinaux)) {
          etatsFinaux.forEach((element) {
            str += '$element; ';
          });

          _etatFinauxOk = true;
          _automate.F = etatsFinaux;
          _etatFinauxErrorMsg = null;
          _textFieldEtatFinauxController.text = str;
        } else {
          _etatFinauxOk = false;
          _automate.F = {};
          _etatFinauxErrorMsg =
              "Tout etat final doit etre dans l'ensemble des etats finaux";
        }
      } else {
        _etatFinauxOk = true;
      }
    });
  }

  void _changeTransitionsState([String text = '']) {
    setState(() {
      _transitionsOk = !_transitionsOk;
    });
  }

  Widget get transitions {
    var columns = _alphabetOk && _etatInitOk && _etatsOk
        ? [
            const DataColumn(label: Text('Etat')),
            ..._automate.X.map((e) => DataColumn(label: Text(e))).toList()
          ]
        : const [DataColumn(label: Text('-'))];
    var rows = _alphabetOk && _etatInitOk && _etatsOk
        ? _automate.Q
            .map(
              (e) => DataRow(
                cells: [
                  DataCell(Text(e)),
                  ..._automate.X
                      .map(
                        (s) => DataCell(
                          TextField(
                            onChanged: (value) => {},
                          ),
                        ),
                      )
                      .toList()
                ],
              ),
            )
            .toList()
        : const [
            DataRow(cells: [DataCell(Text('-'))])
          ];

    return DataTable(columns: columns, rows: rows);
  }

  ButtonStyle flatBtnStyle(int elt) => TextButton.styleFrom(
        foregroundColor: (elt == 1 && _alphabetOk) ||
                (elt == 2 && _etatsOk) ||
                (elt == 3 && _etatInitOk) ||
                (elt == 4 && _etatFinauxOk) ||
                (elt == 5 && _transitionsOk) ||
                (elt == 0 && _automate.contientTousSesElements)
            ? Colors.green
            : Colors.black,
        minimumSize: const Size(88, 66),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    var alphabetContainer = Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(children: <Widget>[
        Row(
          children: [
            Expanded(
                child: Column(
              children: <Widget>[
                TextField(
                  onSubmitted: _changeAlphabetState,
                  controller: _textFieldAlphController,
                  decoration: InputDecoration(
                    labelText: "Entrez l'alphabet: ",
                    hintText: 'Exemple: a; b; c',
                    errorText: _alphErrorMsg,
                    helperText:
                        "Separer chaque symbole par un point-virgule(;)",
                    icon: const Icon(Icons.data_array),
                  ),
                )
              ],
            )),
            TextButton(
              onPressed: _changeAlphabetState,
              style: flatBtnStyle(1),
              child: _alphabetOk
                  ? const Icon(Icons.done_rounded)
                  : const Text('Ok'),
            ),
          ],
        )
      ]),
    );

    var etatsContainer = Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: const [
            BoxShadow(blurRadius: 10, color: Colors.transparent)
          ]),
      child: Column(children: <Widget>[
        Row(
          children: [
            Expanded(
                child: Column(
              children: <Widget>[
                TextField(
                  onSubmitted: _changeEtatsState,
                  controller: _textFieldEtatsController,
                  decoration: InputDecoration(
                      labelText: "Entrez tous les etats possibles: ",
                      hintText: 'Exemple: 0, 1, 2',
                      errorText: _etatsErrorMsg,
                      icon: const Icon(Icons.data_array)),
                )
              ],
            )),
            TextButton(
              onPressed: _changeEtatsState,
              style: flatBtnStyle(2),
              child:
                  _etatsOk ? const Icon(Icons.done_rounded) : const Text('Ok'),
            ),
          ],
        )
      ]),
    );

    var etatInitialContainer = Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(children: <Widget>[
        Row(
          children: [
            Expanded(
                child: Column(
              children: <Widget>[
                TextField(
                  onChanged: _changeEtatInitialState,
                  decoration: InputDecoration(
                      labelText: "Entrez l'etat initial: ",
                      hintText: 'Exemple: 0',
                      errorText: _etatInitErrorMsg,
                      helperText:
                          "L'etat choisi ici doit apparternir a l'ensemble des etats possibles",
                      icon: const Icon(Icons.data_usage)),
                )
              ],
            )),
            TextButton(
              style: flatBtnStyle(3),
              onPressed: _changeEtatInitialState,
              child:
                  _etatInitOk ? const Icon(Icons.done_rounded) : const Text(''),
            ),
          ],
        )
      ]),
    );

    var etatsFinauxContainer = Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: const [
            BoxShadow(blurRadius: 10, color: Colors.transparent)
          ]),
      child: Column(children: <Widget>[
        Row(
          children: [
            Expanded(
                child: Column(
              children: <Widget>[
                TextField(
                  onSubmitted: _changeEtatFinauxState,
                  controller: _textFieldEtatFinauxController,
                  decoration: InputDecoration(
                      labelText: "Entrez les etats finaux: ",
                      hintText: 'Exemple: 0, 1',
                      errorText: _etatFinauxErrorMsg,
                      icon: const Icon(Icons.data_array)),
                )
              ],
            )),
            TextButton(
              onPressed: _changeEtatFinauxState,
              style: flatBtnStyle(4),
              child:
                  _etatsOk ? const Icon(Icons.done_rounded) : const Text('Ok'),
            ),
          ],
        )
      ]),
    );

    var transitionsContainer = Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'Table de transitions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Divider(
            height: 20,
            indent: 50,
            endIndent: 50,
          ),
          transitions,
          TextButton(
            onPressed: _changeTransitionsState,
            style: flatBtnStyle(5),
            child: _transitionsOk
                ? const Icon(Icons.done_rounded)
                : const Text(''),
          ),
        ],
      ),
    );

    var continuContainer = Container(
      // padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          TextButton(
            onPressed: () => {},
            style: flatBtnStyle(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [Text('Continuer'), Icon(Icons.navigate_next)],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(padding: EdgeInsets.all(15)),
            const Text(
              'Automate',
              style: TextStyle(fontSize: 25),
            ),
            const Divider(
              height: 10,
              indent: 20,
              endIndent: 20,
            ),
            alphabetContainer,
            etatsContainer,
            etatInitialContainer,
            etatsFinauxContainer,
            transitionsContainer,
            continuContainer
          ],
        ),
      ),
    );
  }
}
