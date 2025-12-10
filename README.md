# Advanced Banking System with Design Patterns

This repository contains a **modular, extensible banking system** The goal is to implement core banking features while demonstrating **clean architecture** and the use of multiple **design patterns**.
---

## 1. Project Overview

The system provides:

- Multiple account types (savings, checking, loan, investment)
- Core banking operations (deposits, withdrawals, transfers)
- Transaction history and audit logging
- Customer notifications and basic support
- Administrative tools (RBAC, monitoring, reports)

Focus is on **clean architecture, design patterns, and code quality** rather than maximum number of features.

---

## 2. Main Features

### Account Management
- Create, update, and close accounts  
- Support multiple account types  
- Account hierarchy (e.g., parent + sub-accounts)  
- Account states: active, frozen, suspended, closed  

### Transaction Processing
- Deposits, withdrawals, transfers  
- Validation & authorization flow  
- Scheduled/recurring payments  
- Transaction history & audit logs  

### Customer Services
- Real-time notifications for account activity  
- Simple ticket/inquiry management  
- Basic personalized recommendations  

### Administration
- Role-Based Access Control: Customer, Teller, Manager, Admin  
- Monitoring dashboard  
- Reports (daily transactions, account summaries, audit logs)  

---

## 3. Non-Functional Requirements

- **Extensibility:** Easy to add new account types and features  
- **Maintainability:** Clear separation of concerns, SOLID principles  
- **Performance:** Handle 100+ concurrent transactions  
- **Security:** Authentication, authorization, and protection from common web attacks  
- **Testability:** High unit-test coverage with mocked external dependencies  

---

## 4. Design Patterns

The project demonstrates at least **6 design patterns** including:

**Structural**
- Composite – hierarchical account structures  
- Adapter – integration with external/legacy payment systems  
- Decorator – optional account features (e.g., overdraft, insurance)  
- Facade (optional) – simplified API over complex transaction logic  

**Behavioral**
- Observer – notification system (email/SMS/in-app)  
- Strategy – different interest calculation algorithms  
- Chain of Responsibility – transaction approval workflow  
- State (optional) – account state transitions and behaviors  

---
