---
title: Database schema
layout: default
nav_order: 6
parent: Sossoldi Database Structure
---

```mermaid
erDiagram
    bankAccount ||--o{ transaction : has
    bankAccount ||--o{ transaction : transfers_to
    categoryTransaction ||--o{ transaction : categorizes
    transaction ||--o{ recurringTransaction : triggers
    categoryTransaction ||--o{ budget : categorizes

    bankAccount {
        int id PK "AUTO_INCREMENT"
        string name "NOT NULL"
        string symbol "NOT NULL"
        int color "NOT NULL"
        float startingValue "NOT NULL"
        boolean active "NOT NULL"
        boolean mainAccount "NOT NULL"
        datetime createdAt "NOT NULL"
        datetime updatedAt "NOT NULL"
    }

    transaction {
        int id PK "AUTO_INCREMENT"
        datetime date
        float amount "NOT NULL"
        int type "NOT NULL"
        string note
        int idCategory FK
        int idBankAccount FK "NOT NULL"
        int idBankAccountTransfer FK
        boolean recurring "NOT NULL"
        int idRecurringTransaction FK
        datetime createdAt "NOT NULL"
        datetime updatedAt "NOT NULL"
    }

    recurringTransaction {
        int id PK "AUTO_INCREMENT"
        datetime fromDate "NOT NULL"
        datetime toDate
        float amount "NOT NULL"
        string note "NOT NULL"
        string recurrency "NOT NULL"
        int idCategory FK "NOT NULL"
        int idBankAccount FK "NOT NULL"
        datetime lastInsertion
        datetime createdAt "NOT NULL"
        datetime updatedAt "NOT NULL"
    }

    categoryTransaction {
        int id PK "AUTO_INCREMENT"
        string name "NOT NULL"
        string symbol "NOT NULL"
        int color "NOT NULL"
        string note
        int parent FK
        datetime createdAt "NOT NULL"
        datetime updatedAt "NOT NULL"
    }

    budget {
        int id PK "AUTO_INCREMENT"
        int idCategory FK "NOT NULL"
        string name "NOT NULL"
        float amountLimit "NOT NULL"
        boolean active "NOT NULL"
        datetime createdAt "NOT NULL"
        datetime updatedAt "NOT NULL"
    }

```

```mermaid
erDiagram
    currency

    currency {
        int id PK "AUTO_INCREMENT"
        string symbol "NOT NULL"
        string code "NOT NULL"
        string name "NOT NULL"
        boolean mainCurrency "NOT NULL"
    }

```
