import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/attendance_model.dart';
import '../../core/theme/app_colors_extension.dart';

class AppAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double radius;
  final AttendanceStatus? status;
  final bool showStatusDot;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final Border? border;

  const AppAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 24,
    this.status,
    this.showStatusDot = false,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.border,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _statusColor(BuildContext context) {
    switch (status) {
      case AttendanceStatus.onTime:
        return AppColors.onTime;
      case AttendanceStatus.late:
        return AppColors.late;
      case AttendanceStatus.absent:
        return AppColors.absent;
      case AttendanceStatus.onLeave:
        return AppColors.onLeave;
      default:
        return context.colors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;
    final double computedFontSize = fontSize ?? (radius * 0.75);

    Widget avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? context.colors.primary,
        border: border ?? Border.all(color: Colors.white.withAlpha(200), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null && photoUrl!.trim().isNotEmpty
          ? (photoUrl!.startsWith('http://') || photoUrl!.startsWith('https://')
              ? Image.network(
                  photoUrl!.trim(),
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (context, error, stackTrace) => _buildInitialsFallback(context, computedFontSize),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: radius * 0.8,
                        height: radius * 0.8,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      ),
                    );
                  },
                )
              : Image.asset(
                  photoUrl!.trim(),
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (context, error, stackTrace) => _buildInitialsFallback(context, computedFontSize),
                ))
          : _buildInitialsFallback(context, computedFontSize),
    );

    if (!showStatusDot && status == null) {
      return avatarContent;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatarContent,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: radius * 0.6,
            height: radius * 0.6,
            decoration: BoxDecoration(
              color: _statusColor(context),
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.bgCard, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsFallback(BuildContext context, double size) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor ?? context.colors.primary,
            (backgroundColor ?? context.colors.primary).withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

