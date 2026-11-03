import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_colors_extension.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/auth/auth_state.dart';
import '../widgets/app_avatar.dart';

class DemoAccount {
  final String name;
  final String email;
  final String roleLabel;
  final String category; // 'hr', 'manager', 'tech'
  final String department;
  final String photoUrl;
  final IconData icon;
  final Color color;

  const DemoAccount({
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.category,
    required this.department,
    required this.photoUrl,
    required this.icon,
    required this.color,
  });
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final List<DemoAccount> _accounts = [
    DemoAccount(
      name: 'Yahia Hussien',
      email: 'yahia.hussien@company.com',
      roleLabel: 'HR Leader / Admin',
      category: 'hr',
      department: 'Executive Administration & HR',
      photoUrl: 'assets/images/yahia_hussien.jpg',
      icon: Icons.admin_panel_settings_rounded,
      color: const Color(0xFF4F46E5),
    ),
    DemoAccount(
      name: 'Mohamed Hussien',
      email: 'mohamed.hussien@company.com',
      roleLabel: 'Tech Manager / Approver',
      category: 'manager',
      department: 'Engineering Operations',
      photoUrl: 'assets/images/mohamed_hussien.jpg',
      icon: Icons.supervisor_account_rounded,
      color: Color(0xFF06B6D4),
    ),
    DemoAccount(
      name: 'Ahmed Kamal',
      email: 'ahmed.kamal@company.com',
      roleLabel: 'Senior Backend Engineer',
      category: 'tech',
      department: 'Engineering Operations',
      photoUrl: 'assets/images/ahmed_kamal.jpg',
      icon: Icons.terminal_rounded,
      color: AppColors.onTime,
    ),
    DemoAccount(
      name: 'Sara Nour',
      email: 'sara.nour@company.com',
      roleLabel: 'Product Design Lead',
      category: 'tech',
      department: 'Engineering Operations',
      photoUrl: 'assets/images/sara_nour.jpg',
      icon: Icons.brush_rounded,
      color: Color(0xFFEC4899),
    ),
    DemoAccount(
      name: 'Tarek Mahmoud',
      email: 'tarek.mahmoud@company.com',
      roleLabel: 'Quality Assurance Lead',
      category: 'tech',
      department: 'Engineering Operations',
      photoUrl: 'assets/images/tarek_mahmoud.jpg',
      icon: Icons.bug_report_rounded,
      color: AppColors.late,
    ),
    DemoAccount(
      name: 'Mona Zaki',
      email: 'mona.zaki@company.com',
      roleLabel: 'DevOps / Cloud Specialist',
      category: 'tech',
      department: 'Engineering Operations',
      photoUrl: 'assets/images/mona_zaki.jpg',
      icon: Icons.cloud_done_rounded,
      color: Color(0xFF8B5CF6),
    ),
    DemoAccount(
      name: 'Yousef Kamal',
      email: 'yousef.kamal@company.com',
      roleLabel: 'Logistics Manager',
      category: 'manager',
      department: 'Supply Chain & Field Operations',
      photoUrl: '',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF3B82F6),
    ),
    DemoAccount(
      name: 'Nour El-Din',
      email: 'nour.eldin@company.com',
      roleLabel: 'Site Construction Manager',
      category: 'manager',
      department: 'Civil Infrastructure & Sites',
      photoUrl: '',
      icon: Icons.construction_rounded,
      color: Color(0xFFF97316),
    ),
    DemoAccount(
      name: 'Hany Shaker',
      email: 'hany.shaker@company.com',
      roleLabel: 'Customer Support Lead',
      category: 'manager',
      department: 'Customer Care & Retention',
      photoUrl: '',
      icon: Icons.support_agent_rounded,
      color: Color(0xFF14B8A6),
    ),
    DemoAccount(
      name: 'Khaled Selim',
      email: 'khaled.selim@company.com',
      roleLabel: 'Marketing Operations Manager',
      category: 'manager',
      department: 'Marketing & Corporate Branding',
      photoUrl: '',
      icon: Icons.campaign_rounded,
      color: Color(0xFFA855F7),
    ),
  ];

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  String _selectedCategory = 'all';
  DemoAccount _selectedAccount = _accounts[0];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: _selectedAccount.email);
    _passwordController = TextEditingController(text: 'password123');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectAccount(DemoAccount account) {
    setState(() {
      _selectedAccount = account;
      _emailController.text = account.email;
      _passwordController.text = 'password123';
    });
  }

  void _onLoginPressed() {
    context.read<AuthCubit>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.absent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),

                    // App Logo & Header
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.primary, colors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withAlpha(80),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.fingerprint,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Shiftly',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: colors.textMain,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Smart Workforce & Shift Management',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Quick Account & Role Picker ────────────────────────────
                    _buildAccountPickerSection(isLoading),
                    const SizedBox(height: 20),

                    // ─── Login Credentials Form ─────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.bgCard,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: colors.borderSubtle),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Workplace Email',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colors.textMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: colors.textMain),
                            decoration: InputDecoration(
                              hintText: 'name@company.com',
                              fillColor: colors.bgCardSubtle,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: colors.textDim,
                                size: 20,
                              ),
                              suffixIcon: _emailController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, size: 18, color: colors.textDim),
                                      onPressed: () => _emailController.clear(),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colors.textMain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(color: colors.textMain),
                            decoration: InputDecoration(
                              hintText: 'Enter account password',
                              fillColor: colors.bgCardSubtle,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: colors.textDim,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: colors.textDim,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Login Button
                          ElevatedButton(
                            onPressed: isLoading ? null : _onLoginPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text('Sign In as ${_selectedAccount.name.split(' ').first}'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password Note
                    Center(
                      child: Text(
                        'Universal password for all demo accounts: password123',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.textDim,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountPickerSection(bool isLoading) {
    final colors = context.colors;
    final filtered = _selectedCategory == 'all'
        ? _accounts
        : _accounts.where((a) => a.category == _selectedCategory).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.switch_account_rounded, size: 18, color: colors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'CHOOSE SAVED ACCOUNT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: colors.textDim,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '1-Tap Switch',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Category filter pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('all', 'All Roles (${_accounts.length})', Icons.groups_rounded),
                const SizedBox(width: 6),
                _buildCategoryChip('hr', '👑 HR Leader', Icons.admin_panel_settings_rounded),
                const SizedBox(width: 6),
                _buildCategoryChip('manager', '💼 Tech Managers (5)', Icons.supervisor_account_rounded),
                const SizedBox(width: 6),
                _buildCategoryChip('tech', '💻 Tech Team', Icons.computer_rounded),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Accounts list
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final acc = filtered[index];
                final isSelected = acc.email == _emailController.text.trim().toLowerCase();

                return GestureDetector(
                  onTap: () => _selectAccount(acc),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 195,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.bgCardSubtle,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? acc.color : colors.borderSubtle,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: acc.color.withAlpha(40),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            AppAvatar(
                              name: acc.name,
                              photoUrl: acc.photoUrl,
                              radius: 17,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: colors.textMain,
                                    ),
                                  ),
                                  Text(
                                    acc.roleLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: acc.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                acc.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: colors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded, size: 14, color: acc.color),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String catKey, String label, IconData icon) {
    final colors = context.colors;
    final isSelected = _selectedCategory == catKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = catKey;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.bgCardSubtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.primary : colors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : colors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
