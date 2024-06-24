import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart';

class SqlHelper {
  Database? db;

  Future<void> init() async {
    try {
      if (kIsWeb) {
        var factory = databaseFactoryFfiWeb;
        db = await factory.openDatabase('pos.db');
      } else {
        db = await openDatabase(
          'pos.db',
          version: 1,
          onCreate: (db, version) {
            print('database created successfully');
          },
        );
      }
    } catch (e) {
      print('Error in creating database: $e');
    }
  }

  Future<void> registerForeignKeys() async {
    await db!.rawQuery("PRAGMA foreign_keys = ON");
    var result = await db!.rawQuery("PRAGMA foreign_keys");

    print('foreign keys result : $result');
  }

  Future<bool> createTables() async {
    try {
      await registerForeignKeys();
      var batch = db!.batch();
      batch.execute("""
        Create table if not exists categories(
          id integer primary key,
          name text not null,
          description text not null
          ) 
          """);

      batch.execute("""
        Create table if not exists products(
          id integer primary key,
          name text not null,
          description text not null,
          price double not null,
          stock integer not null,
          isAvailable boolean not null,
          image text,
          categoryId integer not null,
          foreign key(categoryId) references categories(id)
          on delete restrict
          ) 
          """);

      batch.execute("""
        Create table if not exists clients(
          id integer primary key,
          name text not null,
          phone text,
          email text,
          address text
          ) 
          """);
      batch.execute("""
        Create table if not exists orders(
          id integer primary key,
          label text,
          totalPrice real,
          discount real,
          clientId integer not null,
          foreign key(clientId) references clients(id)
          on delete restrict
          ) 
          """);
      batch.execute("""
        Create table if not exists orderProductItems(
         orderId integer,
         productCount integer,
         productId integer,
          foreign key(productId) references products(id)
          on delete restrict
          ) 
          """);
      batch.execute("""
         Create table if not exists exchangeRate(
         id integer primary key,
       currencyPair text not null,
      eRate real

      )
      """);

      // batch.execute("""
      // Create table if not exists exchangeRate(
      //   id integer primary key,
      //currencyPair text not null,
      //  eRate text
      //    )
      //      """);

      batch.execute("""
          insert into exchangeRate(currencyPair,eRate) values ('USD/EGP',47);
         """);
      var result = await batch.commit();
      print('resuts $result');
      return true;
    } catch (e) {
      print('Error in creating table: $e');
      return false;
    }
  }
}
