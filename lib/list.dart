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

class PropList extends StatefulWidget {
  final Function enterPage;
  PropList(this.enterPage);

  @override
  _PropList createState() => _PropList(enterPage);
}

class _PropList extends State<PropList> {
  final Function enterPage;
  _PropList(this.enterPage);

  List<List>? listWithCoords;

  Future<void> nameAndLocationList(List<List<String>> givenList) async {
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
    setState(() {
      listWithCoords = listToReturn;
    });
  }

  @override
  void initState() {
    super.initState();
    nameAndLocationList(templeList);
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
        listWithCoords.toString(),
        style: const TextStyle(fontSize: 18),
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
