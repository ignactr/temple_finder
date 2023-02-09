import 'package:flutter/material.dart';
import 'test_data.dart';
import 'package:flutter_geocoder/geocoder.dart';

class PropListItem extends StatelessWidget {
  final String name;
  final String address;
  PropListItem(@required this.name, @required this.address);

  double distance = 12.5;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
      onTap: () => {print('git')},
      child: Container(
        child: Column(children: [
          Text(name, style: TextStyle(fontSize: 15)),
          Text(address, style: TextStyle(fontSize: 15)),
          Text('${distance} km', style: TextStyle(fontSize: 15)),
        ]),
        margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
        padding: const EdgeInsets.all(3),
      ),
    ));
  }
}

class PropList extends StatelessWidget {
  final enterPage;
  PropList(@required this.enterPage);

  Future<void> nameDistanceCoordinates(List<List<String>> givenList) async {
    List<List<String>> listToReturn = [];
    givenList.forEach((row) async {
      var query = row[1];
      var results = await Geocoder.local.findAddressesFromQuery(query);
      var firstResult = results.first;
      print(firstResult.coordinates);
      print('elo');
    });
  }

  @override
  Widget build(BuildContext context) {
    nameDistanceCoordinates(templeList);
    return Column(children: [
      Expanded(
          child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: templeList.length,
        itemBuilder: (context, index) {
          return PropListItem(templeList[index][0], templeList[index][1]);
        },
      )),
      ElevatedButton(
        onPressed: () => {enterPage(0)},
        child: Text(
          'Powrót',
          style: TextStyle(fontSize: 18),
        ),
        style:
            ElevatedButton.styleFrom(backgroundColor: const Color(0xFF374151)),
      )
    ]);
  }
}
