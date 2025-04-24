class TimeRecord {
  final String? project;
  final String? task;
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final String? duration;
  final String? note;

  TimeRecord({
    this.project,
    this.task,
    this.date,
    this.startTime,
    this.endTime,
    this.duration,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'project': project,
      'task': task,
      'date': date?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'note': note,
    };
  }

  factory TimeRecord.fromMap(Map<String, dynamic> map) {
    return TimeRecord(
      project: map['project'],
      task: map['task'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      startTime: map['startTime'],
      endTime: map['endTime'],
      duration: map['duration'],
      note: map['note'],
    );
  }
}
