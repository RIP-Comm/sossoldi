// dart format width=400

class BankAuthorizationCallback {
  final String? code;
  final String? state;
  final String? error;
  final String? errorDescription;

  const BankAuthorizationCallback({this.code, this.state, this.error, this.errorDescription});

  bool get isSuccess => code != null && error == null;
}

enum BankCallbackDisposition { terminal, retryable }
