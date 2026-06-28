 
// ─────────────────────────────────────────────────────────────────────────────
// FILE 3: rbac.dart — Role-Based Access Control
//
// يقرأ الـ role من التوكن مباشرة ويتحقق من الصلاحيات محلياً.
// هذا يعني: لا استدعاء للسيرفر لكل عملية تحقق من الصلاحية.
// ─────────────────────────────────────────────────────────────────────────────
 
import 'package:advanced_banking_system/core/security/jwt_service.dart';
import 'package:advanced_banking_system/core/security/secure_storage.dart';

/// الأدوار المتاحة في النظام بترتيب تصاعدي للصلاحيات
enum UserRole {
  customer, // عميل عادي
  teller,   // موظف صراف
  manager,  // مدير الفرع
  admin,    // مدير النظام
}
 
/// الصلاحيات التفصيلية
enum Permission {
  viewOwnAccounts,
  viewAllAccounts,     // teller وما فوق
  transferOwnAccounts,
  transferOtherBanks,
  transferAboveLimit,  // manager وما فوق (> 1000)
  approveTransfer,     // manager وما فوق
  viewAuditLogs,       // admin فقط
  manageUsers,         // admin فقط
}
 
/// مصفوفة الصلاحيات — كل دور يحصل على مجموعة محددة من الصلاحيات
const _matrix = <UserRole, Set<Permission>>{
  UserRole.customer: {
    Permission.viewOwnAccounts,
    Permission.transferOwnAccounts,
    Permission.transferOtherBanks,
  },
  UserRole.teller: {
    Permission.viewOwnAccounts,
    Permission.viewAllAccounts,
    Permission.transferOwnAccounts,
    Permission.transferOtherBanks,
  },
  UserRole.manager: {
    Permission.viewOwnAccounts,
    Permission.viewAllAccounts,
    Permission.transferOwnAccounts,
    Permission.transferOtherBanks,
    Permission.transferAboveLimit,
    Permission.approveTransfer,
  },
  UserRole.admin: {
    Permission.viewOwnAccounts,
    Permission.viewAllAccounts,
    Permission.transferOwnAccounts,
    Permission.transferOtherBanks,
    Permission.transferAboveLimit,
    Permission.approveTransfer,
    Permission.viewAuditLogs,
    Permission.manageUsers,
  },
};
 
class Rbac {
  Rbac._();
  static final Rbac instance = Rbac._();
 
  final _jwt = JwtService.instance;
  final _storage = SecureStorage.instance;
 
  /// الدور الحالي مستخرج من التوكن المحفوظ
  Future<UserRole?> currentRole() async {
    final token = await _storage.readToken();
    if (token == null) return null;
    final result = _jwt.verify(token);
    if (result is! JwtValid) return null;
    return _parseRole(result.claims.role);
  }
 
  /// هل للمستخدم الحالي هذه الصلاحية؟
  Future<bool> can(Permission permission) async {
    final role = await currentRole();
    if (role == null) return false;
    return _matrix[role]?.contains(permission) ?? false;
  }
 
  /// هل للمستخدم الحالي كل هذه الصلاحيات؟
  Future<bool> canAll(List<Permission> permissions) async {
    final role = await currentRole();
    if (role == null) return false;
    final allowed = _matrix[role] ?? {};
    return permissions.every(allowed.contains);
  }
 
  /// كل صلاحيات المستخدم الحالي
  Future<Set<Permission>> myPermissions() async {
    final role = await currentRole();
    if (role == null) return {};
    return _matrix[role] ?? {};
  }
 
  UserRole? _parseRole(String? raw) {
    if (raw == null) return null;
    return UserRole.values.where((r) => r.name == raw.toLowerCase()).firstOrNull;
  }
}
 