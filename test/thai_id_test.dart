import 'package:flutter_test/flutter_test.dart';
import 'package:sawad_finnix/core/utils/thai_id.dart';

void main() {
  group('ThaiId.isValid', () {
    test('accepts a valid national ID', () {
      // Real ThaiID sample (checksum digit = 6).
      expect(ThaiId.isValid('1103701967986'), isTrue);
      // Same value with mask should also validate.
      expect(ThaiId.isValid('1-1037-01967-98-6'), isTrue);
    });

    test('rejects a wrong check digit', () {
      expect(ThaiId.isValid('1103701967987'), isFalse);
    });

    test('rejects wrong length', () {
      expect(ThaiId.isValid('12345'), isFalse);
      expect(ThaiId.isValid(''), isFalse);
    });
  });

  group('ThaiId.mask', () {
    test('formats 13 digits as #-####-#####-##-#', () {
      expect(ThaiId.mask('1103701967986'), '1-1037-01967-98-6');
    });

    test('formats partial input progressively', () {
      expect(ThaiId.mask('1'), '1');
      expect(ThaiId.mask('11'), '1-1');
      expect(ThaiId.mask('11037'), '1-1037');
      expect(ThaiId.mask('110370'), '1-1037-0');
    });

    test('strips non-digits and caps at 13', () {
      expect(ThaiId.mask('1-1037-01967-98-6extra'), '1-1037-01967-98-6');
    });
  });

  group('ThaiId.digitsOnly', () {
    test('removes mask characters', () {
      expect(ThaiId.digitsOnly('1-1037-01967-98-6'), '1103701967986');
    });
  });

  group('ThaiId.hash', () {
    test('is deterministic and ignores the mask', () {
      final a = ThaiId.hash('1103701967986');
      final b = ThaiId.hash('1-1037-01967-98-6');
      expect(a, b);
      // SHA-256 hex is 64 chars and not the raw pid.
      expect(a.length, 64);
      expect(a, isNot(contains('1103701967986')));
    });

    test('differs for different ids', () {
      expect(ThaiId.hash('1103701967986'),
          isNot(ThaiId.hash('1103701967987')));
    });
  });
}
