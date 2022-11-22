// ignore_for_file: avoid_print

typedef Regles = Map<String, Set<String>>;

///  On appelle grammaire le quadruplet (V, N, X, R)
/// – V est un ensemble fini de symboles dits terminaux, on l’appelle également vocabulaire terminal ;
/// – N est un ensemble fini (disjoint de V) de symboles dits non-terminaux ou encore concepts ;
/// – S un non-terminal particulier appelé axiome (point de départ de la dérivation) ;
/// – R est un ensemble de règles de productions de la forme g → d tel que g ∈ (V + N)+ et
/// d ∈ (V + N)∗. La notation g → d est appelée une dérivation et signifie que g peut être remplacé par d.
class Grammaire {
  /// Epsilon: le mot vide
  static const eps = 'ε';

  /// V est un ensemble fini de symboles dits terminaux, on l’appelle également vocabulaire terminal
  Set<String> _vocabulaireTerminal = const <String>{};

  /// N est un ensemble fini (disjoint de V) de symboles dits non-terminaux ou encore concepts
  Set<String> _nonTerminaux = const <String>{};

  /// S un non-terminal particulier appelé axiome (point de départ de la dérivation)
  String _axiome = '';

  /// R est un ensemble de règles de productions de la forme g → d tel que g ∈ (V + N)+ et d ∈ (V + N)∗ .
  ///  La notation g → d est appelée une dérivation et signifie que g peut être remplacé par d.
  Regles _regles = const {};

  Grammaire({V = const <String>{}, N = const <String>{}, S = ''}) {
    _vocabulaireTerminal = V;
    _nonTerminaux = N;
    _axiome = S;
  }

  Set<String> get V => _vocabulaireTerminal;
  set V(Set<String> value) => _vocabulaireTerminal = value;

  Set<String> get N => _nonTerminaux;
  set N(Set<String> value) => _nonTerminaux = value;

  String get S => _axiome;
  set S(String value) => _axiome = value;

  Regles get R => _regles;
  set R(Regles value) => _regles = value;

  @override
  String toString() {
    var str = '';
    var gauche = R.keys;
    var droite = R.values;
    for (var i = 0; i < R.length; i++) {
      str += '${gauche.elementAt(i)} -> ';

      for (var j = 0; j < droite.elementAt(i).length; j++) {
        str += droite.elementAt(i).elementAt(j);
        if (j < droite.elementAt(i).length - 1) str += ' | ';
      }
      if (i < gauche.length - 1) str += ', ';
    }

    if (R.length > 1) str = '{$str}';
    return '($V, $N, $S, $str)';
  }

  /// Fermeture transitive de Kleene
  static Set<String> fermetureTransitive(Set<String> l1,
          [Set<String> l2 = const <String>{}]) =>
      {...l1, ...l2, eps};

  /// Fermeture Non transitive de Kleene
  static Set<String> fermetureNonTransitive(Set<String> l1,
          [Set<String> l2 = const <String>{}]) =>
      {...l1, ...l2, eps};

  bool get contientTousSesElements {
    return _axiome.isNotEmpty &&
        _nonTerminaux.isNotEmpty &&
        _regles.isNotEmpty &&
        _vocabulaireTerminal.isNotEmpty;
  }

  Set<String> get quelquesMotsGeneres {
    var strs = {_axiome};
    R.forEach((key, value) {
      for (var element in value) {
        var prevRes = strs.firstWhere((element) => element.contains(key));
        if (key == _axiome || prevRes.isNotEmpty) {
          var res = prevRes.isNotEmpty ? prevRes : key;
          var i = 0;
          while (i < 3) {
            res = res.replaceAll(key, element);
            strs.add(res);
            i++;
          }
          // strs.add('...');
        }
      }
    });
    return strs;
  }

  /// Type 3 ou grammaire régulière (à droite 1) : toutes les règles de production sont de la
  /// forme g → d où g ∈ N et d = aB tel que a appartient à V∗ et B appartient à N ∪ {ε} ;
  bool get _estDeTypeTrois {
    var g = R.keys; // gauche
    var d = R.values; // droite

    for (var i = 0; i < d.length; i++) {
      if (N.containsAll(g.elementAt(i).split(''))) {
        var a = <String>{};
        var target = '';
        for (var j = 0; j < d.elementAt(i).length; j++) {
          target = d.elementAt(i).elementAt(j);
          var k;
          for (k = 0; k < target.length; k++) {
            if (V.contains(target[k]) || target[k] == eps)
              a.add(target[k]);
            else
              break;
          }

          var B = target.substring(k);
          if (!(N.containsAll(B.split('')) || B == eps)) return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  /// Type 2 ou grammaire hors-contexte : toutes les règles de production sont de la forme
  /// g → d où g ∈ N et d ∈ (V + N)∗ ;
  bool get _estDeTypeDeux {
    var g = R.keys; // gauche
    var d = R.values; // droite

    var vN = fermetureTransitive(V, N);
    for (var i = 0; i < d.length; i++) {
      if (N.containsAll(g.elementAt(i).split(''))) {
        var target = '';
        for (var j = 0; j < d.elementAt(i).length; j++) {
          target = d.elementAt(i).elementAt(j);
          if (!vN.containsAll(target.split(''))) return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  /// Type 1 ou grammaire contextuelle : toutes les règles sont de la forme g → d tel que
  /// g ∈ (N + V)+, d ∈ (V + N)∗ et |g| 6 |d|. De plus, si ε apparaît à droite alors la partie
  /// gauche doit seulement contenir S (l’axiome). On peut aussi trouver la définition suivante
  /// des grammaires de type 1 : toutes les règles sont de la forme αBβ → αωβ tel que
  /// α, β ∈ (V + N)∗, B ∈ X et ω ∈ (V + N)∗ ;
  bool get _estDeTypeUn {
    var g = R.keys; // gauche
    var d = R.values; // droite

    for (var i = 0; i < R.length; i++) {
      if (fermetureNonTransitive(V, N).containsAll(g.elementAt(i).split(''))) {
        var relationGaucheDroiteOkay = true;
        for (var element in d.elementAt(i)) {
          if (!fermetureTransitive(V, N).containsAll(element.split('')) ||
              g.elementAt(i).length > element.length ||
              (element.contains(eps) && g.elementAt(i) != S)) {
            relationGaucheDroiteOkay = false;
            break;
          }
        }
        if (!relationGaucheDroiteOkay) return false;
      } else {
        return false;
      }
    }
    return true;
  }

  int get type {
    return _estDeTypeTrois
        ? 3
        : _estDeTypeDeux
            ? 2
            : _estDeTypeUn
                ? 1
                : 0;
  }
}

// void main(List<String> args) {
//   Grammaire g = Grammaire(V: {'a', 'b', 'c'}, N: {'S', 'T'}, S: 'S');
//   Regles R = {
//     'S': {'Ta', 'Sa'},
//     'T': {'Tb', 'Sb', Grammaire.eps},
//   };
//   g.R = R;

//   print(g);
//   print(g.quelquesMotsGeneres);
//   print(g.type);
// }
