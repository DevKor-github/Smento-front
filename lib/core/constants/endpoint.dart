import 'dart:core';

class Endpoint {
  // schedule
  static const _getSchedule = '/schedule/show';
  static const _getSchedulesByDate = '/schedule/show';

  static const _createSchedule = '/schedule/add';
  static const _updateSchedule = '/schedule/update';
  static const _deleteSchedule = '/schedule/delete';

  static getSchedule(String scheduleId) => '$_getSchedule$scheduleId';
  static get getSchedulesByDate => _getSchedulesByDate;

  static get createSchedule => _createSchedule;

  static updateSchedule(String scheduleId) => '$_updateSchedule$scheduleId';
  static deleteSchedule(String scheduleId) => '$_deleteSchedule$scheduleId';

  // preparation
  static const _createDefaultPreparation =
      '/preparationuser/set/first'; // 사용자 준비과정 첫 세팅
  static const _createCustomPreparation =
      '/preparationschedule/create'; // 스케줄별 준비과정 생성

  static const _getPreparationStepById =
      '/preparationuser/show/all'; // 사용자 준비과정 조회
  static const _getPreparationByScheduleId =
      '/schedule/get/preparation'; // 스케줄별 준비과정 조회

  static const _updatePreparation = '/preparationuser/modify'; // 사용자 준비과정 수정

  // delelte는 api가 없음.

  static get createDefaultPreparation => _createDefaultPreparation;
  static getCreateCustomPreparation(String scheduleId) =>
      '$_createCustomPreparation/$scheduleId';

  static getPreparationByScheduleId(String scheduleId) =>
      '$_getPreparationByScheduleId/$scheduleId';
  static get getPreparationStepById => _getPreparationStepById;

  static get updatePreparation => _updatePreparation;
}