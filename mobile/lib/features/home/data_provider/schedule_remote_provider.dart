
import 'dart:convert';

import 'package:royal_cinema/core/token_data.dart';
import 'package:http/http.dart' as http;

import '../model/schedule_response.dart';
import '../model/scheduledMovie.dart';
import 'schedule_provider.dart';

class ScheduledRemoteProvider implements ScheduledProvider {

  final _baseUrl = 'http://127.0.0.1:5000/${TokenData.token}'; //new
  // final _baseUrl = 'http://192.168.56.1:3000';

  @override
  addScheduled(ScheduledMovie scheduled) async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
      'Content-Type': 'application/json'
    };
    var url = Uri.parse('http://127.0.0.1:5000/token:bhjbtyBHgtyvytyv/schedules');

    var body = {
      "movieId": scheduled.movieId,
      "movie": scheduled.movie,
      "startTime": scheduled.startTime,
      "endTime": scheduled.endTime,
      "capacity": scheduled.capacity,
      "seatsLeft": scheduled.seatsLeft,
      "price": scheduled.price
    };
    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print(resBody);
    }
    else {
      throw Exception('Failed to create schedules.');
    }
  }

  @override
  editScheduled(String id, ScheduledMovie scheduled) async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
      'Content-Type': 'application/json'
    };
    var url = Uri.parse('http://127.0.0.1:5000/token:bhjbtyBHgtyvytyv/schedules/${scheduled.id}');

    var body = {
      "movieId": scheduled.movieId,
      "movie": scheduled.movie,
      "startTime": scheduled.startTime,
      "endTime": scheduled.endTime,
      "capacity": scheduled.capacity,
      "seatsLeft": scheduled.seatsLeft,
      "price": scheduled.price
    };
    var req = http.Request('PATCH', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print(resBody);
    }
    else {
      throw Exception('Failed to update schedules.');
    }
  }

  @override
  Future<ScheduledMovie?> getScheduled(String id) async {
    var headersList = {
      'Accept': '*/*',
      "Authorization": "Bearer token",
      'Content-Type': 'application/json'
    };
    var url = Uri.parse('http://127.0.0.1:5000/token:bhjbtyBHgtyvytyv/schedules');

    var body = {

    };
    var req = http.Request('GET', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final List scheduleds = json.decode(resBody);

      for (int i = 0; i < scheduleds.length; i++) {
        if (scheduleds[i].id == id) {
          return scheduleds[i];
        }
      }
    } else {
      throw Exception();
    }
  }

  @override
  Future<List<ScheduleResponse>> getAllScheduleds() async {
    final headersList = {
      "Accept": "*/*",
      "User-Agent": "Thunder Client (https://www.thunderclient.com)",
      "Authorization":
      "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoic3RhZmYiLCJpZCI6IjYyOThiOTZmZTk1OThmYWNmMGI2OTQwYyIsImlhdCI6MTY1NDIwMTg0NX0.BkxEosQ8y2jVSZkRDhfohOe9dB0K7wVOnv-VwHSu69k"
    };

    final response = await http.get(Uri.parse('${_baseUrl}/schedules'),
        headers: headersList);

    if (response.statusCode == 200) {

      final scheduleList = jsonDecode(response.body);

      List<ScheduleResponse> fetchedList = [];

      for (var key in scheduleList.keys) {

        List<ScheduledMovie> listSchedule = [];

        for (var schedule in scheduleList[key]) {
          listSchedule.add(ScheduledMovie.fromJson(schedule));
        }

        fetchedList.add(ScheduleResponse(date: key, schedules: listSchedule));
      }

      // print(fetchedList[0].schedules[0].movie);

      return fetchedList;
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  // @override
  // Future<List<ScheduleResponse>> getAllScheduleds() async {
  //
  //   var headersList = {
  //     'Accept': '*/*',
  //     'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
  //     'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoidXNlciIsImlkIjoiNjI5OGExZTcyYjEyYWFhYTI5ODYzODJjIiwiaWF0IjoxNjU0MTcwMTUzfQ.KpOgJoKqfp55TN9y3vfGdibl_taN5tgGojEoCVSCrMc',
  //     'Content-Type': 'application/json'
  //   };
  //   var url = Uri.parse('http://127.0.0.1:5000/token:bhjbtyBHgtyvytyv/schedules');
  //
  //   var body = {
  //   };
  //   var req = http.Request('GET', url);
  //   req.headers.addAll(headersList);
  //   req.body = json.encode(body);
  //
  //   var res = await req.send();
  //   final resBody = await res.stream.bytesToString();
  //
  //   // final response = await http.get(Uri.parse('$_baseUrl/schedules'));
  //
  //   if (res.statusCode >= 200 && res.statusCode < 300) {
  //
  //     final scheduleList = jsonDecode(resBody);
  //
  //     List<ScheduleResponse> fetchedList = [];
  //
  //     for (var key in scheduleList.keys) {
  //
  //       List<ScheduledMovie> listSchedule = [];
  //
  //       for (var schedule in scheduleList[key]) {
  //         listSchedule.add(ScheduledMovie.fromJson(schedule));
  //       }
  //
  //       fetchedList.add(ScheduleResponse(date: key, schedules: listSchedule));
  //     }
  //
  //
  //     return fetchedList;
  //
  //     // print("DDDDDDDDDDDDDDDDDDDDDDDDDDDD");
  //     // print(resBody);
  //     //
  //     // final schedulesList = jsonDecode(resBody);
  //     //
  //     // List<ScheduledMovie> fetchedList = [];
  //     //
  //     // print(schedulesList);
  //     // List<ScheduledMovie> c = await schedulesList.map((scheduled) {
  //     //   ScheduledMovie c2 = ScheduledMovie.fromJson(scheduled);
  //     //   return c2;
  //     // }).toList();
  //     // return c;
  //   } else {
  //     print("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBbb");
  //     throw Exception();
  //   }
  // }
}
