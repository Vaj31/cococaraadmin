import 'package:flutter/material.dart';
import 'package:ccpladmin/helpers/widgets/my_text.dart';
import 'package:ccpladmin/model/polist_model.dart';

class DispatchDocsScreen extends StatelessWidget {
  final PolistModel data;

  const DispatchDocsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyText.bodyLarge("Dispatch Docs Content Here"),
    );
  }
}