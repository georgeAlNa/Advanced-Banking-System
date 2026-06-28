# Advanced Banking System with Design Patterns

This repository contains a **modular, extensible banking system** The goal is to implement core banking features while demonstrating **clean architecture** and the use of multiple **design patterns**.
---

## 1. Project Overview
# Advanced Banking System — Distributed Systems Tasks
## توثيق التاسكات المُطبَّقة على المشروع

---

## نظرة عامة على المشروع

**Flutter Banking App** — تطبيق بنكي مبني بـ Clean Architecture:
- `data/`         ← datasources, models, repos
- `logic/`        ← cubits, services, validators
- `presentation/` ← screens, widgets

**State Management:** Cubit + Freezed  
**Network:** Dio + Either (dartz)  
**DI:** GetIt

---

## Task 1 — Fault-Tolerant Client Interceptor (Circuit Breaker)

**الملف:** `lib/core/networking/resilient_fetcher.dart`  
**التاسك الأصلي:** Fault-Tolerant Client Interceptor Service

### المشكلة
عند فشل الاتصال بالسيرفر، كان التطبيق ينتظر 30 ثانية timeout لكل طلب.
المستخدم عالق أمام شاشة تحميل، وإذا أعاد المحاولة يضاعف الضغط على السيرفر المتعطل.

### الحل المُطبَّق

**Circuit Breaker** — آلة حالات بثلاثة أوضاع:

```
CLOSED → OPEN → HALF_OPEN → CLOSED
```

| الوضع | المعنى | السلوك |
|-------|--------|--------|
| CLOSED | الاتصال طبيعي | كل الطلبات تمر |
| OPEN | السيرفر فاشل | إرجاع fallback فوراً |
| HALF_OPEN | اختبار | طلب واحد للتجربة |

**Exponential Backoff + Jitter:**
```
محاولة 0 → ~500ms
محاولة 1 → ~1000ms ± 25%
محاولة 2 → ~2000ms ± 25%
محاولة 3 → ~4000ms ± 25%
```
الـ jitter يمنع "thundering herd": لو 1000 مستخدم يعيدون المحاولة في نفس اللحظة، تتوزع الطلبات عشوائياً بدل أن تضرب السيرفر معاً.

### الملفات المعدَّلة
- `transfer_remote_data_source.dart` ← يستخدم `AppFetchers.transfer.call(...)`
- `login_remote_data_source.dart` ← يستخدم `AppFetchers.auth.call(...)`

### الظهور في الـ UI
`circuit_breaker_banner.dart` — شريط ملون يظهر أسفل الـ tabs تلقائياً:
- 🔴 OPEN: "خدمة التحويل محجوبة مؤقتاً" + عداد تنازلي
- 🟠 HALF_OPEN: "جاري التحقق من الاتصال..."
- يختفي تلقائياً عند عودة الاتصال

---

## Task 2 — JWT Token Verification + RBAC + Secure Storage

**الملفات:**
- `lib/core/security/jwt_service.dart`
- `lib/core/security/rbac.dart`
- `lib/core/security/secure_storage.dart`
- `lib/core/logging/audit_logger.dart`

**التاسك الأصلي:** Decentralized JWT Token Verification Mesh

### المشكلة
1. التوكن كان يُحفظ في `SharedPreferences` — نص عادي مكشوف
2. لم يكن هناك تحقق من صلاحية التوكن قبل استخدامه
3. لم يكن هناك نظام صلاحيات — أي مستخدم يمكنه تحويل أي مبلغ
4. لا يوجد سجل للعمليات الحساسة

### الحل المُطبَّق

**JwtService — التحقق المحلي:**
```dart
// بدون استدعاء السيرفر
final result = JwtService.instance.verify(token);
switch (result) {
  case JwtValid():   // استخدم الـ claims
  case JwtExpired(): // اطلب تجديد التوكن
  case JwtMalformed(): // خطأ في التوكن
}
```

**SecureStorage — تخزين مشفر:**
```
SharedPreferences (قبل) → نص عادي مكشوف
SecureStorage (بعد)     → Keychain/Keystore مشفر بـ AES-256
```

**RBAC — نظام الصلاحيات:**

| الدور | يستطيع |
|-------|--------|
| customer | تحويل عادي (≤ 1000) |
| teller | تحويل + رؤية كل الحسابات |
| manager | تحويل فوق الحد + الموافقة |
| admin | كل شيء + إدارة المستخدمين |

**AuditLogger — سجل العمليات:**
```
🚨 [CRITICAL] permissionDenied user=ACC-001 {"amount": 5000}
⚠️ [WARNING]  transferFailed user=ACC-001 {"reason": "2PC rollback"}
ℹ️ [INFO]     transferApproved user=ACC-001 {"transactionId": "TX-001"}
```

### الملفات المعدَّلة
- `login_cubit.dart` ← يتحقق من التوكن قبل حفظه + يحفظ في SecureStorage
- `transfer_money_cubit.dart` ← يتحقق من RBAC قبل كل تحويل

---

## Task 3 — Distributed Mutex Lock Coordinator

**الملف:** `lib/core/concurrency/transfer_mutex.dart`  
**التاسك الأصلي:** Distributed Mutex Lock Coordinator

