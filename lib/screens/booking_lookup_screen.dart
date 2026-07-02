// lib/screens/booking_lookup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recovery_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/primary_button.dart';
import '../widgets/recent_search_card.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import 'journey_status_screen.dart';

class BookingLookupScreen extends StatefulWidget {
  const BookingLookupScreen({super.key});

  @override
  State<BookingLookupScreen> createState() => _BookingLookupScreenState();
}

class _BookingLookupScreenState extends State<BookingLookupScreen> {
  final _pnrController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _pnrController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _search() async {
    final pnr = _pnrController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (pnr.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both fields are required')),
      );
      return;
    }
    final provider = context.read<RecoveryProvider>();
    final success = await provider.lookupBooking(pnr, lastName);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const JourneyStatusScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Lookup failed')),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppColors.text.withValues(alpha: 0.55),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: AppColors.softSage, size: 20),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.softSage.withValues(alpha: 0.4),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.softSage.withValues(alpha: 0.4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecoveryProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(AppStrings.appTitle),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page title
            const Text(
              'Flight Recovery Assistance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lookup your disrupted booking and continue with rebooking, refund, or support options.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Lookup form card
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your booking details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _pnrController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _inputDecoration(
                      label: 'PNR / Booking Reference',
                      icon: Icons.confirmation_number_outlined,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      label: 'Last Name',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    text: AppStrings.findTrip,
                    isLoading: provider.isLoading,
                    onPressed: _search,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Recent searches section
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: AppColors.text.withValues(alpha: 0.45),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.recentSearches,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text.withValues(alpha: 0.75),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (provider.recentSearches.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 28),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 36,
                      color: AppColors.softSage.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.noRecent,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.text.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: provider.recentSearches
                    .map((search) => RecentSearchCard(
                          search: search,
                          onTap: () async {
                            final success = await provider.lookupFromRecent(search);
                            if (!context.mounted) return;
                            if (success) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const JourneyStatusScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(provider.errorMessage ?? 'Lookup failed')),
                              );
                            }
                          },
                        ))
                    .toList(),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
