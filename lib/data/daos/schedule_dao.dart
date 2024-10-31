import 'package:drift/drift.dart';
import 'package:on_time_front/config/database.dart';
import 'package:on_time_front/data/tables/places_table.dart';
import 'package:on_time_front/data/tables/schedules_table.dart';
import 'package:on_time_front/domain/entities/schedule_entity.dart';

part 'schedule_dao.g.dart';

@DriftAccessor(tables: [Schedules, Places])
class ScheduleDao extends DatabaseAccessor<AppDatabase>
    with _$ScheduleDaoMixin {
  final AppDatabase db;

  ScheduleDao(this.db) : super(db);

  Future<void> createSchedule(ScheduleEntity scheduleEntity) async {
    await into(db.schedules).insert(
      scheduleEntity.toModel().toCompanion(false),
    );
  }

  Future<List<ScheduleEntity>> getScheduleList() async {
    final List<Schedule> query = await select(db.schedules).get();
    final List<ScheduleEntity> scheduleList = [];
    Future.forEach(query, (shcedule) async {
      // final place = await (select(db.places)
      //       ..where((tbl) => tbl.id.equals(shcedule.placeId)))
      //     .getSingle();
      scheduleList.add(ScheduleEntity.fromModel(
        shcedule,
        const User(
            id: 1,
            email: 'email',
            password: 'password',
            name: 'name',
            spareTime: 1,
            note: 'note',
            score: 1),
        const Place(id: 1, placeName: 'placeName'),
      ));
    });
    return scheduleList;
  }
}
