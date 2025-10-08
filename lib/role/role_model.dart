/// Role model to define user roles and permissions
class UserRole {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// User role assignment model
class UserRoleAssignment {
  final String userId;
  final String userEmail;
  final String roleName;
  final String assignedBy;
  final DateTime assignedAt;
  final bool isActive;

  UserRoleAssignment({
    required this.userId,
    required this.userEmail,
    required this.roleName,
    required this.assignedBy,
    required this.assignedAt,
    this.isActive = true,
  });

  factory UserRoleAssignment.fromJson(Map<String, dynamic> json) {
    return UserRoleAssignment(
      userId: json['user_id'] ?? '',
      userEmail: json['user_email'] ?? '',
      roleName: json['role_name'] ?? '',
      assignedBy: json['assigned_by'] ?? '',
      assignedAt: DateTime.parse(json['assigned_at'] ?? DateTime.now().toIso8601String()),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_email': userEmail,
      'role_name': roleName,
      'assigned_by': assignedBy,
      'assigned_at': assignedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}

/// Default roles and permissions
class DefaultRoles {
  static const String userRole = 'user';
  static const String adminRole = 'admin';

  static UserRole get user => UserRole(
    id: 'user_role',
    name: userRole,
    description: 'Standard user with basic permissions',
    permissions: [
      'view_products',
      'add_to_cart',
      'place_orders',
      'view_own_orders',
      'manage_own_profile',
      'add_to_favorites',
      'write_reviews',
      'personalize_products',
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static UserRole get admin => UserRole(
    id: 'admin_role',
    name: adminRole,
    description: 'Administrator with full permissions',
    permissions: [
      // User permissions
      'view_products',
      'add_to_cart',
      'place_orders',
      'view_own_orders',
      'manage_own_profile',
      'add_to_favorites',
      'write_reviews',
      'personalize_products',
      // Admin permissions
      'manage_users',
      'view_all_orders',
      'manage_orders',
      'manage_products',
      'manage_categories',
      'view_analytics',
      'manage_concierge',
      'manage_deliveries',
      'moderate_reviews',
      'manage_user_roles',
      'view_admin_dashboard',
    ],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  static List<UserRole> get allRoles => [user, admin];
}