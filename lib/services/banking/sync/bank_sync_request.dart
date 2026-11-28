enum BankSyncTrigger { manual, background }

class BankSyncRequest {
  final BankSyncTrigger trigger;
  final Map<String, String> psuHeaders;

  const BankSyncRequest({
    this.trigger = BankSyncTrigger.background,
    this.psuHeaders = const {},
  });

  Map<String, String> headersFor(List<String> requiredHeaders) {
    if (trigger == BankSyncTrigger.background) {
      if (psuHeaders.isNotEmpty) {
        throw const FormatException(
          'Background requests cannot contain PSU headers',
        );
      }
      return const {};
    }
    final normalized = {
      for (final item in psuHeaders.entries) item.key.toLowerCase(): item.value,
    };
    final required = requiredHeaders.map((name) => name.toLowerCase()).toSet();
    if (required.any((name) => normalized[name]?.trim().isNotEmpty != true) ||
        normalized.keys.any((name) => !required.contains(name))) {
      throw const FormatException(
        'Manual sync requires the complete PSU header set',
      );
    }
    if (normalized.entries.any(
      (entry) =>
          !RegExp(r'^psu-[a-z0-9-]+$').hasMatch(entry.key) ||
          entry.value.contains(RegExp(r'[\r\n]')),
    )) {
      throw const FormatException('Invalid PSU header');
    }
    return Map.unmodifiable(normalized);
  }
}
