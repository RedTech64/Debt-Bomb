import 'package:cloud_firestore/cloud_firestore.dart';




getData() async {
  await Firestore.instance.collection('reference').document('data').get();
}