import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/library.dart';

class LibraryService {
  Future<List<Library>> loadLibrarySchedules() async {
    final String response = await rootBundle.loadString('assets/library_schedules.json');
    final data = await json.decode(response);
    return List<Library>.from(data.map((x) => Library.fromJson(x)));
  }
}