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
  final String address;
  final patchFindHandler;
  PropListItem(this.name, this.coords, this.distance, this.address,
      this.patchFindHandler);

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places).toDouble();
    return ((value * mod).round().toDouble() / mod);
  }

  String formattedAddress() {
    if (address.length > 50) {
      return address.substring(0, 51) + '...';
    } else {
      return address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: 'znajdź drogę do tego miejsca',
        child: Card(
            color: const Color(0xFFe5e7eb),
            shadowColor: const Color(0xFFe5e7eb),
            child: InkWell(
                onTap: () => {patchFindHandler(coords)},
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                        child: Text(name, style: const TextStyle(fontSize: 21)),
                      ),
                      Text('${roundDouble(distance, 1)} km',
                          style: const TextStyle(fontSize: 21)),
                    ]),
                    Text(formattedAddress(),
                        style: const TextStyle(fontSize: 15))
                  ]),
                ))));
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
  final String time;
  final String weekDay;
  _PropList(this.handleCancel, this.devicesLocation, this.patchFindHandler,
      this.time, this.weekDay);

//function getTempleList() takes hour, bool isSunday and a list of temples with dates and returns a list of just names and addresses
  List<List<String>> getTempleList(hour, isSunday, data) {
    List<List<String>> templeList = [];
    for (var i = 0; i < data.length; i++) {
      int nominator;
      if (isSunday) {
        nominator = 2;
      } else {
        nominator = 3;
      }

      for (var j = 0; j < data[i][nominator].length; j++) {
        var hourDate = int.parse(data[i][nominator][j].substring(0, 2));
        if (hour == hourDate) {
          List<String> list = [];
          list.add(data[i][0]);
          list.add(data[i][1]);
          list.add(data[i][nominator][j]);
          // print(data[i][nominator][j]);
          templeList.add(list);
          print(list);
        }
      }
    }
    return templeList;
  }

//function getFutureTempleList() takes a list of temples with dates and returns a list with names and addresses of the earliest mass from current time
  List<List<String>> getFutureTempleList(data) {
    TimeOfDay formattedTime = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1]));
    bool? isSunday;
    if (weekDay == 'pon-pt') {
      isSunday = false;
    } else {
      isSunday = true;
    }
    int hour = formattedTime.hour + 1;
    List<List<String>> templeList = [];
    templeList = getTempleList(hour, isSunday, data);

    while (templeList.length == 0) {
      hour++;
      templeList = getTempleList(hour, isSunday, data);
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
  Future<List<List>> nameAndLocationList(
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
            return Column(
              children: [
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      snapshot.data!.length > 7 ? 7 : snapshot.data!.length,
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
                                backgroundColor: const Color(0xFF374151)),
                            child: const Text(
                              'Powrót',
                              style: TextStyle(fontSize: 21),
                            ),
                          ))),
                )
              ],
            );
          } else {
            return const Align(
                alignment: Alignment.center,
                child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator()));
          }
        });
  }
}
