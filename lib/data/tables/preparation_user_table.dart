import 'package:drift/drift.dart';
import 'package:on_time_front/data/tables/user_table.dart';

class PreparationUsers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get preparationName => text().withLength(min: 1, max: 30)();
  IntColumn get preparationTime => integer()();
  IntColumn get order => integer()();
}