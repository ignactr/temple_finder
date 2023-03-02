import 'dart:ffi';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'dart:math';
import 'data.dart';

class PropListItem extends StatelessWidget {
  final String name;
  final Coordinates coords;
  final double distance;
  final String time;
  final patchFindHandler;
  PropListItem(
      this.name, this.coords, this.distance, this.time, this.patchFindHandler);

  late int muchOfName = (name.length * 0.8).toInt();
  late int halfOfName = (name.length ~/ 2).toInt();

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Znajdź drogę do tego miejsca',
      child: Card(
        color: Colors.pink[700],
        shadowColor: Colors.pink[700],
        child: InkWell(
          onTap: () => {patchFindHandler(coords)},
          child: Container(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: 49,
                        child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 21, color: Colors.white),
                            )),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Najwcześniej o ',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white70)),
                            TextSpan(
                              text: '$time',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${roundDouble(distance, 1)} km',
                        style:
                            const TextStyle(fontSize: 21, color: Colors.white)),
                  )
                ],
              )),
        ),
      ),
    );
  }
}

class PropList extends StatefulWidget {
  final Function handleCancel;
  final CameraPosition devicesLocation;
  final patchFindHandler;
  final String time;
  final String weekDay;
  PropList(this.handleCancel, this.devicesLocation, this.patchFindHandler,
      this.time, this.weekDay);

  @override
  _PropList createState() =>
      _PropList(handleCancel, devicesLocation, patchFindHandler, time, weekDay);
}

class _PropList extends State<PropList> {
  final Function handleCancel;
  final CameraPosition devicesLocation;
  final patchFindHandler;
  String time;
  final String weekDay;
  _PropList(this.handleCancel, this.devicesLocation, this.patchFindHandler,
      this.time, this.weekDay);

//function getTempleList() takes time, time difference from mass in miliseconds, bool isSunday and a list of temples with dates and returns a list of just names and addresses
// hour in format "07:10"
  List<List<String>> getTempleList(time, timeDiff, isSunday, data) {
    List<List<String>> templeList = [];
    //for (var i = 0; i < 20; i++) {
    for (var i = 0; i < data.length; i++) {
      int nominator;
      if (isSunday) {
        nominator = 2;
      } else {
        nominator = 3;
      }

      for (var j = 0; j < data[i][nominator].length; j++) {
        var hourData = data[i][nominator][j];
        final parsedDate1 =
            DateTime.parse('1970-01-02 $time:00.000').millisecondsSinceEpoch;
        final parsedDate2 = DateTime.parse('1970-01-02 $hourData:00.000')
            .millisecondsSinceEpoch;

        if (parsedDate2 - parsedDate1 < timeDiff &&
            parsedDate2 - parsedDate1 > 0) {
          List<String> list = [];
          list.add(data[i][0]);
          list.add(data[i][1]);
          list.add(data[i][nominator][j]);
          templeList.add(list);
        }
      }
    }
    return templeList;
  }

//function getFutureTempleList() takes a list of temples with dates and returns a list with names and addresses of the earliest mass from current time
  List<List<String>> getFutureTempleList(data) {
    int timeDiff = 3600000; // 1 hour in miliseconds
    if (time.split(":")[0].length < 2) {
      time = "0" + time;
    }
    if (time.split(":")[1].length < 2) {
      time = time + "0";
    }
    bool isSunday = false;
    if (weekDay == 'niedziela') {
      isSunday = true;
    }
    List<List<String>> templeList = [];
    templeList = getTempleList(time, timeDiff, isSunday, data);
    while (templeList.length == 0) {
      timeDiff += 3600000;
      templeList = getTempleList(time, timeDiff, isSunday, data);
    }

    return templeList;
  }

  //function getDistance takes coordinates of two locations and returns distance between them in straight line (km)
  double getDistance(lat1, lon1, lat2, lon2) {
    double p = 0.017453292519943295;
    double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //function nameAndLocationList uses geocoder packages to turn adress from givenList to coordinates and then display them with names of locations in listToReturn
  Future<List<List>>? nameAndLocationList(
      List<List<String>> givenList, CameraPosition position2) async {
    List<List> listToReturn = [];
    await Future.forEach(
      givenList,
      (row) async {
        var query = row[1];
        var results = await Geocoder.local.findAddressesFromQuery(query);
        var firstResult = results.first;
        listToReturn.add([
          row[0],
          firstResult.coordinates,
          getDistance(
              firstResult.coordinates.latitude,
              firstResult.coordinates.longitude,
              position2.target.latitude,
              position2.target.longitude),
          row[2]
        ]);
      },
    );

    listToReturn.sort((a, b) => a[2].compareTo(b[2]));
    return listToReturn;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: nameAndLocationList(getFutureTempleList(data), devicesLocation),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: const Color(0xFF0f172a),
            body: Column(
              children: [
                const SizedBox(height: 20),
                (snapshot.data!.length == 0)
                    ? Column(children: [
                        SizedBox(height: 40),
                        Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFd1d5db),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(7))),
                            padding: const EdgeInsets.all(6),
                            child: Text('Brak wyników',
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 21,
                                    color: Color(0xFF1e293b))))
                      ])
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length > 7
                            ? 7
                            : snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return PropListItem(
                              snapshot.data![index][0],
                              snapshot.data![index][1],
                              snapshot.data![index][2],
                              snapshot.data![index][3],
                              patchFindHandler);
                        },
                      ),
                Expanded(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ElevatedButton(
                            onPressed: () => {handleCancel()},
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(10),
                                backgroundColor:
                                    Color.fromARGB(255, 55, 71, 97)),
                            child: const Text(
                              'Powrót',
                              style: TextStyle(fontSize: 21),
                            ),
                          ))),
                )
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: const Color(0xFF0f172a),
            body: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  color: Colors.pink[700],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
