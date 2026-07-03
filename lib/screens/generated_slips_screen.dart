// lib/screens/generated_slips_screen.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/recovery_slip_model.dart';
import '../services/slip_storage_service.dart';
import 'slip_details_screen.dart';

class GeneratedSlipsScreen extends StatefulWidget {
  const GeneratedSlipsScreen({super.key});

  @override
  State<GeneratedSlipsScreen> createState() => _GeneratedSlipsScreenState();
}

class _GeneratedSlipsScreenState extends State<GeneratedSlipsScreen> {
  final _storage = SlipStorageService();
  List<RecoverySlipModel> _slips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final slips = await _storage.getAllSlips();
    // Sort newest first by generatedAt descending
    slips.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    if (mounted) setState(() { _slips = slips; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Generated Slips'),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _slips.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _slips.length,
                    itemBuilder: (context, index) =>
                        _SlipCard(slip: _slips[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 72,
              color: AppColors.softSage.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'No recovery slips generated yet.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Slips generated during the recovery flow will appear here.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.text.withValues(alpha: 0.5),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SlipCard extends StatelessWidget {
  final RecoverySlipModel slip;
  const _SlipCard({required this.slip});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(slip.recoveryType);
    final isPending = slip.status.toUpperCase().contains('PENDING');
    final statusColor = isPending ? AppColors.warning : AppColors.success;
    final displayDate = slip.generatedAt.contains('T')
        ? slip.generatedAt.split('T').first
        : slip.generatedAt;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SlipDetailsScreen(slip: slip)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: passenger + type badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      slip.passengerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _TypeBadge(type: slip.recoveryType, color: typeColor),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'PNR: ${slip.pnr}  ·  ${slip.flightNumber}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.text.withValues(alpha: 0.6),
                ),
              ),
              const Divider(height: 20),

              // Route row
              Row(
                children: [
                  const Icon(Icons.flight_takeoff, size: 16, color: AppColors.softSage),
                  const SizedBox(width: 6),
                  Text(
                    '${slip.from}  →  ${slip.to}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status + generated date row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status chip
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPending ? Icons.hourglass_top_rounded : Icons.verified_rounded,
                        size: 13,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        slip.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  _infoChip(Icons.access_time_rounded, 'Generated $displayDate'),
                ],
              ),
              const SizedBox(height: 4),
              _infoChip(Icons.calendar_today_outlined, slip.journeyDate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.text.withValues(alpha: 0.45)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.text.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Color _typeColor(String type) {
    switch (type.toUpperCase()) {
      case 'REFUND':
        return AppColors.success;
      case 'SUPPORT':
        return AppColors.primary;
      case 'REBOOK':
        return AppColors.warning;
      default:
        return AppColors.softSage;
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  final Color color;
  const _TypeBadge({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
