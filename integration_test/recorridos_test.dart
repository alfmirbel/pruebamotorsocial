import 'package:integration_test/integration_test.dart';

import '../test/journeys/j01_j04_test.dart' as j01_j04;
import '../test/journeys/j05_j08_test.dart' as j05_j08;
import '../test/journeys/j09_j12_test.dart' as j09_j12;

/// Recorridos J-01…J-12 en un dispositivo real (modo semilla):
/// `flutter test integration_test -d windows`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  j01_j04.main();
  j05_j08.main();
  j09_j12.main();
}
