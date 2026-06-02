import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/deposit_model.dart';

abstract class DepositDataSource {
  Future<void> submitDeposit(DepositModel deposit);
}

class DepositDataSourceImpl implements DepositDataSource {
  final FirebaseFirestore _firestore;

  DepositDataSourceImpl(this._firestore);

  @override
  Future<void> submitDeposit(DepositModel deposit) async {
    final docRef = _firestore.collection('deposit_requests').doc();
    
    final depositWithId = DepositModel(
      id: docRef.id,
      userId: deposit.userId,
      amount: deposit.amount,
      currency: deposit.currency,
      bankId: deposit.bankId,
      uniqueCode: deposit.uniqueCode,
      status: deposit.status,
      createdAt: deposit.createdAt,
    );
    
    await docRef.set(depositWithId.toJson());
  }
}
