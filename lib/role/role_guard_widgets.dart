import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/role/role_controller.dart';

/// Mixin to provide role-based access control to widgets
mixin RoleGuardMixin<T extends StatefulWidget> on State<T> {
  RoleController get roleController => Get.find<RoleController>();

  /// Check if current user has specific permission
  bool hasPermission(String permission) {
    return roleController.hasPermission(permission);
  }

  /// Check if current user is admin
  bool get isAdmin => roleController.isAdmin;

  /// Check if current user has all specified permissions
  bool hasAllPermissions(List<String> permissions) {
    return roleController.hasAllPermissions(permissions);
  }

  /// Check if current user has any of the specified permissions
  bool hasAnyPermission(List<String> permissions) {
    return roleController.hasAnyPermission(permissions);
  }
}

/// Widget that conditionally shows content based on permissions
class PermissionGuard extends StatelessWidget {
  final String? permission;
  final List<String>? permissions;
  final bool requireAll;
  final bool adminOnly;
  final Widget child;
  final Widget? fallback;
  final bool showFallbackOnNoPermission;

  const PermissionGuard({
    super.key,
    this.permission,
    this.permissions,
    this.requireAll = true,
    this.adminOnly = false,
    required this.child,
    this.fallback,
    this.showFallbackOnNoPermission = false,
  }) : assert(
          (permission != null) ^ (permissions != null) ^ adminOnly,
          'Either permission, permissions, or adminOnly must be specified, but not multiple',
        );

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleController>(
      builder: (roleController) {
        bool hasAccess = false;

        if (adminOnly) {
          hasAccess = roleController.isAdmin;
        } else if (permission != null) {
          hasAccess = roleController.hasPermission(permission!);
        } else if (permissions != null) {
          hasAccess = requireAll
              ? roleController.hasAllPermissions(permissions!)
              : roleController.hasAnyPermission(permissions!);
        }

        if (hasAccess) {
          return child;
        } else if (showFallbackOnNoPermission && fallback != null) {
          return fallback!;
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Widget that shows different content based on user role
class RoleBasedWidget extends StatelessWidget {
  final Widget? adminWidget;
  final Widget? userWidget;
  final Widget? defaultWidget;

  const RoleBasedWidget({
    super.key,
    this.adminWidget,
    this.userWidget,
    this.defaultWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleController>(
      builder: (roleController) {
        if (roleController.isAdmin && adminWidget != null) {
          return adminWidget!;
        } else if (!roleController.isAdmin && userWidget != null) {
          return userWidget!;
        } else if (defaultWidget != null) {
          return defaultWidget!;
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// AppBar with role-based actions
class RoleBasedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? userActions;
  final List<Widget>? adminActions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final TextStyle? titleStyle;

  const RoleBasedAppBar({
    super.key,
    required this.title,
    this.userActions,
    this.adminActions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleController>(
      builder: (roleController) {
        List<Widget>? actions;
        
        if (roleController.isAdmin && adminActions != null) {
          actions = adminActions;
        } else if (!roleController.isAdmin && userActions != null) {
          actions = userActions;
        }

        return AppBar(
          title: Text(
            title,
            style: titleStyle,
          ),
          leading: leading,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: backgroundColor,
          actions: actions,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Floating Action Button with permission guard
class PermissionFloatingActionButton extends StatelessWidget {
  final String? permission;
  final List<String>? permissions;
  final bool requireAll;
  final bool adminOnly;
  final VoidCallback onPressed;
  final Widget child;
  final String? tooltip;
  final Color? backgroundColor;

  const PermissionFloatingActionButton({
    super.key,
    this.permission,
    this.permissions,
    this.requireAll = true,
    this.adminOnly = false,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.backgroundColor,
  }) : assert(
          (permission != null) ^ (permissions != null) ^ adminOnly,
          'Either permission, permissions, or adminOnly must be specified, but not multiple',
        );

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permission: permission,
      permissions: permissions,
      requireAll: requireAll,
      adminOnly: adminOnly,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }
}

/// List tile with role-based visibility
class RoleBasedListTile extends StatelessWidget {
  final String? permission;
  final List<String>? permissions;
  final bool requireAll;
  final bool adminOnly;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  const RoleBasedListTile({
    super.key,
    this.permission,
    this.permissions,
    this.requireAll = true,
    this.adminOnly = false,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
  }) : assert(
          (permission != null) ^ (permissions != null) ^ adminOnly,
          'Either permission, permissions, or adminOnly must be specified, but not multiple',
        );

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permission: permission,
      permissions: permissions,
      requireAll: requireAll,
      adminOnly: adminOnly,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        enabled: enabled,
      ),
    );
  }
}

/// Button with permission guard
class PermissionButton extends StatelessWidget {
  final String? permission;
  final List<String>? permissions;
  final bool requireAll;
  final bool adminOnly;
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  const PermissionButton({
    super.key,
    this.permission,
    this.permissions,
    this.requireAll = true,
    this.adminOnly = false,
    this.onPressed,
    required this.child,
    this.style,
  }) : assert(
          (permission != null) ^ (permissions != null) ^ adminOnly,
          'Either permission, permissions, or adminOnly must be specified, but not multiple',
        );

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      permission: permission,
      permissions: permissions,
      requireAll: requireAll,
      adminOnly: adminOnly,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: child,
      ),
    );
  }
}

/// Role indicator badge
class RoleBadge extends StatelessWidget {
  final String role;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const RoleBadge({
    super.key,
    required this.role,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = backgroundColor ?? _getDefaultBackgroundColor(role);
    Color txtColor = textColor ?? _getDefaultTextColor(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: txtColor,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getDefaultBackgroundColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red.shade100;
      case 'user':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getDefaultTextColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red.shade800;
      case 'user':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}