// dart format width=400

import '../banking_exception.dart';
import 'enable_banking_errors.dart';

void checkEnableBankingReference(String providerId, String remoteId) {
  if (providerId != enableBankingId || remoteId.trim().isEmpty || remoteId == '.' || remoteId == '..') {
    throw const BankingException(providerId: enableBankingId, failure: BankingFailure.rejected);
  }
}
