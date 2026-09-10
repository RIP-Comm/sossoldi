// dart format width=400

import '../bank_institution.dart';
import '../bank_institution_directory.dart';
import 'enable_banking_api.dart';
import 'enable_banking_errors.dart';
import 'enable_banking_institution_mapper.dart';

class EnableBankingInstitutionDirectory implements BankInstitutionDirectory {
  final EnableBankingApi _api;
  final _mapper = const EnableBankingInstitutionMapper();

  EnableBankingInstitutionDirectory(this._api);

  @override
  Future<List<BankInstitution>> getInstitutions({String? country, BankingCustomerType customerType = BankingCustomerType.personal}) => withEnableBankingErrors(() async {
    final values = await _api.getAspsps(country: country, psuType: customerType.name);
    return List.unmodifiable(values.map(_mapper.institution));
  });
}
