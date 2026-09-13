import AppIntents
import Foundation

@available(iOS 16.0, *)
struct AddWalletTransactionIntent: AppIntent {
  static var title: LocalizedStringResource = "Add Wallet Transaction"
  static var description = IntentDescription(
    "Adds an uncategorized Apple Wallet transaction to Sossoldi."
  )
  static var openAppWhenRun = false

  @Parameter(title: "Amount")
  var amount: String

  @Parameter(title: "Merchant")
  var merchant: String

  @Parameter(title: "Card")
  var card: String

  init() {}

  init(amount: String, merchant: String, card: String) {
    self.amount = amount
    self.merchant = merchant
    self.card = card
  }

  func perform() async throws -> some IntentResult {
    _ = card
    try PendingWalletTransactionStore.append(
      amount: amount,
      merchant: merchant.trimmingCharacters(in: .whitespacesAndNewlines),
      card: card.trimmingCharacters(in: .whitespacesAndNewlines)
    )
    return .result()
  }
}

private struct PendingWalletTransaction: Encodable {
  let amount: String
  let merchant: String
  let card: String
  let createdAt: String
}

private enum PendingWalletTransactionStore {
  private static let fileName = "pending_wallet_transactions.jsonl"

  static func append(amount: String, merchant: String, card: String) throws {
    let pendingTransaction = PendingWalletTransaction(
      amount: amount,
      merchant: merchant,
      card: card,
      createdAt: iso8601Now()
    )

    let data = try JSONEncoder().encode(pendingTransaction) + Data("\n".utf8)
    let url = try pendingTransactionsURL()

    if FileManager.default.fileExists(atPath: url.path) {
      let handle = try FileHandle(forWritingTo: url)
      try handle.seekToEnd()
      try handle.write(contentsOf: data)
      try handle.close()
    } else {
      try data.write(to: url, options: .atomic)
    }
  }

  private static func pendingTransactionsURL() throws -> URL {
    let documentsURL = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: false
    )
    return documentsURL.appendingPathComponent(fileName)
  }

  private static func iso8601Now() -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: Date())
  }
}
