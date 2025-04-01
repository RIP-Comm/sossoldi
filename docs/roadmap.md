---
title: Roadmap
layout: default
nav_order: 3
---

# Roadmap (WIP)

Sossoldi is an open-source project driven by a singular ambition – **to empower individuals in making deliberate financial choices**. Unlike conventional tools, this project currently operates without dates, reflecting its early-stage development as a dynamic open-source endeavor. It is designed as a mobile-first application, allowing users to easily track their net worth anywhere without the need for a PC.
By following this roadmap, Sossoldi will evolve from a basic income/expense tracker to a comprehensive financial management tool, offering users a complete view of their finances.

## Phase 1: Income/Expense Tracking + Budgeting (Beta)

**Objective:** Build a robust foundation for users to track their income, expenses, and create basic budgets.

### 1. User Interface (UI) Design and Wireframing

- Design a clean and user-friendly interface for easy navigation.
- Create wireframes for essential screens such as dashboard, income/expense tracking, budgeting and add transaction
- Use graphs and data to make it easier for a user to understand how they are doing with their financials

### 2. Implement expense tracking with customizable categories.

- Allow users to input one-time and recurring expenses.
- Enable the user to create custom categories or subcategories 

### 3. Budgeting

- Introduce basic budgeting features to help users set spending limits.
- Provide notifications/alerts when users approach or exceed budget limits.

### 4. User Feedback and Iteration

- Launch a beta version for limited user testing.
- Gather user feedback and make necessary improvements.

## Phase 2: Data Management & Usability Improvements

**Objective:** Enhancing import/export, making data handling easier.

### 1. Improve Import/Export Feature (Better CSV Template)

Currently, the app exports all data in a raw format, making it difficult for users to read or modify. This update will introduce a **cleaner, more structured template** with:
- Clear column headers.
- Improved formatting for dates, amounts, and categories.
- More intuitive organization that makes it easier for users to analyze or edit before importing.

### 2. Add Partial Import (Importing Transactions Without Overwriting)

Right now, importing a new dataset completely replaces the old one, causing **data loss concerns**. This feature will allow users to:
- Import **new transactions without deleting existing ones**.
- Choose between full replacement or **adding new data**.

### 3. Add Support for Importing from Other Apps (Structured Data from Banks and Other Apps)

Many users already track their finances in **bank apps or other budgeting tools**. This feature will:
- Support structured imports from **bank statements and financial apps**.
- Identify key fields (date, amount, category) to **auto-map data**.
- Allow **manual corrections** before finalizing import.


### 4. Hidden Mode (Privacy Shield for Sensitive Data)

Hidden Mode is designed to **protect financial data from prying eyes** when using the app in public. With a simple **gesture or toggle**, users can:
- **Blur or hide balances and transactions** while keeping the app functional.
- **Quickly toggle visibility** with a tap

### 5. Backup Data in Cloud (Opt-In Feature)

To **prevent data loss** and allow multi-device access, this feature will:
- Let users **opt-in** to automatic backups.
- Allow restoring previous backups in case of errors or accidental deletions.


### 6. Add Default Categories (Pre-Set Categories + Onboarding Improvements)

Currently, users must manually create categories. This feature will:
- Offer a **set of common categories** (e.g., Salary, Rent, Groceries).
- Integrate with onboarding, letting users **customize their starting categories**.
- Provide suggestions based on spending patterns.


### 7. Subcategories (Nested Categories for Better Tracking)
Users want more detailed expense tracking. This feature will:
- Allow **categories to have subcategories** (e.g., "Food" → "Groceries" / "Dining Out").
- Improve financial reports, **breaking down spending more accurately**.
- Support custom subcategories based on user preferences.

## Phase 2: Multi-Currency & Investment Tracking

**Objective:** Expanding the scope of financial tracking beyond basic budgeting.

### 1. Multicurrency Tracking (Support Multiple Currencies in Accounts/Transactions)
Currently, the app assumes a **single currency**, which limits global users. This update will:
- Allow **multiple currencies per account**.
- Automatically fetch **exchange rates** for conversions.
- Show **total net worth in a base currency** while tracking foreign transactions.


### 2. Investments Tracking (Stocks, ETFs, Bonds, Crypto as Initial Focus)
Users want to track **investments alongside regular finances**. This feature will:
- Support **stocks, ETFs, bonds, and cryptocurrencies**.
- Let users **manually input holdings**.
- Display **profit/loss, portfolio allocation, and performance over time**.

## Phase 3: Advanced Budgeting & Financial Insights

**Objective:** Expanding financial tracking tools.

### 1. Annual Budgets (Budget Tracking for a Full Year, Not Just Monthly)
Currently, budgets reset **month by month**, making long-term planning difficult. This update will:
- Allow users to set **yearly budgets** alongside monthly ones.
- Compare past years to **analyze spending trends**.

### 2. Total Net Worth Tracking (Revamp the Graph Page for a Better Financial Overview)
Right now, the **net worth view is basic**. This revamp will:
- Focus on **net worth growth over time**, integrating assets, liabilities, and investments.
- Offer a **clearer graph with breakdowns by category** (cash, investments).
- Allow users to **filter time periods** (e.g., past 6 months, 5 years).


### 3. Forecasting (Basic Financial Planning & Projections)
Users want tools to **predict future financial health**. This will start with:
- A **simple forecast based on past spending trends**.
- Ability to add **planned expenses/incomes to project future cash flow**.
- Potential expansion into **advanced simulations (e.g., Monte Carlo analysis)**.

## Phase 4: Automation & Smart Features

**Objective:** Making financial tracking seamless and more intelligent.

### 1. OpenBanking API or Alternatives (Automated Bank Transaction Tracking)
To **limit manual entry**, this feature will:
- Integrate with **bank APIs** (where available) to fetch transactions automatically.


### 2. Google Sheets Integration (Export Financial Data for Deeper Analysis)
For users who prefer **custom analysis**, this feature will:
- Allow **automatic syncing of financial data to Google Sheets**.
- Let users build **custom dashboards with real-time updates**.
- Support **scheduled exports** for better tracking.


### 3. Financial Literacy Tools (Tooltips, Guides, and Recommended Resources for Users)
Many users lack **financial knowledge**. This feature will:
- Provide **in-app explanations for key financial terms**.
- Offer **links to educational resources** (blogs, books, videos).
- Suggest **personal finance best practices** based on user spending patterns.

## Phase 5: Collaboration & Sharing

**Objective:** Enabling shared financial tracking and multi-user features.

### 1. Shared Account (Allow Multiple Users to Collaborate on Finances)
Ideal for **families, couples, or shared expenses**, this feature will:
- Allow users to **invite others** to access the same financial data.
- Set **custom permissions** (e.g., view-only, full access).
- Support **shared budgets and split transactions**.
