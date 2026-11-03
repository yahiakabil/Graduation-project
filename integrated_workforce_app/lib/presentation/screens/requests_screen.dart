import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/request_model.dart';
import '../../data/models/user_model.dart';
import '../../logic/requests/requests_cubit.dart';
import '../../logic/requests/requests_state.dart';
import '../widgets/app_avatar.dart';
import '../../core/theme/app_colors_extension.dart';

class RequestsScreen extends StatefulWidget {
  final UserModel user;

  const RequestsScreen({super.key, required this.user});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  RequestType? _filterType;
  DateTime? _filterDate;
  String _selectedAdminTeam = 'All';
  int _managerTabIndex = 0; // 0 = Team Approvals, 1 = My Requests

  void _showDecisionDialog(BuildContext context, RequestModel req, bool isApprove) {
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: context.colors.bgCard,
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle : Icons.cancel,
              color: isApprove ? AppColors.onTime : AppColors.absent,
            ),
            const SizedBox(width: 8),
            Text(
              isApprove ? 'Approve Request' : 'Reject Request',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm ${isApprove ? 'approving' : 'rejecting'} ${req.typeLabel} for ${req.employeeName}:',
              style: TextStyle(fontSize: 12, color: context.colors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: isApprove
                    ? 'Optional manager comment (e.g. Approved)...'
                    : 'Reason for rejection (e.g. Needs prior notice)...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (isApprove) {
                context.read<RequestsCubit>().approveRequest(
                      req.id,
                      comment: commentCtrl.text.trim().isNotEmpty
                          ? commentCtrl.text.trim()
                          : 'Approved by Manager.',
                    );
              } else {
                context.read<RequestsCubit>().rejectRequest(
                      req.id,
                      comment: commentCtrl.text.trim().isNotEmpty
                          ? commentCtrl.text.trim()
                          : 'Rejected by Manager.',
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? AppColors.onTime : AppColors.absent,
              foregroundColor: Colors.white,
            ),
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _openNewRequestModal(BuildContext context) {
    RequestType selectedType = RequestType.permission;
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final reasonController = TextEditingController();
    final minutesController = TextEditingController(text: '30');
    final advanceAmountController = TextEditingController(text: '2000');
    String repaymentSchedule = 'Deduct next month in full';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: context.colors.bgCard,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isManager = widget.user.role == UserRole.manager;
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Submit New Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: context.colors.textMain,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(modalCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Destination Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: context.colors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedType == RequestType.cashAdvance
                                  ? 'Destination: Requires Manager review, then Admin (HR & Finance) final disbursement.'
                                  : isManager
                                      ? 'Destination: Admin (HR) will review your request.'
                                      : 'Destination: Your Manager (${widget.user.managerName}) will review this.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type Dropdown
                    Text(
                      'Request Type',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<RequestType>(
                      value: selectedType,
                      decoration: const InputDecoration(),
                      items: const [
                        DropdownMenuItem(value: RequestType.permission, child: Text('Late/Early Permission')),
                        DropdownMenuItem(value: RequestType.leave, child: Text('Leave (Annual, Sick, Unpaid)')),
                        DropdownMenuItem(value: RequestType.excuse, child: Text('Single-Day Excuse')),
                        DropdownMenuItem(value: RequestType.correction, child: Text('Check-Out Correction (24h)')),
                        DropdownMenuItem(value: RequestType.overtime, child: Text('Overtime Request')),
                        DropdownMenuItem(value: RequestType.cashAdvance, child: Text('Loan')),
                        DropdownMenuItem(value: RequestType.deviceChange, child: Text('Device Change (New Phone)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Loan Specific Inputs
                    if (selectedType == RequestType.cashAdvance) ...[
                      Text(
                        'Requested Advance Amount (EGP)',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: advanceAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixText: 'EGP ',
                          hintText: 'Enter amount (e.g. 2000)',
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Repayment Schedule',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: repaymentSchedule,
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'Deduct next month in full', child: Text('Deduct next month in full')),
                          DropdownMenuItem(value: 'Split across 2 months (50% each)', child: Text('Split across 2 months (50% each)')),
                          DropdownMenuItem(value: 'Split across 3 months (33% each)', child: Text('Split across 3 months (33% each)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => repaymentSchedule = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Target Date
                    Text(
                      'Target Date',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.calendar_today, size: 18),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Minutes (if Permission or Overtime)
                    if (selectedType == RequestType.permission || selectedType == RequestType.overtime) ...[
                      Text(
                        'Requested Minutes',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: minutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.timelapse, size: 18),
                          suffixText: 'Minutes',
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Reason / Explanation
                    Text(
                      'Reason & Justification',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: selectedType == RequestType.cashAdvance
                            ? 'State reason for Loan (e.g. personal emergency)...'
                            : 'State official justification...',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        if (reasonController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please provide a reason.')),
                          );
                          return;
                        }

                        final newReq = RequestModel(
                          id: 'req-${DateTime.now().millisecondsSinceEpoch}',
                          employeeId: widget.user.id,
                          employeeName: widget.user.name,
                          employeeRole: widget.user.jobTitle,
                          type: selectedType,
                          status: RequestStatus.pending,
                          submissionDate: DateTime.now(),
                          targetDate: dateController.text,
                          reason: reasonController.text.trim(),
                          minutes: int.tryParse(minutesController.text),
                          advanceAmount: selectedType == RequestType.cashAdvance
                              ? double.tryParse(advanceAmountController.text)
                              : null,
                          repaymentSchedule: selectedType == RequestType.cashAdvance
                              ? repaymentSchedule
                              : null,
                          reviewerRole: (selectedType == RequestType.cashAdvance || isManager)
                              ? 'Admin HR'
                              : 'Direct Manager',
                          department: widget.user.department,
                        );

                        context.read<RequestsCubit>().submitRequest(newReq);
                        Navigator.of(modalCtx).pop();
                      },
                      child: const Text('Submit for Approval'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isManager = widget.user.role == UserRole.manager;
    final isAdmin = widget.user.role == UserRole.admin;

    return Scaffold(
      
      appBar: AppBar(
        title: Text(
          (isManager || isAdmin)
              ? (_managerTabIndex == 0 ? (isAdmin ? 'Company Approvals' : 'Team Approvals') : (isAdmin ? 'Requests Ledger' : 'My Requests'))
              : 'My Requests',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _filterDate == null ? Icons.calendar_month_outlined : Icons.event_available,
              color: _filterDate == null ? context.colors.primary : AppColors.onTime,
              size: 24,
            ),
            tooltip: 'Filter by Specific Day',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _filterDate ?? DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2027, 12),
              );
              if (picked != null) {
                setState(() => _filterDate = picked);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: context.colors.primary, size: 28),
            onPressed: () => _openNewRequestModal(context),
          ),
        ],
      ),
      body: BlocConsumer<RequestsCubit, RequestsState>(
        listener: (context, state) {
          if (state is RequestsLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.onTime,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isApprover = isManager || isAdmin;
          final List<RequestModel> allRequests = (state is RequestsLoaded) ? state.myRequests : [];
          final List<RequestModel> allPending = (state is RequestsLoaded) ? state.pendingApprovals : [];
          // Server /requests/pending already authorizes and filters correctly for current manager/admin
          final List<RequestModel> pendingForApprover = allPending;

          List<RequestModel> roleFiltered;

          if (widget.user.role == UserRole.employee) {
            // Regular employees only see their own requests
            roleFiltered = allRequests.where((r) => r.employeeId == widget.user.id).toList();
          } else if (widget.user.role == UserRole.manager) {
            // Managers in 'My Requests' tab see strictly their own personal requests
            roleFiltered = allRequests.where((r) => r.employeeId == widget.user.id).toList();
          } else {
            // Admin sees all or chooses a specific department team
            if (_selectedAdminTeam == 'All') {
              roleFiltered = allRequests;
            } else {
              roleFiltered = allRequests.where((r) => r.department == _selectedAdminTeam).toList();
            }
          }

          // Filter by Type
          var filtered = _filterType == null
              ? roleFiltered
              : roleFiltered.where((r) => r.type == _filterType).toList();

          // Filter by Day (Edit 1)
          if (_filterDate != null) {
            final dateStr1 = DateFormat('yyyy-MM-dd').format(_filterDate!);
            final dateStr2 = DateFormat('MMM d, yyyy').format(_filterDate!).toLowerCase();
            final dateStr3 = DateFormat('MMM dd, yyyy').format(_filterDate!).toLowerCase();
            final dayNumStr = 'oct ${_filterDate!.day}';

            filtered = filtered.where((r) {
              final sub = r.submissionDate;
              final isSameSub = sub.year == _filterDate!.year && sub.month == _filterDate!.month && sub.day == _filterDate!.day;
              final targetLower = r.targetDate.toLowerCase();
              final isSameTarget = targetLower.contains(dateStr1) ||
                  targetLower.contains(dateStr2) ||
                  targetLower.contains(dateStr3) ||
                  targetLower.contains(dayNumStr);
              return isSameSub || isSameTarget;
            }).toList();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Approver Top Segmented Toggle: Approvals vs Requests Ledger
              if (isApprover)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.colors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _managerTabIndex = 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _managerTabIndex == 0 ? context.colors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.assignment_turned_in_outlined,
                                    size: 16,
                                    color: _managerTabIndex == 0 ? Colors.white : context.colors.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${isAdmin ? "Pending Approvals" : "Team Approvals"} (${pendingForApprover.length})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _managerTabIndex == 0 ? Colors.white : context.colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _managerTabIndex = 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _managerTabIndex == 1 ? context.colors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: _managerTabIndex == 1 ? Colors.white : context.colors.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isAdmin ? 'Requests Ledger' : 'My Requests',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _managerTabIndex == 1 ? Colors.white : context.colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // VIEW 1: Approver (Manager / Admin HR) Approvals Tab
              if (isApprover && _managerTabIndex == 0)
                Expanded(
                  child: _buildTeamApprovalsList(context, pendingForApprover),
                )
              else ...[
                // VIEW 2: My Personal Requests / Employee / Admin View
                // Notice banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.primary.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.route, color: context.colors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAdmin
                              ? 'Admin Oversight: Full company request ledger with instant department filtering.'
                              : isManager
                                  ? 'Destination: Your personal requests are routed directly to Admin (HR) for review.'
                                  : 'Requests route to your Direct Manager. Device changes route to Admin.',
                          style: TextStyle(fontSize: 11, color: context.colors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

                // Admin Team Selector
                if (isAdmin)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.colors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.group_work_outlined, size: 16, color: context.colors.primary),
                        const SizedBox(width: 10),
                        Text('Filter Team: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMuted)),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedAdminTeam,
                              isExpanded: true,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.colors.textMain),
                              items: const [
                                DropdownMenuItem(value: 'All', child: Text('All Teams (Company-Wide)')),
                                DropdownMenuItem(value: 'Mobile Engineering Team', child: Text('Mobile Engineering Team')),
                                DropdownMenuItem(value: 'Product & QA Team', child: Text('Product & QA Team')),
                                DropdownMenuItem(value: 'Cloud & Infrastructure Team', child: Text('Cloud & Infrastructure Team')),
                                DropdownMenuItem(value: 'UX & Design Team', child: Text('UX & Design Team')),
                                DropdownMenuItem(value: 'HR & Operations Team', child: Text('HR & Operations Team')),
                                DropdownMenuItem(value: 'Mediterranean Sales Team', child: Text('Mediterranean Sales Team')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedAdminTeam = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Active Date Filter Pill (with X Cancel button)
                if (_filterDate != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: context.colors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.primary.withAlpha(90)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, size: 16, color: context.colors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Filtered Date: ${DateFormat('dd MMM yyyy').format(_filterDate!)}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.colors.primary),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _filterDate = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, size: 14, color: context.colors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterChip('All', null),
                      _buildFilterChip('Permission', RequestType.permission),
                      _buildFilterChip('Leave', RequestType.leave),
                      _buildFilterChip('Cash Advance (سلفة)', RequestType.cashAdvance),
                      _buildFilterChip('Overtime', RequestType.overtime),
                      _buildFilterChip('Profile Update', RequestType.profileUpdate),
                      _buildFilterChip('Device Change', RequestType.deviceChange),
                    ],
                  ),
                ),

                // Request Cards List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.find_in_page_outlined, size: 40, color: context.colors.textDim),
                              const SizedBox(height: 8),
                              Text(
                                'No requests found for this filter.',
                                style: TextStyle(color: context.colors.textMuted, fontWeight: FontWeight.w700),
                              ),
                              if (_filterDate != null) ...[
                                const SizedBox(height: 10),
                                TextButton.icon(
                                  onPressed: () => setState(() => _filterDate = null),
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Clear Date Filter'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final req = filtered[index];
                            return _buildRequestCard(context, req);
                          },
                        ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, RequestType? type) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primary : context.colors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : context.colors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, RequestModel req) {
    Color statusBg;
    Color statusText;
    String statusStr;

    switch (req.status) {
      case RequestStatus.pending:
        statusBg = AppColors.lateLight;
        statusText = AppColors.late;
        statusStr = 'Pending Review';
        break;
      case RequestStatus.approved:
        statusBg = AppColors.onTimeLight;
        statusText = AppColors.onTime;
        statusStr = 'Approved';
        break;
      case RequestStatus.rejected:
        statusBg = AppColors.absentLight;
        statusText = AppColors.absent;
        statusStr = 'Rejected';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req.typeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: context.colors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusStr,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (req.type == RequestType.cashAdvance && req.advanceAmount != null) ...[
            Text(
              'Advance Amount: ${req.advanceAmount!.toInt()} EGP (${req.repaymentSchedule ?? "Next Month"})',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.onTime,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            'Target Date: ${req.targetDate} ${req.minutes != null ? '(${req.minutes} mins)' : ''}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: context.colors.textMain,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.bgCanvas,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${req.reason}"',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: context.colors.textMuted,
              ),
            ),
          ),
          if (req.managerComment != null) ...[
            const SizedBox(height: 8),
            Text(
              'Reviewer note: ${req.managerComment}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onTime,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviewer: ${req.reviewerRole}',
                style: TextStyle(
                  fontSize: 10,
                  color: context.colors.textDim,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (req.status == RequestStatus.pending)
                TextButton(
                  onPressed: () {
                    context.read<RequestsCubit>().cancelRequest(req.id);
                  },
                  child: const Text(
                    'Cancel Request',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.absent,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamApprovalsList(BuildContext context, List<RequestModel> pendingList) {
    if (pendingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.onTimeLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.done_all_rounded, size: 42, color: AppColors.onTime),
            ),
            const SizedBox(height: 14),
            Text(
              'No Pending Team Approvals',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: context.colors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'All incoming requests from your department have been reviewed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pendingList.length,
      itemBuilder: (context, index) {
        final req = pendingList[index];
        return _buildTeamApprovalCard(context, req);
      },
    );
  }

  Widget _buildTeamApprovalCard(BuildContext context, RequestModel req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Member Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppAvatar(
                    name: req.employeeName,
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.employeeName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: context.colors.textMain,
                        ),
                      ),
                      Text(
                        req.employeeRole,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lateLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req.typeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.late,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Details Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.bgCanvas,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Requested Details:',
                      style: TextStyle(fontSize: 11, color: context.colors.textMuted, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${req.targetDate} ${req.minutes != null ? '(${req.minutes} mins)' : ''}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.colors.textMain),
                    ),
                  ],
                ),
                if (req.actualCheckInTime != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Actual Server Clock-In:',
                        style: TextStyle(fontSize: 11, color: context.colors.textMuted, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        req.actualCheckInTime!,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.late),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Reason: "${req.reason}"',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Decision Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDecisionDialog(context, req, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.absent,
                    side: BorderSide(color: AppColors.absentLight),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showDecisionDialog(context, req, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onTime,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


