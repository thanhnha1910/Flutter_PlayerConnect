import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/tournament_registration_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/tournament/tournament_bloc.dart';
import '../../bloc/tournament/tournament_event.dart';
import '../../bloc/tournament/tournament_state.dart';
import '../../widgets/paypal_webview_handler.dart';
import 'tournament_receipt_screen.dart';

class TournamentRegistrationScreen extends StatefulWidget {
  final TournamentModel tournament;
  
  const TournamentRegistrationScreen({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentRegistrationScreen> createState() => _TournamentRegistrationScreenState();
}

class _TournamentRegistrationScreenState extends State<TournamentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _teamCodeController = TextEditingController();
  
  bool _showCreateTeamForm = false; // Start with false, will be updated based on teams
  bool _isLoadingTeams = true; // Add loading state
  int? _selectedTeamId;
  List<dynamic> _userTeams = [];
  
  @override
  void initState() {
    super.initState();
    print('DEBUG: TournamentRegistrationScreen initState called');
    // Load user teams when screen initializes
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      print('DEBUG: Loading user teams for userId: ${authState.user.id}');
      context.read<TournamentBloc>().add(LoadUserTeams(userId: authState.user.id));
    }
  }
  
  @override
  void dispose() {
    _teamNameController.dispose();
    _teamCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Register for Tournament',
          style: AppTheme.headingLarge,
        ),
      ),
      body: BlocListener<TournamentBloc, TournamentState>(
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
            // Team created successfully, add to user teams and update UI
            setState(() {
              _userTeams.add(state.team);
              _selectedTeamId = state.team.id;
              _showCreateTeamForm = false;
              _isLoadingTeams = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Team "${state.team.name}" created successfully! Now you can register for the tournament.',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is TournamentRegistrationSuccess) {
            // Check if there's a payment URL for PayPal
            if (state.response.paymentUrl != null) {
              _handlePayPalPayment(state.response.paymentUrl!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Registration successful! Check your email for confirmation.',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
              Navigator.of(context).pop();
            }
          } else if (state is TournamentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Registration failed: ${state.message}',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTournamentInfo(),
              const SizedBox(height: 24),
              _buildRegistrationForm(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTournamentInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tournament.name,
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.tournament.description,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
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
                  Icons.attach_money,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.tournament.registrationFee > 0
                      ? '${widget.tournament.registrationFee.toStringAsFixed(0)} VND'
                      : 'Free',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.tournament.registrationFee > 0
                        ? AppTheme.textPrimary
                        : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
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
          return Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang tải danh sách team...'),
              ],
            ),
          );
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registration Details',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // After loading is complete, decide what to show
              if (_userTeams.isNotEmpty && !_showCreateTeamForm)
                _buildTeamSelection(_userTeams)
              else
                Column(
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
                    const SizedBox(height: 16),
                    _buildCreateTeamForm(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSubmitButton() {
    return BlocBuilder<TournamentBloc, TournamentState>(
      builder: (context, state) {
        final isLoading = state is TournamentLoading;
        
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
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
                    _showCreateTeamForm ? 'Create Team' : 'Register Team',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
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
    return Form(
      key: _formKey,
      child: Column(
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
              if (_userTeams.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showCreateTeamForm = false;
                    });
                  },
                  child: Text(
                    'Select Existing Team',
                    style: TextStyle(color: AppTheme.primaryAccent),
                  ),
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
            controller: _teamCodeController,
            decoration: InputDecoration(
              labelText: 'Team Code',
              hintText: 'Enter your team code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.code),
            ),
            maxLines: 1,
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
            'Please login to register for tournament.',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    if (_showCreateTeamForm) {
      // Creating new team
      if (_formKey.currentState!.validate()) {
        context.read<TournamentBloc>().add(
          CreateTeam(
            name: _teamNameController.text.trim(),
            code: _teamCodeController.text.trim().isEmpty 
                ? null 
                : _teamCodeController.text.trim(),
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
              'Please select a team to register.',
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
      // Navigate to PayPal WebView instead of external browser
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PayPalWebViewHandler(
            paymentUrl: paymentUrl,
            amount: widget.tournament.registrationFee.toDouble(),
            onPaymentSuccess: (paymentId) async {
              // Handle successful payment
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Payment successful! Tournament registration completed.',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
                
                // Navigate to tournament receipt screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TournamentReceiptScreen(
                      tournament: widget.tournament,
                      paymentId: paymentId,
                      teamId: _selectedTeamId!,
                    ),
                  ),
                );
              }
            },
            onPaymentError: (error) {
              if (mounted) {
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
              }
            },
            onPaymentCancel: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Payment cancelled. Please try again.',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to open PayPal: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}