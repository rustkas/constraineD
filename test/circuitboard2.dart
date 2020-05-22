import 'package:constrained_sps/constrained.dart';
import 'dart:math';

//a class to use as a variable for the circuit board
//a component of the circuit board
class Chip {
  String name;
  int width;
  int height;
  Chip(this.name, this.width, this.height);

  @override
  String toString() => name;
  @override
  bool operator ==(other) {
    return name == other.name;
  }

  //generate the domain as a list of tuples of top left corners
  List generate_domain(int board_width, int board_height) {
    var domain = [];
    for (var x = 0; x < (board_width - width + 1); x++) {
      for (var y = (height - 1); y < board_height; y++) {
        domain.add([x, y]);
      }
    }

    return domain;
  }
}

//A binary constraint that makes sure two Chip variables do not overlap.
class CircuitBoardConstraint extends BinaryConstraint {
  CircuitBoardConstraint(var var1, var var2) : super(var1, var2);

  @override
  bool isSatisfied(assignment) {
    //if either variable is not in the assignment then it must be consistent
    //since they still have their domain
    if (!assignment.containsKey(variable1) ||
        !assignment.containsKey(variable2)) {
      return true;
    }
    //check that var1 does not overlap var2

    //got the overlapping rectangle formula from
    //http://codesam.blogspot.com/2011/02/check-if-two-rectangles-intersect.html
    int x1 = assignment[variable1][0];
    int y1 = assignment[variable1][1];
    int x2 = variable1.width - 1 + x1;
    int y2 = y1 - variable1.height + 1;
    int x3 = assignment[variable2][0];
    int y3 = assignment[variable2][1];
    int x4 = variable2.width - 1 + x3;
    int y4 = y3 - variable2.height + 1;

    //print x1, y1, self.var1.name
    //print x2, y2, self.var1.name
    //print x3, y3, self.var2.name
    //print x4, y4, self.var2.name
    //print (x1 > x4 or x2 < x3 or y1 < y4 or y2 > y3)
    return (x1 > x4 || x2 < x3 || y1 < y4 || y2 > y3);
  }
}

//print's a circuit board solution nicely
void print_cb_solution(Map solution, board_width, board_height) {
  //for sol in solution:
  //    print sol.name
  //    print solution[sol]
  //create a board of periods
  var board = {};
  for (var i = 0; i < board_width; i++) {
    for (var j = 0; j < board_width; j++) {
      board[Point(i, j)] = '.';
    }
  }

  // label each square
  for (Chip variable in solution.keys) {
    int x = solution[variable][0];
    int y = solution[variable][1];
    for (var i = 0; i < variable.width; i++) {
      for (var j = 0; j < variable.height; j++) {
        //print ('${x+i}, ${y-j}: ${variable.name}');
        board[Point(x + i, y - j)] = variable.name;
      }
    }
  }
  //print(board);
  //print out the square
  var rows = [];
  for (var row = 0; row < board_height; row++) {
    var rowstring = '';
    for (var col = 0; col < board_width; col++) {
      rowstring = rowstring + board[Point(col, row)];
    }
    rows.add(rowstring);
  }
  for (var row = rows.length - 1; row > -1; row--) {
    print(rows[row]);
  }
}

void main() {
  //create the CSP
  var board_width = 20;
  var board_height = 20;
  //create the chips
  var c1 = Chip('1', 6, 2);
  var c2 = Chip('2', 5, 8);
  var c3 = Chip('3', 10, 4);
  var c4 = Chip('4', 16, 1);
  var c5 = Chip('5', 10, 8);
  var c6 = Chip('6', 8, 10);
  var c7 = Chip('7', 5, 5);
  var variables = [c1, c2, c3, c4, c5, c6, c7];
  var domains = {};
  for (var variable in variables) {
    domains[variable] = variable.generate_domain(board_width, board_height);
  }

  var cb_csp = CSP(variables, domains);

  //add constraints
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c1, c2));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c1, c3));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c1, c4));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c1, c5));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c1, c6));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c1, c7));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c2, c3));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c2, c4));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c2, c5));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c2, c6));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c2, c7));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c3, c4));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c3, c5));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c3, c6));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c3, c7));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c4, c5));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c4, c6));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c4, c7));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c5, c6));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c5, c7));
  cb_csp.addBinaryConstraint(CircuitBoardConstraint(c6, c7));

  //run the solution and calculate the time it took
  var stopwatch = Stopwatch()..start();
  backtrackingSearch(cb_csp, {}, mrv: true).then((solution) {
    print('Took ' + stopwatch.elapsed.toString() + ' seconds to solve.');

    if (solution == null) {
      print('No solution found!');
    } else {
      print(solution);
      print('Found a solution on the ' +
          board_width.toString() +
          'x' +
          board_height.toString() +
          'grid:');
      print_cb_solution(solution, board_width, board_height);
    }
  });
}
