import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/team_model.dart';
import '../../../data/models/tournament_registration_model.dart';
import '../../bloc/tournament/tournament_bloc.dart';
import '../../bloc/tournament/tournament_event.dart';
import '../../bloc/tournament/tournament_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../paypal_webview_handler.dart';

class TournamentRegistrationDialog extends StatefulWidget {
  final TournamentModel tournament;
  
  const TournamentRegistrationDialog({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentRegistrationDialog> createState() => _TournamentRegistrationDialogState();
}

class _TournamentRegistrationDialogState extends State<TournamentRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _teamDescriptionController = TextEditingController();
  
  bool _showCreateTeamForm = false; // Start with false, will be updated based on teams
  bool _isLoadingTeams = true; // Add loading state
  int? _selectedTeamId;
  List<dynamic> _userTeams = [];
  
  @override
  void initState() {
    super.initState();
    print('DEBUG: TournamentRegistrationDialog initState called');
    _loadUserTeams();
  }
  
  void _loadUserTeams() {
    final authState = context.read<AuthBloc>().state;
    print('DEBUG: _loadUserTeams called, authState: ${authState.runtimeType}');
    if (authState is Authenticated) {
      print('DEBUG: User authenticated, userId: ${authState.user.id}');
      context.read<TournamentBloc>().add(
        LoadUserTeams(userId: authState.user.id),
      );
      print('DEBUG: LoadUserTeams event dispatched');
    } else {
      print('DEBUG: User not authenticated, authState: $authState');
    }
  }
  
  @override
  void dispose() {
    _teamNameController.dispose();
    _teamDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TournamentBloc, TournamentState>(
      listener: (context, state) {
        if (state is UserTeamsLoaded) {
          // Teams loaded, determine UI state
          print('DEBUG: UserTeamsLoaded - teams count: ${state.teams.length}');
          print('DEBUG: Teams data: ${state.teams.map((t) => '${t.name} (ID: ${t.id})').toList()}');
          setState(() {
            _userTeams = state.teams;
            _isLoadingTeams = false;
            _showCreateTeamForm = state.teams.isEmpty;
            print('DEBUG: _showCreateTeamForm set to: $_showCreateTeamForm');
            print('DEBUG: _userTeams count: ${_userTeams.length}');
            print('DEBUG: _isLoadingTeams set to: $_isLoadingTeams');
          });
        } else if (state is TeamCreated) {
          // Team created successfully, add to teams list and show selection
          setState(() {
            _userTeams.add(state.team);
            _selectedTeamId = state.team.id;
            _showCreateTeamForm = false;
            _isLoadingTeams = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tạo team thành công! Vui lòng xác nhận đăng ký.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is TournamentRegistrationSuccess) {
          // Registration successful, close dialog and navigate to payment
          Navigator.of(context).pop();
          
          if (state.response.paymentUrl != null) {
             // Navigate to payment URL (PayPal)
             _handlePayPalPayment(state.response.paymentUrl!);
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text(
                   'Đăng ký thành công! Đang chuyển hướng đến trang thanh toán...',
                   style: const TextStyle(color: Colors.white),
                 ),
                 backgroundColor: Colors.green,
                 duration: const Duration(seconds: 3),
               ),
             );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Đăng ký thành công! Kiểm tra email để xác nhận.',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else if (state is TournamentError) {
          // Handle specific error cases
          String errorMessage = state.message;
          Color backgroundColor = Colors.red;
          
          // Check for specific error types
          if (state.message.toLowerCase().contains('đã đăng ký') || 
              state.message.toLowerCase().contains('already registered') ||
              state.message.contains('409')) {
            errorMessage = 'Team này đã đăng ký giải đấu rồi!';
            backgroundColor = Colors.orange;
          } else if (state.message.toLowerCase().contains('hết chỗ') || 
                     state.message.toLowerCase().contains('full') ||
                     state.message.toLowerCase().contains('capacity')) {
            errorMessage = 'Giải đấu đã hết chỗ đăng ký!';
            backgroundColor = Colors.red;
          } else if (state.message.toLowerCase().contains('deadline') ||
                     state.message.toLowerCase().contains('hạn đăng ký')) {
            errorMessage = 'Đã hết hạn đăng ký cho giải đấu này!';
            backgroundColor = Colors.red;
          } else if (state.message.toLowerCase().contains('network') ||
                     state.message.toLowerCase().contains('connection') ||
                     state.message.toLowerCase().contains('internet')) {
            errorMessage = 'Lỗi kết nối mạng. Vui lòng thử lại!';
            backgroundColor = Colors.grey;
          } else {
            errorMessage = 'Đăng ký thất bại: ${state.message}';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: backgroundColor,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Đóng',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildContent(),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryAccent.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: AppTheme.primaryAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register for Tournament',
                      style: AppTheme.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.tournament.name,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTournamentInfo(),
            const SizedBox(height: 20),
            _buildRegistrationForm(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTournamentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Start: ${_formatDate(widget.tournament.startDate)}',
                style: AppTheme.bodySmall,
              ),
              const Spacer(),
              Icon(
                Icons.people,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.tournament.currentTeams}/${widget.tournament.maxTeams} teams',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.attach_money,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                widget.tournament.registrationFee > 0
                    ? 'Fee: ${widget.tournament.registrationFee.toStringAsFixed(0)} VND'
                    : 'Free tournament',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.tournament.registrationFee > 0
                      ? AppTheme.textPrimary
                      : Colors.green,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.event_available,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.tournament.registrationDeadline != null
                    ? 'Deadline: ${_formatDate(widget.tournament.registrationDeadline!)}'
                    : 'Deadline: Not specified',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegistrationForm() {
    return BlocBuilder<TournamentBloc, TournamentState>(
      builder: (context, state) {
        print('DEBUG: _buildRegistrationForm - state: ${state.runtimeType}');
        print('DEBUG: _isLoadingTeams: $_isLoadingTeams');
        print('DEBUG: _showCreateTeamForm: $_showCreateTeamForm');
        print('DEBUG: _userTeams count: ${_userTeams.length}');
        
        // Show loading while teams are being fetched
        if (_isLoadingTeams || state is TournamentLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải danh sách team...'),
                ],
              ),
            ),
          );
        }
        
        // After loading is complete, decide what to show
        if (_userTeams.isNotEmpty && !_showCreateTeamForm) {
          print('DEBUG: Showing team selection');
          return _buildTeamSelection(_userTeams);
        }
        
        print('DEBUG: Showing create team form');
        return Column(
          children: [
            if (_userTeams.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showCreateTeamForm = false;
                      });
                    },
                    child: Text('Chọn team có sẵn (${_userTeams.length})'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showCreateTeamForm = true;
                      });
                    },
                    child: const Text('Tạo team mới'),
                  ),
                ],
              ),
            if (_userTeams.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bạn chưa có team nào. Vui lòng tạo team để đăng ký giải đấu.',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _buildCreateTeamForm(),
          ],
        );
      },
    );
  }
  
  Widget _buildTeamSelection(List<dynamic> teams) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Your Team',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showCreateTeamForm = true;
                });
              },
              child: Text(
                'Create New Team',
                style: TextStyle(color: AppTheme.primaryAccent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: teams.map<Widget>((team) {
              final isSelected = _selectedTeamId == team.id;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedTeamId = team.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryAccent.withOpacity(0.1) : null,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: team.id,
                        groupValue: _selectedTeamId,
                        onChanged: (value) {
                          setState(() {
                            _selectedTeamId = value;
                          });
                        },
                        activeColor: AppTheme.primaryAccent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (team.code != null && team.code.isNotEmpty)
                              Text(
                                'Code: ${team.code}',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCreateTeamForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Create New Team',
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            BlocBuilder<TournamentBloc, TournamentState>(
              builder: (context, state) {
                if (state is UserTeamsLoaded && state.teams.isNotEmpty) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        _showCreateTeamForm = false;
                      });
                    },
                    child: Text(
                      'Select Existing Team',
                      style: TextStyle(color: AppTheme.primaryAccent),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _teamNameController,
          decoration: InputDecoration(
            labelText: 'Team Name *',
            hintText: 'Enter your team name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.group),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Team name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _teamDescriptionController,
          decoration: InputDecoration(
            labelText: 'Team Code',
            hintText: 'Enter your team code (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.code),
          ),
          maxLines: 1,
        ),
      ],
    );
  }
  
  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: BlocBuilder<TournamentBloc, TournamentState>(
              builder: (context, state) {
                final isLoading = state is TournamentLoading;
                
                return ElevatedButton(
                  onPressed: isLoading ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _showCreateTeamForm 
                              ? 'Tạo Team' 
                              : 'Đăng ký giải đấu',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
  
  void _submitRegistration() {
    // Get current user from auth bloc
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng đăng nhập để đăng ký giải đấu.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    if (_showCreateTeamForm) {
      // Creating new team - only create team, don't auto-register
      if (_formKey.currentState!.validate()) {
        context.read<TournamentBloc>().add(
          CreateTeam(
            name: _teamNameController.text.trim(),
            code: _teamDescriptionController.text.trim().isEmpty 
                ? null 
                : _teamDescriptionController.text.trim(),
            userId: authState.user.id,
          ),
        );
      }
    } else {
      // Using existing team
      if (_selectedTeamId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vui lòng chọn team để đăng ký.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      
      // Register with selected team
      final request = TournamentRegistrationRequest(
        tournamentId: widget.tournament.id!,
        teamId: _selectedTeamId!,
      );
      
      context.read<TournamentBloc>().add(
        RegisterForTournament(request: request),
      );
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handlePayPalPayment(String paymentUrl) async {
    try {
      // Show payment dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            'Payment Required',
            style: AppTheme.headingSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.payment,
                size: 48,
                color: AppTheme.primaryAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'You will be redirected to PayPal to complete your payment for this tournament.',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Fee: ${widget.tournament.registrationFee.toStringAsFixed(0)} VND',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryAccent,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close payment dialog
                Navigator.of(context).pop(); // Close registration dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close payment dialog
                await _launchPayPalUrl(paymentUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Pay with PayPal'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error opening payment: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _launchPayPalUrl(String url) async {
    try {
      // Close the registration dialog before opening PayPal WebView
      Navigator.of(context).pop();
      
      // Navigate to PayPal WebView for better UX
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PayPalWebViewHandler(
            paymentUrl: url,
            onPaymentSuccess: (paymentId) {
              Navigator.of(context).pop(); // Close WebView
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payment completed successfully! Payment ID: $paymentId',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            onPaymentError: (error) {
              Navigator.of(context).pop(); // Close WebView
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payment failed: $error',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            onPaymentCancel: () {
              Navigator.of(context).pop(); // Close WebView
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Payment was cancelled.',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error opening PayPal: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


}

// Helper function to show the dialog
void showTournamentRegistrationDialog({
  required BuildContext context,
  required TournamentModel tournament,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => TournamentRegistrationDialog(
      tournament: tournament,
    ),
  );
}