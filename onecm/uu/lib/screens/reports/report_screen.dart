import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uu/providers/baby_provider.dart';
import 'package:uu/providers/report_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  bool _generatingDoctor = false;
  bool _generatingHandoff = false;

  @override
  Widget build(BuildContext context) {
    final babyId = ref.watch(selectedBabyIdProvider);
    if (babyId == null) {
      return const Scaffold(
        body: Center(child: Text('Please select a baby first.')),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Doctor Visit Report Card ──
          _ReportCard(
            icon: Icons.medical_services_outlined,
            iconColor: Colors.teal,
            title: 'Doctor Visit Report',
            description:
                'Generate a one-page PDF summary for your pediatrician. '
                'Includes growth data, vaccinations, health events, and milestones.',
            isLoading: _generatingDoctor,
            onTap: _generateDoctorReport,
          ),
          const SizedBox(height: 16),

          // ── Caregiver Handoff Card ──
          _ReportCard(
            icon: Icons.people_outline,
            iconColor: Colors.indigo,
            title: 'Caregiver Handoff',
            description:
                'Generate shareable notes for a caregiver or babysitter. '
                'Includes feeding schedule, sleep patterns, medications, and contacts.',
            isLoading: _generatingHandoff,
            onTap: _generateCaregiverHandoff,
          ),
        ],
      ),
    );
  }

  Future<void> _generateDoctorReport() async {
    setState(() => _generatingDoctor = true);

    try {
      final pdfBytes = await ref.read(doctorReportProvider.future);
      if (pdfBytes == null || !mounted) return;

      await _showPdfPreview(pdfBytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingDoctor = false);
    }
  }

  Future<void> _showPdfPreview(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: 'doctor_visit_report.pdf',
    );
  }

  Future<void> _generateCaregiverHandoff() async {
    setState(() => _generatingHandoff = true);

    try {
      final text = await ref.read(caregiverHandoffProvider.future);
      if (text == null || !mounted) return;

      await _showHandoffPreview(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating handoff notes: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingHandoff = false);
    }
  }

  Future<void> _showHandoffPreview(String text) async {
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Caregiver Notes',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          SharePlus.instance.share(ShareParams(text: text));
                        },
                        tooltip: 'Share',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  text,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Report Card ──────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isLoading;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
