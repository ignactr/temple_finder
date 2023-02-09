import 'package:flutter/material.dart';
import 'test_data.dart';
import 'package:flutter_geocoder/geocoder.dart';

class PropListItem extends StatelessWidget {
  final String name;
  final String address;
  //final nameAndLocationList;
  PropListItem(
    @required this.name,
    @required this.address,
  );

  double distance = 12.5;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
      onTap: () => {},
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
  final Function enterPage;
  PropList(this.enterPage);

  Future<List<List>> nameAndLocationList(List<List<String>> givenList) async {
    List<List> listToReturn = [];
    await Future.forEach(
      givenList,
      (row) async {
        var query = row[1];
        var results = await Geocoder.local.findAddressesFromQuery(query);
        var firstResult = results.first;
        listToReturn.add([row[0], firstResult.coordinates]);
      },
    );
    print('lista: $listToReturn');
    return listToReturn;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: templeList.length,
        itemBuilder: (context, index) {
          return PropListItem(templeList[index][0], templeList[index][1]);
        },
      )),
      Text(
        nameAndLocationList(templeList).toString(),
        style: TextStyle(fontSize: 18),
      ),
      ElevatedButton(
        onPressed: () => {enterPage(0)},
        style:
            ElevatedButton.styleFrom(backgroundColor: const Color(0xFF374151)),
        child: const Text(
          'Powrót',
          style: TextStyle(fontSize: 18),
        ),
      ),
    ]);
  }
}
