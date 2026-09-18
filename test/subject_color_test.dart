import 'package:cahier_journal_ce1/core/theme/app_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('subjectColorFor', () {
    test('reconnaît les matières du référentiel', () {
      expect(subjectColorFor('Grammaire'), SubjectColor.francais);
      expect(subjectColorFor('Numération'), SubjectColor.mathematiques);
      expect(subjectColorFor('Questionner le monde'), SubjectColor.questionnerLeMonde);
      expect(subjectColorFor('BCD'), SubjectColor.bcd);
      expect(subjectColorFor('EMC'), SubjectColor.emc);
      expect(subjectColorFor('EPS'), SubjectColor.eps);
    });

    test('retombe sur specialiste pour un libellé inconnu ou un spécialiste', () {
      expect(subjectColorFor('Anglais'), SubjectColor.specialiste);
      expect(subjectColorFor('Vietnamien'), SubjectColor.specialiste);
      expect(subjectColorFor('Un libellé jamais vu'), SubjectColor.specialiste);
    });
  });
}