### المشكلة
إذا ضغط المستخدم زر "تحويل" مرتين بسرعة، أو الشبكة بطّأت فضغط مجدداً:
```
ضغطة 1 → emit(loading) ...
ضغطة 2 → emit(loading) ...  ← ما في guard كافٍ
→ نفس المبلغ يتحول مرتين ❌
```

### الحل — أربع آليات

**1. Mutex Lock:**
```
ضغطة 1 → يحصل على القفل → يشتغل
ضغطة 2 → MutexLocked    → "عملية تحويل قيد التنفيذ"
```

**2. Fencing Token:**
```
عملية 1 → token 1001
عملية 2 → token 1002
طلب قديم وصل بـ token 1001 → مرفوض (< 1002 الحالي)
```

**3. Idempotency Key:**
```
Key = from + to + amount + الدقيقة الحالية
نفس الـ key خلال 30 ثانية → نجاح هادئ بدون تنفيذ مجدد
```

**4. Lease Expiry:**
```
القفل يتحرر تلقائياً بعد 10 ثوانٍ
حتى لو التطبيق انهار → لا dead lock
```

### الظهور في الـ UI
رسائل SnackBar واضحة حسب كل حالة:
- `MutexLocked` → "عملية تحويل قيد التنفيذ، الرجاء الانتظار"
- `MutexDuplicate` → "تمت العملية بنجاح" (هادئ)
- `MutexFencingRejected` → "انتهت صلاحية هذه العملية"

---

## Task 4 — Two-Phase Commit (2PC)

**الملف:** `lib/core/consistency/two_phase_commit.dart`  
**التاسك الأصلي:** Two-Phase Commit Distributed Locking Transaction

### المشكلة
```
الخطوة 1: خصم 500 من حساب A  ✅
السيرفر ينهار                💥
الخطوة 2: إضافة 500 لحساب B  ❌ لم تتم
النتيجة: 500 ضاعت
```

### الحل — مرحلتان

```
Phase 1 (Prepare/Vote):
  DebitParticipant.prepare()  → هل الرصيد كافٍ؟  → COMMIT / ABORT
  CreditParticipant.prepare() → دائماً           → COMMIT
  AuditLogParticipant.prepare() → دائماً         → COMMIT
  
  إذا كل الأصوات COMMIT:
    → Phase 2: Commit

  إذا أي صوت ABORT:
    → Phase 2: Rollback (بالترتيب المعكوس)

Phase 2A (Global Commit):
  debit() → credit() → auditLog()
  
Phase 2B (Global Rollback):
  auditLog.rollback() → credit.rollback() → debit.rollback()
```

### الظهور في الـ UI
`transaction_log_panel.dart` — يظهر أسفل شاشة التحويل أثناء العملية:

```
🔵 PHASE 1: VOTING                    2PC Log
10:23:45  📋 debit-participant — جاري التحضير...
10:23:45  ✅ debit voted COMMIT
10:23:46  ✅ credit voted COMMIT
10:23:46  🟢 GLOBAL COMMIT
10:23:46  💾 debit committed
10:23:46  💾 credit committed
10:23:46  🏁 COMMITTED ✓
```
يختفي تلقائياً بعد ثانيتين من الانتهاء.

---

## كيف تتكامل التاسكات مع بعضها

```
المستخدم يضغط "تحويل"
        ↓
TransferMoneyCubit.submit()
        ↓
RBAC.can(permission)          [Task 2] هل للمستخدم صلاحية؟
        ↓
TransferMutex.runExclusive()  [Task 3] منع double-submission
        ↓
ApprovalChain.handle()        [موجود مسبقاً] validate البيانات
        ↓
TwoPhaseCoordinator.execute() [Task 4] atomicity كاملة
  ├── Phase 1: Prepare & Vote
  └── Phase 2: Commit or Rollback
        ↓
AppFetchers.transfer.call()   [Task 1] Circuit Breaker على كل HTTP call
        ↓
AuditLogger.log()             [Task 2] تسجيل النتيجة
```

---

## الملفات الجديدة (مُضافة للمشروع)

| الملف | التاسك |
|-------|--------|
| `lib/core/networking/resilient_fetcher.dart` | Task 1 |
| `lib/core/security/jwt_service.dart` | Task 2 |
| `lib/core/security/secure_storage.dart` | Task 2 |
| `lib/core/security/rbac.dart` | Task 2 |
| `lib/core/logging/audit_logger.dart` | Task 2 |
| `lib/core/concurrency/transfer_mutex.dart` | Task 3 |
| `lib/core/consistency/two_phase_commit.dart` | Task 4 |
| `lib/features/transfer_money/presentation/widgets/circuit_breaker_banner.dart` | Task 1 UI |
| `lib/features/transfer_money/presentation/widgets/transaction_log_panel.dart` | Task 4 UI |

## الملفات المعدَّلة

| الملف | التعديل |
|-------|---------|
| `transfer_money_cubit.dart` | Task 1+2+3+4 |
| `login_cubit.dart` | Task 2 |
| `login_remote_data_source.dart` | Task 1 |
| `transfer_remote_data_source.dart` | Task 1+4 |
| `transfer_repo_impl.dart` | Task 4 |
| `transfer_screen.dart` | Task 1 UI + Task 4 UI |

---

## الـ Dependency الجديدة

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.2.2
```

---

*توثيق مشروع Advanced Banking System — Distributed Systems Implementation*
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
