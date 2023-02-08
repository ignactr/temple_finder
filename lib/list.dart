import 'package:flutter/material.dart';
import 'test_data.dart';

class PropListItem extends StatelessWidget {
  final String name;
  final String address;
  PropListItem(@required this.name, @required this.address);

  double distance = 12.5;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Text(name), Text(address)],
    );
  }
}

class PropList extends StatelessWidget {
  final void enterPage;
  PropList(@required this.enterPage);

  @override
  Widget build(BuildContext context) {
    return (ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: templeList.length,
      itemBuilder: (context, index) {
        return PropListItem(templeList[index][0], templeList[index][1]);
      },
    ));
  }
}
