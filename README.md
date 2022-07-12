## Criteria Query Language Brasil (Dart/Flutter)

CQLBr é um framework opensource que provê escritas gerando o script SQL, através de uma interface, permitindo mapear de forma orientada a objeto, toda sintaxe de comandos SQL (SELECT, INSERT, UPDATE e DELETE), para banco de dados relacional.

Durante o desenvolvimento de software, é evidente a preocupação em que se tem em aumentar a produtividade e manter a compatibilidade entre os possíveis bancos que um sistema pode usar. No que se refere a sintaxe de banco de dados, temos em alguns casos, incompatibilidades entre comandos SQL, exigindo assim, a necessidade de um maior controle na escrita de cada banco, e foi para ajudar nesse ponto crítico que CQLBr nasceu, ele foi projetado para que a escrita de querys seja única, de forma funcional e orientada a objeto, possibilitando assim a mesma escrita feita pelo framework, gerar querys diferentes conforme o banco selecionado, o qual pode ser mudado de forma muito simples, bastando selecionar um dos modelos implementados no CQLBr Framework, sem ter que re-faturar diversas querys espalhadas pelas milhares de linhas de código.

## COMO COMEÇAR A USAR

```dart
  CQLBr cqlbr = CQLBr(select: CQLSelectFirebird());
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
Expect : "INSERT INTO CLIENTES (ID_CLIENTE, NOME_CLIENTE) VALUES (1, 'MyName')";

String result = cqlbr
       .insert$()
       .into$('CLIENTES')
       .set$('ID_CLEINTE', 1)
       .set$('NOME_CLIENTE', 'MyName')
    .asString();
```

## UPDATE

```dart
Expect : "UPDATE CLIENTES SET ID_CLIENTE = 2, NOME_CLIENTE = 'MyName' WHERE ID_CLIENTE = 1";

String result = cqlbr
       .update$()
       .set$('ID_CLEINTE', 2)
       .set$('NOME_CLIENTE', 'MyName')
       .where$('ID_CLIENTE = 1')
    .asString();
```

## DELETE

```dart
Expect : "DELETE FROM CLIENTES WHERE ID_CLIENTE = 1";

String result = cqlbr
       .delete$()
       .from$('CLIENTES') 
       .where$('ID_CLIENTE = 1')
    .asString();
```

## Additional information

TODO: multi-database SQL syntax using object orientation, now in flutter.
