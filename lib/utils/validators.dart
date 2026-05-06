class Validators {
  /// Validate name input
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  /// Validate that a date is selected and not in the past
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Please select a date';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date.isBefore(today)) {
      return 'Cannot book for a past date';
    }
    return null;
  }

  /// Validate that a time slot is selected
  static String? validateTimeSlot(String? timeSlot) {
    if (timeSlot == null || timeSlot.isEmpty) {
      return 'Please select a time slot';
    }
    return null;
  }

  /// Validate that a service type is selected
  static String? validateServiceType(String? serviceType) {
    if (serviceType == null || serviceType.isEmpty) {
      return 'Please select a service type';
    }
    return null;
  }
}
