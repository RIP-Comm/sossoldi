enum BankingCustomerType { personal, business }

class BankInstitution {
  final String providerId;
  final String id;
  final String name;
  final String country;
  final Uri? logoUri;
  final Set<BankingCustomerType> customerTypes;
  final Duration? maximumConsentDuration;
  final bool isSandbox;
  final bool isBeta;
  final List<String> requiredPsuHeaders;

  BankInstitution({
    required this.providerId,
    required this.id,
    required this.name,
    required this.country,
    this.logoUri,
    Set<BankingCustomerType> customerTypes = const {},
    this.maximumConsentDuration,
    this.isSandbox = false,
    this.isBeta = false,
    List<String> requiredPsuHeaders = const [],
  }) : customerTypes = Set.unmodifiable(customerTypes),
       requiredPsuHeaders = List.unmodifiable(requiredPsuHeaders);
}
