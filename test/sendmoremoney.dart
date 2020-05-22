import 'package:constrained_sps/constrained.dart';

class SendMoreMoneyConstraint extends ListConstraint {

  SendMoreMoneyConstraint(var letters): super(letters);

  @override
  bool isSatisfied(Map assignment) {
    // if there are duplicate values then it's not correct
    /*List values = new List.from(assignment.values);
    Set set = new Set();
    for (var i = 0; i < assignment.length; i++) {
      if (!set.add(values[i])) {
        return false;
      }
    }*/

    var d = Set.from(assignment.values);
    if (d.length < assignment.length) {
      return false;
    }

    // if all variables have been assigned, check if it adds up correctly
    if (assignment.length == variables.length) {
      int send = assignment['S'] * 1000 + assignment['E'] * 100 + assignment['N'] * 10 + assignment['D'];
      int more = assignment['M'] * 1000 + assignment['O'] * 100 + assignment['R'] * 10 + assignment['E'];
      int money = assignment['M'] * 10000 + assignment['O'] * 1000 + assignment['N'] * 100 + assignment['E'] * 10 + assignment['Y'];
      if ((send + more) == money) {
        return true;
      } else {
        return false;
      }
    }

    // until we have all of the variables assigned, the assignment is valid
    return true;
  }
}


void main() {
  var variables = ['S', 'E', 'N', 'D', 'M', 'O', 'R', 'Y'];
  var domains = {};
  for (var variable in variables) {
    domains[variable] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  }
  domains['S'] = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  domains['M'] = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  var mapCSP =  CSP(variables, domains);

  mapCSP.addListConstraint( SendMoreMoneyConstraint(variables));

  var stopwatch =  Stopwatch()..start();
  backtrackingSearch(mapCSP, {}, mrv: true).then((solution) {
    print('Took ' + stopwatch.elapsed.toString() + ' seconds to solve.');
    print(solution);
    int send = solution['S'] * 1000 + solution['E'] * 100 + solution['N'] * 10 + solution['D'];
    int more = solution['M'] * 1000 + solution['O'] * 100 + solution['R'] * 10 + solution['E'];
    int money = solution['M'] * 10000 + solution['O'] * 1000 + solution['N'] * 100 + solution['E'] * 10 + solution['Y'];
    print(send.toString() + ' + ' + more.toString() + ' = ' + money.toString());
  });

}
