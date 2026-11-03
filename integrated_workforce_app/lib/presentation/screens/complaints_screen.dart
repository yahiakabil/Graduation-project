import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/request_model.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/auth/auth_state.dart';
import '../../logic/requests/requests_cubit.dart';
import '../../core/theme/app_colors_extension.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _subjectController = TextEditingController();
  final _complaintController = TextEditingController();
  bool _isAnonymous = false;
  String _selectedCategory = 'Managerial Grievance';

  final List<String> _categories = [
    'Managerial Grievance',
    'Workplace Harassment',
    'Payroll / Deduction Discrepancy',
    'Safety & Facility Concern',
    'Ethics & Whistleblower',
    'General Feedback',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  void _submitComplaint() {
    if (_complaintController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe your grievance or inquiry.'),
          backgroundColor: AppColors.absent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: context.colors.primary, size: 28),
            SizedBox(width: 10),
            Text('Confirm Submission', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Text(
          _isAnonymous
              ? 'Your complaint will be sent ANONYMOUSLY directly to the HR Administrator. Your manager will not see this report.'
              : 'Your complaint will be sent directly to the HR Administrator with your employee profile attached. Your manager will not see this report.',
          style: TextStyle(fontSize: 12, color: context.colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthCubit>().state;
              final user = authState is Authenticated ? authState.user : null;
              final empName = _isAnonymous ? 'Anonymous Employee' : (user?.name ?? 'Employee');
              final empId = _isAnonymous ? 'anon' : (user?.id ?? 'emp-1');
              final empRole = _isAnonymous ? 'Confidential Staff' : (user?.jobTitle ?? 'Employee');

              final subject = _subjectController.text.trim();
              final text = _complaintController.text.trim();
              final reason = '[$_selectedCategory] ${subject.isNotEmpty ? '$subject - ' : ''}$text';

              final req = RequestModel(
                id: 'complaint-${DateTime.now().millisecondsSinceEpoch}',
                employeeId: empId,
                employeeName: empName,
                employeeRole: empRole,
                type: RequestType.complaint,
                status: RequestStatus.pending,
                submissionDate: DateTime.now(),
                targetDate: 'Direct HR Resolution',
                reason: reason,
                reviewerRole: 'Admin HR',
              );

              context.read<RequestsCubit>().submitRequest(req);

              Navigator.pop(ctx);
              _subjectController.clear();
              _complaintController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Grievance report submitted directly to HR Administrator.'),
                  backgroundColor: AppColors.onTime,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Submit to HR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Direct HR & About Workplace'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.colors.primary,
          unselectedLabelColor: context.colors.textMuted,
          indicatorColor: context.colors.primary,
          tabs: const [
            Tab(text: 'Direct HR Complaints'),
            Tab(text: 'About Workplace'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Direct HR Grievances
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Confidentiality Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.colors.primary.withAlpha(60)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_person_outlined, color: context.colors.primary, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CONFIDENTIAL & DIRECT TO HR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: context.colors.primary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Reports submitted here bypass your direct manager completely and route exclusively to the HR Administration department.',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colors.primary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Form Container
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.colors.bgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Anonymous Toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Submit Anonymously',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: context.colors.textMain),
                      ),
                      subtitle: Text(
                        'Do not disclose my name or employee code to HR',
                        style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                      ),
                      value: _isAnonymous,
                      activeColor: context.colors.primary,
                      onChanged: (val) {
                        setState(() {
                          _isAnonymous = val;
                        });
                      },
                    ),
                    Divider(height: 20, color: context.colors.borderSubtle),

                    // Category
                    Text(
                      'Grievance Category',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(),
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Subject
                    Text(
                      'Subject / Title',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        hintText: 'Brief summary of the issue...',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Details
                    Text(
                      'Detailed Description',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _complaintController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Provide complete details, dates, and context for HR investigation...',
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _submitComplaint,
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Send Directly to HR'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // TAB 2: About Workplace
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.bgCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.colors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [context.colors.primary, context.colors.primary],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.business_center, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Integrated Workforce',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              'Enterprise Workforce & Payroll System v2.0',
                              style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Security & Compliance Standards:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.colors.textMain),
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureItem(Icons.gps_fixed, 'Strict 50-Meter Geofencing', 'Attendance is only recorded within verified branch GPS boundaries.'),
                    _buildFeatureItem(Icons.security, 'Anti-Spoofing & Mock GPS Guard', 'Third-party mock location apps are automatically detected and blocked.'),
                    _buildFeatureItem(Icons.phonelink_lock, 'Hardware Device UUID Binding', 'Prevents proxy attendance by locking user accounts to registered physical devices.'),
                    _buildFeatureItem(Icons.timeline, '15-Minute Chronological Radar', 'Verifies continuous employee presence throughout core work hours.'),
                    _buildFeatureItem(Icons.balance, 'Automated Lateness Ladder', 'Calculates payroll adjustments mathematically according to labor policies.'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: context.colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.colors.textMain)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 11, color: context.colors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

