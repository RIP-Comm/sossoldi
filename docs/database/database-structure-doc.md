---
title: Sossoldi Database Structure
layout: default
nav_order: 5
has_children: true
---


# Sossoldi Database Structure

> **[TODO]**: Why are there no foreign keys?

## Tables

[Database schema](database-schema.md)


### System

1. [**android_metadata**](#android_metadata): Table automatically created by SQLite to manage localization information.
2. [**sqlite_sequence**](#sqlite_sequence): Table automatically created by SQLite to manage the auto-increment index.

### Application

1. [**bankAccount**](#bankaccount): The user's accounts.
2. [**transaction**](#transaction): The user's transactions.
3. [**recurringTransaction**](#recurringtransaction): The configuration of recurring transactions.
4. [**categoryTransaction**](#categorytransaction): The user's categories of transactions.
5. [**budget**](#budget): Manages the budget for specific categories.
6. [**currency**](#currency): Stores information about supported currencies.

---

## Tables details

### android_metadata

`locale` is the only column in this table and stores the locale code (e.g., `en_US`, `it_IT`). This table typically contains a single row with the locale set when the database was first created by the application.

### sqlite_sequence

Stores the last index used for the `id` field of each table. The `name` field contains the table name, and the `seq` field contains the last index value used.

### bankAccount

Stores all types of user accounts, including bank accounts, debit cards, broker accounts and so on.

Fields of `bankAccount`:

- `name`: the name provided by the user for the account. This field is mandatory.
- `symbol` and `color`: manage the information of the icon shown in the app.
- `startingValue`: contains the initial value used to calculate balance of the account.
- `active`: if set to '1' (true), the account is included in the net worth calculation.
- `mainAccount`: if set to '1' (true) is the default account. Only one account can be the main account at any given time.

[Back to Tables](#tables)

### transaction

Stores all the user's transactions for all the accounts. A transaction can be an income, an expanse or a transfer to other accounts.

Fields of `transaction`:

- `date` and `amount`: specify the date of the transaction and the amount involved.
- `type`: enumerates the type of transaction: `'IN'` (income), `'OUT'` (expense) or `'TRSF'` (transfer).
- `note`: an arbitrary description provided by the user for the transaction. Is not mandatory.
- `idCategory`: the ID of the `categoryTransaction` table, indicating the category of the transaction.
- `idBankAccount`: the ID of the `bankAccount` table in which the transaction occurred.
- `idBankAccountTransfer`: if it is a transfer transaction, this field contains the ID of the `bankAccount` table where the transaction is directed.
- `recurring`: if set to `'1'` (true), indicates that the transaction is recurring.
- `idRecurringTransaction`: if `recurring` field is true, contains the ID of the `recurringTransaction` table.

[Back to Tables](#tables)

### recurringTransaction

Stores the configuration of recurring transactions that will be inserted over time in the `transaction` table.

- The `idRecurringTransaction` field in the `transaction` table links to the `recurringTransaction` table.

Fields of `recurringTransaction`:

- `fromDate`, `toDate` and `amount`: indicate the period of validity and the amount of the recurring transaction.
- `note`: an arbitrary description provided by the user for the transaction. this field is mandatory.
   > **[TODO]**: why is this field mandatory? in the `transaction` table, it is nullable.
- `recurrency`: specifies the interval at which the transaction will be repeated: daily, monthly, bi-monthly and so on.
- `idCategory`: the ID of the `categoryTransaction` table, indicating the category of the recurring transaction.
- `idBankAccount`: the ID of the `bankAccount` from which the funds will be deducted for the recurring transaction.
- `lastInsertion`: the last date used to calculate when the next transaction will be inserted into the `transaction` table.

[Back to Tables](#tables)

### categoryTransaction

Stores the user's transaction categories.

- The `idCategory` field in the `transaction` table links to the `categoryTransaction` table.
- The `idCategory` field in the `budget` table links to the `categoryTransaction` table.

> **[TODO]** This tables is linked with `transaction` and `budget`. Why its name is `categoryTransaction`?

Fields of `categoryTransaction`:

- `name`: an arbitrary name provided by the user for the category. This field is mandatory.
- `symbol` and `color`: manage the information of the icon shown in the app.
- `note`: not used
  - > **[TODO]**: should this field be removed?
- `parent`: if it is a sub-category, contains the ID of the parent category.

[Back to Tables](#tables)

### budget

Stores the spending limits for categories.

Fields of `budget`:

- `idCategory`: the ID of the `categoryTransaction` table, indicating the category for the budget.
- `name`: the name of the category. This field is mandatory.
  > **[TODO]**: Why is this field here? It duplicates the `name` field in `categoryTransaction`, and there is already an `idCategory` reference.
- `amountLimit`: the maximum spending limit for the category.
- `active`: if set to `'1'` (true), the budget is active.
> **[TODO]**: The purpose of this field is unclear. It seems to always be active.

[Back to Tables](#tables)

### currency

Stores the currencies that the app supports.

Fields of `currency`:

 - `symbol`: the currency symbol shown alongside the amount of money. For instance: `€`, `$` and so on.
 - `code`: the three-letter alpha code defined by ISO 4217. For instance: `EUR`, `USD`, and so on.
 - `name`: the full name of the currency. For instance: `Euro`, `United States Dollar`, and so on.
 - `mainCurrency`: if set to `'1'` (true), this is the default currency. Only one currency can be the main currency at any given time.

[Back to Tables](#tables)

## Relationship tables

- **bankAccount** → **transaction**: A transaction is associated with a specific bank account.
- **bankAccount** → **transaction** (idBankAccountTransfer): For transfer transactions between accounts.
- **categoryTransaction** → **transaction**: A transaction must belong to a category.
- **transaction** → **recurringTransaction**: A transaction can be generated by recurring transaction configuration.
- **categoryTransaction** → **budget**: Budgets are set for specific categories.
- **currency** No relationships with other tables.


## Additional note

All tables have the fields `createdAt` and `updatedAt` for temporal tracking.
