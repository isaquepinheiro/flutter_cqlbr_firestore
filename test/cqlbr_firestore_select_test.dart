import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_cqlbr_core/flutter_cqlbr_core.dart';
import 'package:flutter_cqlbr_firestore/flutter_cqlbr_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  // Fake Cloud Firestore
  final instance1 = FakeFirebaseFirestore();
  await instance1.collection('users').doc('1').set(
    {
      'username': 'Bob',
      'email': 'isaquesp@gmail.com',
    },
  );
  // CQLBr
  await instance1.collection('users').doc('2').set(
    {
      'username': 'Bob',
      'email': 'isaquesp@gmail.com',
    },
  );
  CQLBr cqlbr = CQLBr(select: CQLSelectFirestore(instance1));

  test(
    'TestSelect_CollectionFirestore',
    () async {
      final batch = instance1.batch();

      // CQLBr
      CollectionReference result =
          cqlbr.select$().all$().from$('users').asResult();
      QuerySnapshot snapshot1 = await result.get();

      // Fake Cloud Firestore
      QuerySnapshot snapshot2 = await instance1.collection('users').get();

      await batch.commit();

      expect(snapshot1.docs.first.data().toString(),
          snapshot2.docs.first.data().toString());

      // debugPrint('Fake ${snapshot1.docs.first.data().toString()}');
      // debugPrint('CQLBr ${snapshot2.docs.first.data().toString()}');
    },
  );

  test(
    'TestSelectWhere_CollectionFirestore',
    () async {
      final batch = instance1.batch();

      // CQLBr
      Query result = cqlbr
          .select$()
          .all$()
          .from$('users')
          .where$('username')
          .equal$('Bob')
          .asResult();
      QuerySnapshot snapshot1 = await result.get();

      // Fake Cloud Firestore
      QuerySnapshot snapshot2 = await instance1
          .collection('users')
          .where('username', isEqualTo: 'Bob')
          .get();

      await batch.commit();

      expect(snapshot1.docs.first.data().toString(),
          snapshot2.docs.first.data().toString());

      // debugPrint('Fake ${snapshot1.docs.first.data().toString()}');
      // debugPrint('CQLBr ${snapshot2.docs.first.data().toString()}');
    },
  );
}
