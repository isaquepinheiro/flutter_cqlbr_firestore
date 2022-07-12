## Criteria Query Language Brasil (Dart/Flutter)

CQLBr é um framework opensource que provê escritas gerando o script SQL, através de uma interface, permitindo mapear de forma orientada a objeto, toda sintaxe de comandos SQL (SELECT, INSERT, UPDATE e DELETE), para banco de dados relacional.

Durante o desenvolvimento de software, é evidente a preocupação em que se tem em aumentar a produtividade e manter a compatibilidade entre os possíveis bancos que um sistema pode usar. No que se refere a sintaxe de banco de dados, temos em alguns casos, incompatibilidades entre comandos SQL, exigindo assim, a necessidade de um maior controle na escrita de cada banco, e foi para ajudar nesse ponto crítico que CQLBr nasceu, ele foi projetado para que a escrita de querys seja única, de forma funcional e orientada a objeto, possibilitando assim a mesma escrita feita pelo framework, gerar querys diferentes conforme o banco selecionado, o qual pode ser mudado de forma muito simples, bastando selecionar um dos modelos implementados no CQLBr Framework, sem ter que re-faturar diversas querys espalhadas pelas milhares de linhas de código.

## COMO COMEÇAR A USAR

```dart
  CQLBr cqlbr = CQLBr(select: CQLSelectFirebird(FirebaseFirestore.instance));
```

TODO: Ao instâncias o CQL, deve-se injetar a ele o nodelo do banco que se vai usar, isso poderá ser feito pode parâmetro em seu sistema, configurando qual modelo será injetado.

## SELECT

```dart
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

  await instance1.collection('users').doc('2').set(
    {
      'username': 'Bob',
      'email': 'isaquesp@gmail.com',
    },
  );

  // CQLBr
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
    },
  );
}
```

## INSERT

```dart
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

  await instance1.collection('users').doc('2').set(
    {
      'username': '= Bob',
      'email': 'bob@gmail.com',
    },
  );

  // CQLBr
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
```

## UPDATE

```dart
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
      'email': 'bob@gmail.com',
    },
  );

  await instance1.collection('users').doc('2').set(
    {
      'username': 'Isaque Pinheiro',
      'email': 'isaquesp@gmail.com',
    },
  );

  // CQLBr
  CQLBr cqlbr = CQLBr(select: CQLSelectFirestore(instance1));

  test(
    'TestUpdateWhere_CollectionFirestore',
    () async {
      // Vários testes de operações no banco de dados,
      // devem estar cobertos por uma trasação.
      final batch = instance1.batch();

      bool result1 = false;
      // CQLBr
      Query result = cqlbr
          .update$('users')
          .set$('username', 'Isaque')
          .where$('email')
          .equal$('isaquesp@gmail.com')
          .asResult();
      await result.get().then(
        (list) {
          for (var doc in list.docs) {
            doc.reference
                .update((cqlbr.ast.update() as CQLUpdateFirestore).toMap())
                .then((value) => result1 = true)
                .onError((error, stackTrace) => result1 = false);
          }
        },
      );

      bool result2 = false;
      // Fake Cloud Firestore
      await instance1
          .collection('users')
          .where('email', isEqualTo: 'bob@gmail.com')
          .get()
          .then(
        (list) {
          for (var doc in list.docs) {
            doc.reference
                .update({'username': 'Bob Esponja'})
                .then((value) => result2 = true)
                .onError((error, stackTrace) => result2 = false);
          }
        },
      );

      await batch.commit();

      expect(result1, result2);
    },
  );
}
```

## DELETE

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_cqlbr_core/flutter_cqlbr_core.dart';
import 'package:flutter_cqlbr_firestore/flutter_cqlbr_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  // Fake Cloud Firestore
  final instance1 = FakeFirebaseFirestore();

  await instance1.collection('users').doc().set(
    {
      'username': 'Bob',
      'email': 'bob@gmail.com',
    },
  );

  await instance1.collection('users').doc('2').set(
    {
      'username': 'Isaque',
      'email': 'isaque@gmail.com',
    },
  );

  // CQLBr
  CQLBr cqlbr = CQLBr(select: CQLSelectFirestore(instance1));

  test(
    'TestDelete_CollectionFirestore',
    () async {
      final batch = instance1.batch();

      bool result1 = false;
      // CQLBr
      DocumentReference result = cqlbr.delete$().from$('users').asResult();
      await result.delete().then((value) => result1 = true).onError(
            (error, stackTrace) => result1 = false,
          );

      bool result2 = false;
      //Fake Cloud Firestore
      await instance1
          .collection('users')
          .doc()
          .delete()
          .then((value) => result2 = true)
          .onError(
            (error, stackTrace) => result2 = false,
          );

      await batch.commit();

      expect(result1, result2);
    },
  );

  test(
    'TestDeleteWhere_CollectionFirestore',
    () async {
      final batch = instance1.batch();

      bool result1 = false;
      // CQLBr
      Query result = cqlbr
          .delete$()
          .from$('users')
          .where$('email')
          .equal$('isaque@gmail.com')
          .asResult<Query>();

      await result.get().then(
        (list) {
          for (var doc in list.docs) {
            doc.reference.delete().then((value) => result1 = true).onError(
                  (error, _) => result1 = false,
                );
          }
        },
      );

      bool result2 = false;
      // Fake Cloud Firestore
      Query resultFake = instance1
          .collection('users')
          .where('email', isEqualTo: 'bob@gmail.com');

      await resultFake.get().then(
        (list) {
          for (var doc in list.docs) {
            doc.reference.delete().then((value) => result2 = true).onError(
                  (error, _) => result2 = false,
                );
          }
        },
      );

      await batch.commit();

      expect(result1, result2);
    },
  );
}
```

## Additional information

TODO: multi-database SQL syntax using object orientation, now in flutter.
