import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_cqlbr_core/flutter_cqlbr_core.dart';

class CQLWhereFirestore extends CQLSection implements ICQLWhere {
  late final ICQLExpression _expression;

  CQLWhereFirestore() : super(name: 'Where') {
    _expression = CQLExpression();
  }

  @override
  ICQLExpression get expression => _expression;
  @override
  set expression(ICQLExpression value) => _expression = value;

  @override
  T? serialize<T extends Object>([CollectionReference? collectionRef]) {
    return isEmpty()
        ? collectionRef as T
        : collectionRef?.where(
            _expression.left!.serialize<String>().replaceAll('=', '').trim(),
            isEqualTo: _expression.right
                ?.serialize<String>()
                .replaceAll('=', '')
                .trim()) as T;
  }

  @override
  void clear() {
    _expression.clear();
  }

  @override
  bool isEmpty() {
    return _expression.isEmpty();
  }
}
