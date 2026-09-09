import AppIntents
import Foundation
import SQLite3

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
    let parsedAmount = try WalletTransactionAmountParser.parse(amount)
    try WalletTransactionStore.insert(
      amount: abs(parsedAmount),
      type: parsedAmount < 0 ? "IN" : "OUT",
      merchant: merchant.trimmingCharacters(in: .whitespacesAndNewlines)
    )
    return .result()
  }
}

private enum WalletTransactionAmountParser {
  static func parse(_ value: String) throws -> Double {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    for style in [NumberFormatter.Style.currency, .decimal] {
      let formatter = NumberFormatter()
      formatter.locale = .autoupdatingCurrent
      formatter.numberStyle = style
      formatter.isLenient = true
      if let amount = formatter.number(from: trimmed)?.doubleValue, amount.isFinite {
        return amount
      }
    }

    if let amount = Double(normalizedDecimalString(from: trimmed)), amount.isFinite {
      return amount
    }

    throw WalletTransactionStoreError.invalidAmount(value)
  }

  private static func normalizedDecimalString(from value: String) -> String {
    let filtered = value
      .unicodeScalars
      .filter { CharacterSet(charactersIn: "0123456789,.-").contains($0) }
      .map(String.init)
      .joined()

    guard let lastDot = filtered.lastIndex(of: ".") else {
      return filtered.replacingOccurrences(of: ",", with: ".")
    }

    guard let lastComma = filtered.lastIndex(of: ",") else {
      return filtered
    }

    let decimalSeparator = lastDot > lastComma ? "." : ","
    let groupingSeparator = decimalSeparator == "." ? "," : "."

    return filtered
      .replacingOccurrences(of: groupingSeparator, with: "")
      .replacingOccurrences(of: decimalSeparator, with: ".")
  }
}

private enum WalletTransactionStore {
  static func insert(amount: Double, type: String, merchant: String) throws {
    let databaseURL = try sossoldiDatabaseURL()
    guard FileManager.default.fileExists(atPath: databaseURL.path) else {
      throw WalletTransactionStoreError.databaseNotFound
    }

    var database: OpaquePointer?
    guard sqlite3_open_v2(databaseURL.path, &database, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK else {
      let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "Unknown SQLite error"
      sqlite3_close(database)
      throw WalletTransactionStoreError.openFailed(message)
    }
    defer { sqlite3_close(database) }

    let now = iso8601Now()
    let note = merchant.isEmpty ? "Apple Pay transaction" : merchant
    let sql = """
      INSERT INTO "transaction"
        (date, amount, type, note, idCategory, idBankAccount, idBankAccountTransfer, recurring, idRecurringTransaction, createdAt, updatedAt)
      VALUES
        (?, ?, ?, ?, NULL, 0, NULL, 0, NULL, ?, ?)
      """

    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
      let message = String(cString: sqlite3_errmsg(database))
      throw WalletTransactionStoreError.prepareFailed(message)
    }
    defer { sqlite3_finalize(statement) }

    bindText(now, to: statement, at: 1)
    sqlite3_bind_double(statement, 2, amount)
    bindText(type, to: statement, at: 3)
    bindText(note, to: statement, at: 4)
    bindText(now, to: statement, at: 5)
    bindText(now, to: statement, at: 6)

    guard sqlite3_step(statement) == SQLITE_DONE else {
      let message = String(cString: sqlite3_errmsg(database))
      throw WalletTransactionStoreError.insertFailed(message)
    }
  }

  private static func sossoldiDatabaseURL() throws -> URL {
    let documentsURL = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: false
    )
    return documentsURL.appendingPathComponent("sossoldi.db")
  }

  private static func iso8601Now() -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: Date())
  }

  private static func bindText(_ value: String, to statement: OpaquePointer?, at index: Int32) {
    let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    sqlite3_bind_text(statement, index, value, -1, transient)
  }
}

private enum WalletTransactionStoreError: LocalizedError {
  case invalidAmount(String)
  case databaseNotFound
  case openFailed(String)
  case prepareFailed(String)
  case insertFailed(String)

  var errorDescription: String? {
    switch self {
    case .invalidAmount(let value):
      return "Unable to read the Wallet transaction amount: \(value)"
    case .databaseNotFound:
      return "Open Sossoldi once before running this shortcut."
    case .openFailed(let message):
      return "Unable to open the Sossoldi database: \(message)"
    case .prepareFailed(let message):
      return "Unable to prepare the Wallet transaction insert: \(message)"
    case .insertFailed(let message):
      return "Unable to add the Wallet transaction: \(message)"
    }
  }
}
