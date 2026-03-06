enum CollectionStatus { scheduled, assigned, enRoute, arrived, collecting, completed, failed }

extension CollectionStatusExtension on CollectionStatus {
  String get label {
    switch (this) {
      case CollectionStatus.scheduled: return 'Scheduled';
      case CollectionStatus.assigned: return 'Assigned';
      case CollectionStatus.enRoute: return 'En Route';
      case CollectionStatus.arrived: return 'Arrived';
      case CollectionStatus.collecting: return 'Collecting';
      case CollectionStatus.completed: return 'Completed';
      case CollectionStatus.failed: return 'Failed';
    }
  }
}
