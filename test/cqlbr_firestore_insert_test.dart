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
      'username': '= Bob',
      'email': 'bob@gmail.com',
    },
  );
  // CQLBr
  await instance1.collection('users').doc('2').set(
    {
      'username': '= Bob',
      'email': 'bob@gmail.com',
    },
  );
  CQLBr cqlbr = CQLBr(select: CQLSelectFirestore(instance1));

  test(
    'TestInsertWhere_CollectionFirestore',
    () async {
      final batch = instance1.batch();

      bool result1 = false;
      // CQLBr
      CollectionReference result = cqlbr
          .insert$()
          .into$('users')
          .values$('username', 'Isaque Pinheiro')
          .values$('email', 'isaque@gmail.com')
          .asResult();
      await result
          .add((cqlbr.ast.insert() as CQLInsertFirestore).toMap())
          .then((value) => result1 = true);

      bool result2 = false;
      // Fake Cloud Firestore
      await instance1.collection('users').add({
        "username": "= Isaque Pinheiro",
        "email": "isaque@gmail.com"
      }).then((value) => result2 = true);

      await batch.commit();

      expect(result1, result2);
    },
  );
}
