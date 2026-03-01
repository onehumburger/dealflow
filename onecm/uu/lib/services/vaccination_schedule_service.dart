/// A single vaccine dose in the CDC schedule.
class ScheduledVaccine {
  final String name;
  final int doseNumber;
  final int ageMonths;
  final String description;

  const ScheduledVaccine({
    required this.name,
    required this.doseNumber,
    required this.ageMonths,
    required this.description,
  });

  /// Unique key combining vaccine name and dose number.
  String get key => '$name#$doseNumber';
}

/// The status of a vaccine in the schedule relative to the baby's age.
enum VaccineStatus {
  administered,
  overdue,
  upcoming,
  future,
}

/// A vaccine with its computed status for display.
class VaccineStatusEntry {
  final ScheduledVaccine vaccine;
  final VaccineStatus status;

  const VaccineStatusEntry({
    required this.vaccine,
    required this.status,
  });
}

/// US CDC recommended vaccination schedule for 0-36 months.
///
/// Pure logic service with no database dependency.
class VaccinationScheduleService {
  /// Full CDC vaccination schedule for 0-18 months.
  List<ScheduledVaccine> get fullSchedule => _schedule;

  /// Returns all vaccines due up to the given age (inclusive).
  List<ScheduledVaccine> getScheduleForAge(int ageMonths) {
    return _schedule.where((v) => v.ageMonths <= ageMonths).toList();
  }

  /// Returns vaccines due in the next 2 months from the given age.
  List<ScheduledVaccine> getUpcomingVaccinations(int ageMonths) {
    return _schedule
        .where((v) => v.ageMonths > ageMonths && v.ageMonths <= ageMonths + 2)
        .toList();
  }

  /// Returns vaccines that are past due and not yet administered.
  ///
  /// A vaccine is overdue if its scheduled age is strictly less than the
  /// baby's current age and it hasn't been administered.
  List<ScheduledVaccine> getOverdueVaccinations(
    int ageMonths,
    Set<String> administeredKeys,
  ) {
    return _schedule
        .where((v) =>
            v.ageMonths < ageMonths && !administeredKeys.contains(v.key))
        .toList();
  }

  /// Returns the full schedule with status computed for each vaccine.
  List<VaccineStatusEntry> getVaccineStatus({
    required int ageMonths,
    required Set<String> administeredKeys,
  }) {
    return _schedule.map((v) {
      final VaccineStatus status;
      if (administeredKeys.contains(v.key)) {
        status = VaccineStatus.administered;
      } else if (v.ageMonths < ageMonths) {
        status = VaccineStatus.overdue;
      } else if (v.ageMonths <= ageMonths + 2) {
        status = VaccineStatus.upcoming;
      } else {
        status = VaccineStatus.future;
      }
      return VaccineStatusEntry(vaccine: v, status: status);
    }).toList();
  }

  static const _schedule = <ScheduledVaccine>[
    // Hepatitis B: birth, 1 month, 6 months
    ScheduledVaccine(
      name: 'Hepatitis B',
      doseNumber: 1,
      ageMonths: 0,
      description: 'First dose at birth',
    ),
    ScheduledVaccine(
      name: 'Hepatitis B',
      doseNumber: 2,
      ageMonths: 1,
      description: 'Second dose at 1 month',
    ),
    // Rotavirus: 2, 4, 6 months
    ScheduledVaccine(
      name: 'Rotavirus',
      doseNumber: 1,
      ageMonths: 2,
      description: 'First dose at 2 months',
    ),
    // DTaP: 2, 4, 6, 15 months
    ScheduledVaccine(
      name: 'DTaP',
      doseNumber: 1,
      ageMonths: 2,
      description: 'First dose at 2 months',
    ),
    // Hib: 2, 4, 6, 15 months
    ScheduledVaccine(
      name: 'Hib',
      doseNumber: 1,
      ageMonths: 2,
      description: 'First dose at 2 months',
    ),
    // PCV13: 2, 4, 6, 12 months
    ScheduledVaccine(
      name: 'PCV13',
      doseNumber: 1,
      ageMonths: 2,
      description: 'First dose at 2 months',
    ),
    // IPV: 2, 4, 6 months
    ScheduledVaccine(
      name: 'IPV',
      doseNumber: 1,
      ageMonths: 2,
      description: 'First dose at 2 months',
    ),
    // 4 months
    ScheduledVaccine(
      name: 'Rotavirus',
      doseNumber: 2,
      ageMonths: 4,
      description: 'Second dose at 4 months',
    ),
    ScheduledVaccine(
      name: 'DTaP',
      doseNumber: 2,
      ageMonths: 4,
      description: 'Second dose at 4 months',
    ),
    ScheduledVaccine(
      name: 'Hib',
      doseNumber: 2,
      ageMonths: 4,
      description: 'Second dose at 4 months',
    ),
    ScheduledVaccine(
      name: 'PCV13',
      doseNumber: 2,
      ageMonths: 4,
      description: 'Second dose at 4 months',
    ),
    ScheduledVaccine(
      name: 'IPV',
      doseNumber: 2,
      ageMonths: 4,
      description: 'Second dose at 4 months',
    ),
    // 6 months
    ScheduledVaccine(
      name: 'Hepatitis B',
      doseNumber: 3,
      ageMonths: 6,
      description: 'Third dose at 6 months',
    ),
    ScheduledVaccine(
      name: 'Rotavirus',
      doseNumber: 3,
      ageMonths: 6,
      description: 'Third dose at 6 months',
    ),
    ScheduledVaccine(
      name: 'DTaP',
      doseNumber: 3,
      ageMonths: 6,
      description: 'Third dose at 6 months',
    ),
    ScheduledVaccine(
      name: 'Hib',
      doseNumber: 3,
      ageMonths: 6,
      description: 'Third dose at 6 months',
    ),
    ScheduledVaccine(
      name: 'PCV13',
      doseNumber: 3,
      ageMonths: 6,
      description: 'Third dose at 6 months',
    ),
    ScheduledVaccine(
      name: 'IPV',
      doseNumber: 3,
      ageMonths: 6,
      description: 'Third dose at 6 months',
    ),
    ScheduledVaccine(
      name: 'Influenza',
      doseNumber: 1,
      ageMonths: 6,
      description: 'First dose at 6 months (annual)',
    ),
    // 12 months
    ScheduledVaccine(
      name: 'PCV13',
      doseNumber: 4,
      ageMonths: 12,
      description: 'Fourth dose at 12 months',
    ),
    ScheduledVaccine(
      name: 'MMR',
      doseNumber: 1,
      ageMonths: 12,
      description: 'First dose at 12 months',
    ),
    ScheduledVaccine(
      name: 'Varicella',
      doseNumber: 1,
      ageMonths: 12,
      description: 'First dose at 12 months',
    ),
    ScheduledVaccine(
      name: 'Hepatitis A',
      doseNumber: 1,
      ageMonths: 12,
      description: 'First dose at 12 months',
    ),
    // 15 months
    ScheduledVaccine(
      name: 'DTaP',
      doseNumber: 4,
      ageMonths: 15,
      description: 'Fourth dose at 15 months',
    ),
    ScheduledVaccine(
      name: 'Hib',
      doseNumber: 4,
      ageMonths: 15,
      description: 'Fourth dose at 12-15 months',
    ),
    // 18 months
    ScheduledVaccine(
      name: 'Hepatitis A',
      doseNumber: 2,
      ageMonths: 18,
      description: 'Second dose at 18 months',
    ),
  ];
}
