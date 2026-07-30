import 'package:flutter/material.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/model/polist_model.dart';

class ImagesScreen extends StatelessWidget {
  final PolistModel data;

  const ImagesScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyText.bodyLarge("Images Gallery Here"),
    );
  }
}