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
    try WalletTransactionStore.insert(
      amount: try WalletTransactionAmountParser.parse(amount),
      merchant: merchant.trimmingCharacters(in: .whitespacesAndNewlines)
    )
    return .result()
  }
}

private enum WalletTransactionAmountParser {
  static func parse(_ value: String) throws -> Double {
    let allowedCharacters = CharacterSet(charactersIn: "0123456789,.-")
    let filtered = value.unicodeScalars
      .filter { allowedCharacters.contains($0) }
      .map(String.init)
      .joined()
      .replacingOccurrences(of: ",", with: ".")

    let decimalSeparatorCount = filtered.filter { $0 == "." }.count
    let normalized = decimalSeparatorCount > 1
      ? removeThousandsSeparators(from: filtered)
      : filtered

    guard let amount = Double(normalized), amount.isFinite else {
      throw WalletTransactionStoreError.invalidAmount(value)
    }

    return abs(amount)
  }

  private static func removeThousandsSeparators(from value: String) -> String {
    guard let lastSeparator = value.lastIndex(of: ".") else {
      return value
    }

    return value.enumerated().compactMap { offset, character in
      let index = value.index(value.startIndex, offsetBy: offset)
      return character == "." && index != lastSeparator ? nil : character
    }.map(String.init).joined()
  }
}

private enum WalletTransactionStore {
  static func insert(amount: Double, merchant: String) throws {
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
        (?, ?, 'OUT', ?, NULL, 0, NULL, 0, NULL, ?, ?)
      """

    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
      let message = String(cString: sqlite3_errmsg(database))
      throw WalletTransactionStoreError.prepareFailed(message)
    }
    defer { sqlite3_finalize(statement) }

    bindText(now, to: statement, at: 1)
    sqlite3_bind_double(statement, 2, amount)
    bindText(note, to: statement, at: 3)
    bindText(now, to: statement, at: 4)
    bindText(now, to: statement, at: 5)

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
