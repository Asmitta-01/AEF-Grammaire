typedef Tableau = Set<Set<String>>;

/// Automate, plus precisement **Automate a Etats Finis**
///
/// Un automate à états finis est une machine abstraite définie par le quintuplet (X, Q, q0, F, δ) tel que :
/// – X est l’ensemble des symboles formant les mots en entrée (l’alphabet du mot à reconnaître) ;
/// – Q est l’ensemble des états possibles ;
/// – q0 est l’état initial ;
/// – F est l’ensemble des états finaux (F 6= ∅, F ⊆ Q). F représente l’ensemble des états d’acceptation ;
/// – δ est une fonction de transition qui permet de passer d’un état à un autre selon l’entrée en cours :
/// δ : Q × (X ∪ {ε}) 7→ 2Q
/// δ(qi, a) = {qj1, ..., qjk} ou ∅ (∅ signifie que la configuration n’est pas prise en charge)
class Automate {
  /// X est l’ensemble des symboles formant les mots en entrée (l’alphabet du mot à reconnaître) ;
  Set<String> _ensembledeSymboles = const <String>{};

  /// Q est l’ensemble des états possibles ;
  Set<String> _ensembleEtatsPossibles = const <String>{};

  /// q0 est l’état initial ;
  String _etatInitial = '';

  /// F est l’ensemble des états finaux (F 6= ∅, F ⊆ Q). F représente l’ensemble des états d’acceptation
  Set<String> _ensembleEtatsFinaux = const <String>{};

  /// δ est une fonction de transition qui permet de passer d’un état à un autre selon l’entrée en cours
  Tableau _transitions = {{}};

  Automate(
      {X = const <String>{},
      Q = const <String>{},
      q0 = '',
      F = const <String>{}}) {
    _ensembledeSymboles = X;
    _ensembleEtatsPossibles = Q;
    _etatInitial = q0;
    _ensembleEtatsFinaux = F;
  }

  Set<String> get X => _ensembledeSymboles;
  set X(Set<String> value) => _ensembledeSymboles = value;

  Set<String> get Q => _ensembleEtatsPossibles;
  set Q(Set<String> value) => _ensembleEtatsPossibles = value;

  String get q0 => _etatInitial;
  set q0(String value) => _etatInitial = value;

  Set<String> get F => _ensembleEtatsFinaux;
  set F(Set<String> value) => _ensembleEtatsFinaux = value;

  @override
  String toString() {
    var str = 'δ est donne par le tableau suivant: \n\tEtat \t';
    for (var element in X) {
      str += '| $element ';
    }
    for (var i = 0; i < Q.length; i++) {
      str += '\n\t ${Q.elementAt(i)}\t';
      for (var j = 0; j < X.length; j++) {
        if (_transitions.elementAt(i).elementAt(j).isEmpty)
          str += '| - ';
        else
          str += '| ${_transitions.elementAt(i).elementAt(j)} ';
      }
    }
    return '($X, $Q, $q0, $F, δ)\n$str';
  }

  /// Un mot est accepté par un AEF si, après avoir lu tout le mot, l’automate se trouve dans un
  /// état final (qf ∈ F). En d’autres termes, un mot est rejeté par un AEF dans deux cas :
  /// – L’automate est dans l’état qi, l’entrée courante étant a et la transition δ(qi, a) n’existe pas
  /// – L’automate arrive à lire tout le mot mais l’état de sortie n’est pas un état final
  bool motValide(String mot) {
    String etatCourant = q0;
    for (var i = 0; i < mot.length; i++) {
      if (X.contains(mot[i]))
        etatCourant = _transitions
            .elementAt(Q.toList().indexOf(etatCourant))
            .elementAt(X.toList().indexOf(mot[i]));
      else
        return false;

      if (etatCourant.isEmpty) return false;
    }

    return F.contains(etatCourant);
  }

  bool get contientTousSesElements {
    return _ensembleEtatsFinaux.isNotEmpty &&
        _ensembleEtatsPossibles.isNotEmpty &&
        _ensembledeSymboles.isNotEmpty &&
        _etatInitial.isNotEmpty &&
        _transitions.isNotEmpty;
  }
}

// void main(List<String> args) {
//   Automate g = Automate(X: {'a', 'b'}, Q: {'0', '1'}, q0: '0', F: {'1'});
//   Tableau t = {
//     {'0', '1'},
//     {'', '1'}
//   };
//   g._transitions = t;

//   print(g);
//   print(g.motValide('ab'));
//   print(g.motValide('ba'));
//   print(g.motValide('a'));
// }
