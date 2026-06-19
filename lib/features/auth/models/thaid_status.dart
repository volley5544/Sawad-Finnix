/// Verification state derived from `/auth/thaid/status/{sessionId}`.
enum ThaidVerifyState { pending, success, failed, unknown }

/// Person data returned by ThaiID after a successful verification.
///
/// The exact response shape from the backend has not been provided yet, so this
/// parser is intentionally defensive: it checks several common field names and
/// nesting (`data`/`person`/`result`). Once a real sample is available, tighten
/// the mapping in [ThaidStatus.fromMap].
class ThaidPerson {
  const ThaidPerson({
    this.pid,
    this.firstName,
    this.lastName,
    this.fullName,
    this.birthDate,
    this.address,
  });

  final String? pid;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final DateTime? birthDate;
  final String? address;

  factory ThaidPerson.fromMap(Map<String, dynamic> map) {
    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = map[k];
        if (v != null && '$v'.isNotEmpty) return '$v';
      }
      return null;
    }

    final birthRaw = pick(['birthdate', 'birthDate', 'date_of_birth', 'dob']);
    DateTime? birth;
    if (birthRaw != null) birth = DateTime.tryParse(birthRaw);

    return ThaidPerson(
      pid: pick(['pid', 'citizen_id', 'citizenId', 'nationalId', 'id_card']),
      firstName: pick(['given_name', 'givenName', 'firstName', 'first_name']),
      lastName: pick(['family_name', 'familyName', 'lastName', 'last_name']),
      fullName: pick(['name', 'fullName', 'full_name', 'name_en']),
      birthDate: birth,
      address: pick(['address', 'house_address']),
    );
  }
}

class ThaidStatus {
  const ThaidStatus({required this.state, this.person, this.raw});

  final ThaidVerifyState state;
  final ThaidPerson? person;
  final Map<String, dynamic>? raw;

  bool get isSuccess => state == ThaidVerifyState.success;
  bool get isPending => state == ThaidVerifyState.pending;

  factory ThaidStatus.fromMap(Map<String, dynamic> map) {
    // Find the status indicator across likely keys.
    final statusRaw =
        '${map['status'] ?? map['state'] ?? map['result'] ?? ''}'
            .toLowerCase();

    ThaidVerifyState state;
    if (['success', 'complete', 'completed', 'verified', 'done', 'approved']
        .contains(statusRaw)) {
      state = ThaidVerifyState.success;
    } else if (['pending', 'processing', 'waiting', 'in_progress', 'inprogress']
        .contains(statusRaw)) {
      state = ThaidVerifyState.pending;
    } else if (['failed', 'error', 'rejected', 'expired', 'cancel', 'cancelled']
        .contains(statusRaw)) {
      state = ThaidVerifyState.failed;
    } else {
      // No explicit status: infer success if person data is present.
      state = ThaidVerifyState.unknown;
    }

    // Locate nested person data if present.
    Map<String, dynamic>? personMap;
    for (final key in ['data', 'person', 'result', 'profile', 'user']) {
      final v = map[key];
      if (v is Map<String, dynamic>) {
        personMap = v;
        break;
      }
    }
    personMap ??= map; // fall back to top-level fields

    final person = ThaidPerson.fromMap(personMap);
    final hasPerson = person.pid != null ||
        person.fullName != null ||
        person.firstName != null;

    if (state == ThaidVerifyState.unknown && hasPerson) {
      state = ThaidVerifyState.success;
    }

    return ThaidStatus(
      state: state,
      person: hasPerson ? person : null,
      raw: map,
    );
  }
}
