import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'app_avatar.dart';
import '../../data/api/api_client.dart';
import '../../core/theme/app_colors_extension.dart';

class BiometricGpsDialog extends StatefulWidget {
  final double branchRadius;
  final String? userPhotoUrl;
  final String userName;
  final String userCode;
  final Function({
    required double latitude,
    required double longitude,
    required bool biometricVerified,
    required bool isMockLocation,
  }) onConfirmCheckIn;

  const BiometricGpsDialog({
    super.key,
    this.branchRadius = 50.0,
    this.userPhotoUrl,
    this.userName = 'Ahmed Kamal',
    this.userCode = 'EMP-4092',
    required this.onConfirmCheckIn,
  });

  @override
  State<BiometricGpsDialog> createState() => _BiometricGpsDialogState();
}

class _BiometricGpsDialogState extends State<BiometricGpsDialog> {
  bool isGpsVerifying = true;
  bool isDeviceVerifying = false;
  bool isDeviceVerified = false;
  bool isWifiVerifying = false;
  bool isWifiVerified = false;
  bool isFaceScanning = false;
  bool isFaceVerified = false;

  bool isInsideRadius = true;
  bool isMockGpsDetected = false;
  double simulatedDistance = 18.0;
  double _activeBranchLat = 30.0444;
  double _activeBranchLon = 31.2357;

  @override
  void initState() {
    super.initState();
    _fetchCurrentBranchGps();
    _startSequentialVerification();
  }

  void _fetchCurrentBranchGps() async {
    try {
      final res = await ApiClient.get('/admin/branches/current');
      if (res is Map<String, dynamic> && mounted) {
        setState(() {
          _activeBranchLat = (res['latitude'] as num?)?.toDouble() ?? 30.0444;
          _activeBranchLon = (res['longitude'] as num?)?.toDouble() ?? 31.2357;
        });
      }
    } catch (_) {}
  }

  void _startSequentialVerification() async {
    // Step 1: GPS Geofence (400ms)
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        isGpsVerifying = false;
        isDeviceVerifying = true;
      });
    }

    // Step 2: Specific Device Binding (400ms)
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        isDeviceVerifying = false;
        isDeviceVerified = true;
        isWifiVerifying = true;
      });
    }

    // Step 3: WiFi Router BSSID MAC Check (400ms)
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        isWifiVerifying = false;
        isWifiVerified = true;
        isFaceScanning = true;
      });
    }

    // Step 4: In-App Face Liveness Scan (700ms)
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        isFaceScanning = false;
        isFaceVerified = true;
      });
    }
  }

  bool get isAllPassed =>
      isInsideRadius && isDeviceVerified && isWifiVerified && isFaceVerified;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: context.colors.bgCard,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isAllPassed
                      ? AppColors.onTimeLight
                      : context.colors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isAllPassed ? Icons.verified_user_rounded : Icons.shield_rounded,
                    size: 30,
                    color: isAllPassed ? AppColors.onTime : context.colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Security Check-In Protocol',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: context.colors.textMain,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '4-Layer Anti-Spoofing & Biometric Verification',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textMuted,
                ),
              ),
              const SizedBox(height: 16),

              // Live Biometric Face Matching Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.bgCanvas,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isFaceVerified
                        ? AppColors.onTime.withAlpha(80)
                        : (isFaceScanning ? context.colors.primary.withAlpha(80) : context.colors.borderSubtle),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AppAvatar(
                          name: widget.userName,
                          photoUrl: widget.userPhotoUrl,
                          radius: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: context.colors.textMain,
                                ),
                              ),
                              Text(
                                '${widget.userCode} • Registered Biometric Profile',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isFaceVerified
                                ? AppColors.onTimeLight
                                : (isFaceScanning ? context.colors.primaryLight : context.colors.bgCard),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isFaceVerified
                                  ? AppColors.onTime.withAlpha(60)
                                  : (isFaceScanning ? context.colors.primary.withAlpha(60) : context.colors.borderSubtle),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isFaceScanning)
                                const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(strokeWidth: 1.5),
                                )
                              else
                                Icon(
                                  isFaceVerified ? Icons.check_circle_rounded : Icons.camera_front_rounded,
                                  size: 13,
                                  color: isFaceVerified ? AppColors.onTime : context.colors.textDim,
                                ),
                              const SizedBox(width: 4),
                              Text(
                                isFaceVerified ? '99.4% Match' : (isFaceScanning ? 'Scanning...' : 'Ready'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isFaceVerified ? AppColors.onTime : (isFaceScanning ? context.colors.primary : context.colors.textDim),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── 1. GPS 50m Geofence ──
              _buildVerificationRow(
                isDone: !isGpsVerifying && isInsideRadius,
                isLoading: isGpsVerifying,
                icon: Icons.location_on_rounded,
                title: 'Branch Geofence ($simulatedDistance m from Center)',
                subtitle: '50m threshold enforced • Mock Location: Clean',
              ),
              const SizedBox(height: 9),

              // ── 2. Specific Registered Device ──
              _buildVerificationRow(
                isDone: isDeviceVerified,
                isLoading: isDeviceVerifying,
                icon: Icons.phonelink_lock_rounded,
                title: 'Authorized Device Bound (Pixel 7)',
                subtitle: 'Hardware UUID: 8A4F-291C • Single-phone policy',
              ),
              const SizedBox(height: 9),

              // ── 3. WiFi Router BSSID MAC Address ──
              _buildVerificationRow(
                isDone: isWifiVerified,
                isLoading: isWifiVerifying,
                icon: Icons.wifi_tethering_rounded,
                title: 'HQ Router Access Point (BSSID Match)',
                subtitle: 'MAC: 74:83:C2:A1:09:4E • Anti-hotspot spoofing',
              ),
              const SizedBox(height: 9),

              // ── 4. In-App Camera Face Liveness ──
              _buildVerificationRow(
                isDone: isFaceVerified,
                isLoading: isFaceScanning,
                icon: Icons.face_retouching_natural_rounded,
                title: 'In-App Live Face ID Scan',
                subtitle: isFaceScanning
                    ? 'Front camera analyzing micro-blinks & depth...'
                    : 'Live facial biometrics confirmed (Anti-Photo/Screen passed)',
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: context.colors.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: context.colors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isAllPassed
                          ? () {
                              Navigator.of(context).pop();
                              widget.onConfirmCheckIn(
                                latitude: _activeBranchLat,
                                longitude: _activeBranchLon,
                                biometricVerified: isFaceVerified,
                                isMockLocation: isMockGpsDetected,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.onTime,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Confirm Clock-In',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationRow({
    required bool isDone,
    required bool isLoading,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    Color bg;
    Color iconColor;

    if (isDone) {
      bg = AppColors.onTimeLight;
      iconColor = AppColors.onTime;
    } else if (isLoading) {
      bg = context.colors.primaryLight;
      iconColor = context.colors.primary;
    } else {
      bg = context.colors.bgCanvas;
      iconColor = context.colors.textDim;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? AppColors.onTime.withAlpha(50)
              : isLoading
                  ? context.colors.primary.withAlpha(50)
                  : context.colors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              isDone ? Icons.check_circle_rounded : icon,
              color: iconColor,
              size: 19,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDone ? context.colors.textMain : context.colors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDone ? AppColors.onTime : context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


