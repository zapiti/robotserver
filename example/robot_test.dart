
import 'package:robotserver/robotserver.dart';
import 'my_test.dart';

void main() async {
  final rrs = RobotServer(MyTest('teste'));
  rrs.serve();
}
