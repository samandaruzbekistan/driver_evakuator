import 'package:driver_evakuator/background_locator/models.dart';
import 'package:driver_evakuator/controllers/location_controller.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase{
  Database? database;
  String tableName = "locations";
  String jobsTableName = "jobs";
  final LocationController controller = Get.put(LocationController());
  LocalDatabase();

  Future<Database> getDb() async {
    if (database == null) {
      database = await createDatabase();
      return database!;
    }
    return database!;
  }

  createDatabase() async {
    print("Database ochish uchun harakat boshlandi");

    String databasesPath = await getDatabasesPath();
    String dbPath = '${databasesPath}locations.db';
    print("Databasening manzili $dbPath");


    var database = await openDatabase(dbPath, version: 1, onCreate: populateDb);
    print("Database ochildi");
    print("Database ochiqmi:   ${database.isOpen}");

    return database;
  }

  void populateDb(Database database, int version) async {
    await database.execute("CREATE TABLE IF NOT EXISTS $tableName ("
        "id INTEGER PRIMARY KEY,"
        "lat DOUBLE,"
        "long DOUBLE"
        ")");

    await database.rawInsert(
        'INSERT INTO $tableName (id, lat, long) VALUES (?, ?, ?)',
        [1, 0.0, 0.0]);

    await database.execute("CREATE TABLE IF NOT EXISTS $jobsTableName ("
        "id INTEGER PRIMARY KEY,"
        "job_id TEXT,"
        "minMoney double,"
        "minKm double,"
        "kmMoney double,"
        "amount double,"
        "totalDistanceKm double,"
        "status TEXT,"
        "lat DOUBLE,"
        "long DOUBLE"
        ")");
  }

  Future addJob(JobModel jobModel, double minMoney) async {
    Database db = await getDb();
    var id = await db.insert(jobsTableName, jobModel.toJson());
    print("Job $id bilan databsega saqlandi");
  }

  Future<Map<String, dynamic>?> getJobById(String id) async {
    Database db = await getDb();

    // Query the database to retrieve the row with the specified id
    List<Map<String, dynamic>> result = await db.query(
      jobsTableName,
      where: 'job_id = ?',
      whereArgs: [id],
    );

    // If a row with the specified id exists, return it, otherwise return null
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }



  Future<int> getPendingJobCount() async {
    Database db = await getDb();

    // Query the database to count rows where status = false
    List<Map<String, dynamic>> result = await db.query(
      jobsTableName,
      where: 'status = ?',
      whereArgs: ["false"], // Assuming status is a text column
    );

    // Return the count of rows matching the condition
    return result.length;
  }

  Future<Map<String, dynamic>?> getFalseStatusJob() async {
    Database db = await getDb();

    // Query the database to retrieve the row with the specified id
    List<Map<String, dynamic>> result = await db.query(
      jobsTableName,
      where: 'status = ?',
      whereArgs: ['false'],
    );

    // If a row with the specified id exists, return it, otherwise return null
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<void> updateLocation(double newLat, double newLong) async {
    Database db = await getDb();

    // Update the row with the specified id
    await db.update(
      jobsTableName,
      {
        'lat': newLat,
        'long': newLong,
      },
      where: 'status = ?',
      whereArgs: ['false'],
    );

    print('Location has been updated.');
  }

  Future<void> completeJob(String id) async {
    Database db = await getDb();

    // Update the row with the specified id
    await db.update(
      jobsTableName,
      {
        'status': true,
      },
      where: 'job_id = ?',
      whereArgs: [id],
    );

    print('Job completed.');
  }

  Future<void> updateLocationAndInfo(double newLat, double newLong, double amount, double totalDistanceKm) async {
    Database db = await getDb();

    // Update the row with the specified id
    await db.update(
      jobsTableName,
      {
        'lat': newLat,
        'long': newLong,
        'amount': amount,
        'totalDistanceKm': totalDistanceKm,
      },
      where: 'status = ?',
      whereArgs: ['false'],
    );
    // controller.updateJobData(amount, newLat);
    // controller.amount.value = amount;
    // print('Location has been updated.');
    // print(controller.amount);
  }




//  Location queries


  Future<Map<String, dynamic>?> getLocationById(int id) async {
    Database db = await getDb();

    // Query the database to retrieve the row with the specified id
    List<Map<String, dynamic>> result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    // If a row with the specified id exists, return it, otherwise return null
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  void printLocationById(int id) async {
    // Retrieve the location details for the specified id
    Map<String, dynamic>? location = await getLocationById(id);

    // Check if the location exists
    if (location != null) {
      // Print the details of the location
      print('Location Details for ID $id:');
      print('ID: ${location['id']}');
      print('Latitude: ${location['lat']}');
      print('Longitude: ${location['long']}');
    } else {
      // Print a message indicating that the location was not found
      print('Location with ID $id was not found.');
    }
  }

  Future addLocation(LocationModel locationModel) async {
    Database db = await getDb();
    var id = await db.insert(tableName, locationModel.toJson());
    print("Location $id bilan databsega saqlandi");
  }

  Future<List> getLocations() async {
    Database db = await getDb();

    var result = await db.query(tableName, columns: ["id","lat", "long"]);
    return result.toList();
  }
}