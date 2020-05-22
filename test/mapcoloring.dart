import 'package:constrained_sps/constrained.dart';

class MapColoringConstraint extends BinaryConstraint {

  MapColoringConstraint(var variable1, var variable2): super(variable1,
      variable2);

  @override
  bool isSatisfied(Map assignment) {
    // if either variable is not in the assignment then it must be consistent
    // since they still have their domain
    if (!assignment.containsKey(variable1) || !assignment.containsKey(variable2
        )) {
      return true;
    }
    // check that the color of var1 does not equal var2
    return (assignment[variable1] != assignment[variable2]);
  }
}


void main() {
  var variables = ['Western Australia', 'Northern Territory',
      'South Australia', 'Queensland', 'South Wales', 'Victoria', 'Tasmania'];
  var domains = {};
  for (var variable in variables) {
    domains[variable] = ['r', 'g', 'b'];
  }

  var mapCSP =  CSP(variables, domains);

  mapCSP.addBinaryConstraint(MapColoringConstraint('Western Australia',
      'Northern Territory'));
  mapCSP.addBinaryConstraint(MapColoringConstraint('Western Australia',
      'South Australia'));
  mapCSP.addBinaryConstraint(MapColoringConstraint('South Australia',
      'Northern Territory'));
  mapCSP.addBinaryConstraint(MapColoringConstraint('Queensland',
      'Northern Territory'));
  mapCSP.addBinaryConstraint(MapColoringConstraint('Queensland',
      'South Australia'));
  mapCSP.addBinaryConstraint(MapColoringConstraint('Queensland',
      'South Wales'));
  mapCSP.addBinaryConstraint(MapColoringConstraint('South Wales',
      'South Australia'));
  mapCSP.addBinaryConstraint(MapColoringConstraint('Victoria',
      'South Australia'));
  mapCSP.addBinaryConstraint(MapColoringConstraint('Victoria',
      'South Wales'));

  var stopwatch = Stopwatch()
    ..start();
  backtrackingSearch(mapCSP, {}).then((solution) {
    print(stopwatch.elapsedMicroseconds);
    print(solution);
  });
}
