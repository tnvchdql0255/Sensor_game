// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  late Database _db;
  static const String DB_NAME = 'data.db';
  static const String TABLE_NAME = 'StageData';
  static const int DB_VERSION = 1;

  Future<Database> get db async {
    _db = await initDB();
    return _db;
  }

  Future<Database> initDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath,
        DB_NAME); //시스템 기본 데이터베이스경로에 데이터베이스이름을 붙인 경로를 만듬 (ex. game/db/ + data.db)

    bool exists = await io.File(path).exists(); //해당 경로에 데이터 베이스 파일이 존재하는지 확인함

    if (!exists) {
      // 데이터베이스가 존재하지 않으면 데이터베이스를 생성함
      // assets에 있는 파일을 복사하여 데이터베이스 파일을 생성합니다.
      await io.Directory(dirname(path)).create(recursive: true);

      // 데이터베이스를 열고 테이블을 생성합니다.
      Database db = await openDatabase(path, version: DB_VERSION,
          onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $TABLE_NAME (
            StageNum INTEGER PRIMARY KEY,
            isCleared BOOLEAN NOT NULL
          )
          ''');
        for (int i = 1; i <= 30; i++) {
          await db.rawInsert('''
            INSERT INTO $TABLE_NAME (StageNum, isCleared)
            VALUES (?, ?)
            ''', [i, false]);
        }
        await db.rawUpdate('''
          UPDATE $TABLE_NAME SET isCleared = ? WHERE StageNum = ?
          ''', [true, 1]);
      });
      return db;
    } else {
      // 데이터베이스가 이미 존재하는 경우 데이터베이스를 엽니다.
      return await openDatabase(path, version: DB_VERSION);
    }
  }

  Future<List<bool>> getAllStageStatus() async {
    final db = await this.db;
    List<Map> result = await db.query(TABLE_NAME, columns: ['isCleared']);
    List<bool> isClearedList = [];
    for (int i = 0; i < result.length; i++) {
      isClearedList.add(result[i]['isCleared'] == 1 ? true : false);
    }
    return isClearedList;
  }

  ///targetStage: 현재 스테이지, state: 바꿀 클리어 상태
  Future<bool> changeIsCleared(int targetStage, bool state) async {
    final db = await this.db;
    try {
      await db.rawUpdate(
          '''UPDATE $TABLE_NAME SET isCleared = ? WHERE StageNum = ?''',
          [state, targetStage]);
      return true;
    } catch (e) {
      return false;
    }
  }
}
