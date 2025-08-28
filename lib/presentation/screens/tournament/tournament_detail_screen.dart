import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tournament_model.dart';
import '../../bloc/tournament/tournament_bloc.dart';
import '../../bloc/tournament/tournament_event.dart';
import '../../bloc/tournament/tournament_state.dart';
import 'tournament_registration_screen.dart';

class TournamentDetailScreen extends StatefulWidget {
  final String tournamentSlug;
  
  const TournamentDetailScreen({
    super.key,
    required this.tournamentSlug,
  });

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TournamentBloc>().add(LoadTournamentBySlug(slug: widget.tournamentSlug));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: BlocBuilder<TournamentBloc, TournamentState>(
        builder: (context, state) {
          if (state is TournamentLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is TournamentError) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: AppTheme.scaffoldBackground,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading tournament',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: AppTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TournamentBloc>().add(
                          LoadTournamentBySlug(slug: widget.tournamentSlug),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (state is TournamentDetailLoaded) {
            return _buildTournamentDetail(state.tournament);
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
  
  Widget _buildTournamentDetail(TournamentModel tournament) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primaryAccent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                tournament.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryAccent,
                      AppTheme.primaryAccent.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: tournament.image != null
                    ? Image.network(
                        tournament.image!,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(tournament),
                  const SizedBox(height: 16),
                  _buildInfoCard(tournament),
                  const SizedBox(height: 16),
                  _buildDescriptionCard(tournament),
                  if (tournament.rules != null) ...[
                    const SizedBox(height: 16),
                    _buildRulesCard(tournament),
                  ],
                  if (tournament.prizes != null) ...[
                    const SizedBox(height: 16),
                    _buildPrizesCard(tournament),
                  ],
                  const SizedBox(height: 100), // Space for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: tournament.status.toLowerCase() == 'upcoming' &&
              tournament.currentTeams < tournament.maxTeams
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/tournament-registration',
                  arguments: {'tournament': tournament},
                );
              },
              backgroundColor: AppTheme.primaryAccent,
              icon: const Icon(Icons.app_registration, color: Colors.white),
              label: const Text(
                'Register',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
  
  Widget _buildStatusCard(TournamentModel tournament) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(tournament.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(tournament.status).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                tournament.status.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(tournament.status),
                ),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Teams',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  '${tournament.currentTeams}/${tournament.maxTeams}',
                  style: AppTheme.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(TournamentModel tournament) {
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
              'Tournament Information',
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              'Start Date',
              _formatDate(tournament.startDate),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.event,
              'End Date',
              _formatDate(tournament.endDate),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Registration Deadline',
              tournament.registrationDeadline != null 
                  ? _formatDate(tournament.registrationDeadline!) 
                  : 'Not specified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.attach_money,
              'Registration Fee',
              tournament.registrationFee > 0
                  ? '${tournament.registrationFee.toStringAsFixed(0)} VND'
                  : 'Free',
            ),
            if (tournament.location != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.location_on,
                'Location',
                tournament.location!,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDescriptionCard(TournamentModel tournament) {
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
              'Description',
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tournament.description,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRulesCard(TournamentModel tournament) {
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
              'Rules & Regulations',
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tournament.rules!,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPrizesCard(TournamentModel tournament) {
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
              'Prizes',
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tournament.prizes != null 
                  ? '${tournament.prizes!} VND' 
                  : 'Not specified',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}