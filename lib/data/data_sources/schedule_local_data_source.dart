import 'package:on_time_front/core/database/database.dart';
import 'package:on_time_front/domain/entities/schedule_entity.dart';

abstract interface class ScheduleLocalDataSource {
  final AppDatabase appDatabase;

  ScheduleLocalDataSource({
    required this.appDatabase,
  });

  Future<void> createSchedule(ScheduleEntity schedule, int userId);

  Future<List<ScheduleEntity>> getScheduleList();

  Future<void> updateSchedule(ScheduleEntity schedule);

  Future<void> deleteSchedule(ScheduleEntity schedule);
}