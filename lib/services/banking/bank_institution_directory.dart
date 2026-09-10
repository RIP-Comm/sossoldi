// dart format width=400

import 'bank_institution.dart';

abstract interface class BankInstitutionDirectory {
  Future<List<BankInstitution>> getInstitutions({String? country, BankingCustomerType customerType = BankingCustomerType.personal});
}
