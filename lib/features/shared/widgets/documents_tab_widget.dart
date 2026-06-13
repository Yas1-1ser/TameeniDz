import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tameenidz/generated/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tameenidz/core/theme/app_colors.dart';
import 'package:tameenidz/core/theme/app_colors_extension.dart';

class DocumentsTabWidget extends StatefulWidget {
  final String? clientId;
  final String? operatorId;
  final bool isAdmin;

  const DocumentsTabWidget({
    super.key,
    this.clientId,
    this.operatorId,
    this.isAdmin = false,
  });

  @override
  State<DocumentsTabWidget> createState() => _DocumentsTabWidgetState();
}

class _DocumentsTabWidgetState extends State<DocumentsTabWidget> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    _future = _fetchDocuments();
  }

  Future<List<Map<String, dynamic>>> _fetchDocuments() async {
    var query = supabase.from('policies').select();

    if (widget.clientId != null) {
      query = query.eq('client_id', widget.clientId!);
    } else if (widget.operatorId != null) {
      query = query.eq('operator_id', widget.operatorId!);
    } else if (!widget.isAdmin) {
      return [];
    }

    final response = await query.order('submitted_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }
        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        final docs = snapshot.data ?? [];

        return Column(
          children: [
            _buildHeader(docs),
            Expanded(
              child:
                  docs.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: 12,
                        ),
                        itemCount: docs.length,
                        itemBuilder:
                            (context, index) => _buildDocumentCard(docs[index]),
                      ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(List<Map<String, dynamic>> docs) {
    final total = docs.length;
    final completed =
        docs
            .where(
              (d) =>
                  d['status']?.toString().toLowerCase() == 'accepted' ||
                  d['status']?.toString().toLowerCase() == 'paid',
            )
            .length;
    final pendingCount = total - completed;

    return Container(
      width: double.infinity,
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            AppLocalizations.of(context)!.totalDocuments,
            total.toString(),
          ),
          _buildDivider(),
          _buildStat(
            AppLocalizations.of(context)!.completed,
            completed.toString(),
          ),
          _buildDivider(),
          _buildStat(
            AppLocalizations.of(context)!.pending,
            pendingCount.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: context.colors.slate100,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.colors.slate100.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: AppColors.accentGold.withValues(alpha: 0.5),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final name =
        doc['plan_name'] ??
        doc['plan_id'] ??
        AppLocalizations.of(context)!.insuranceDocument;
    final dateStr = doc['submitted_at'] ?? doc['created_at'];
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    final status = doc['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.offWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.slate200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.accentGold,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.accentGold,
                  size: 26,
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.colors.darkText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'd MMMM yyyy',
                        Localizations.localeOf(context).toString(),
                      ).format(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.slate500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBadge(status),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconBtn(
                    Icons.download_rounded,
                    AppLocalizations.of(context)!.download,
                    () => _handleDocumentAction(doc),
                  ),
                  SizedBox(height: 6),
                  _buildIconBtn(
                    Icons.visibility_outlined,
                    AppLocalizations.of(context)!.view,
                    () => _handleDocumentAction(doc),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'accepted':
      case 'paid':
        badgeColor = AppColors.primaryGreen;
        textColor = context.colors.slate100;
        label = AppLocalizations.of(context)!.statusAccepted;
        break;
      case 'rejected':
        badgeColor = AppColors.rejected;
        textColor = Colors.white;
        label = AppLocalizations.of(context)!.statusRejected;
        break;
      default:
        badgeColor = AppColors.accentGold;
        textColor = context.colors.darkText;
        label = AppLocalizations.of(context)!.statusPending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
      ),
    );
  }

  Future<void> _handleDocumentAction(Map<String, dynamic> doc) async {
    final List<Map<String, String>> availableDocs = [];
    final l10n = AppLocalizations.of(context)!;

    if (doc['receipt_url'] != null && doc['receipt_url'].toString().isNotEmpty) {
      availableDocs.add({'label': l10n.paymentReceiptLabel, 'url': doc['receipt_url']});
    }

    if (doc['document_urls'] != null) {
      final docs = doc['document_urls'] as List<dynamic>;
      for (var d in docs) {
        if (d is Map<String, dynamic> && d['url'] != null) {
          availableDocs.add({
            'label': d['label']?.toString() ?? l10n.documents,
            'url': d['url'].toString(),
          });
        }
      }
    }
    
    if (doc['pdf_url'] != null && doc['pdf_url'].toString().isNotEmpty) {
      availableDocs.add({'label': 'PDF Document', 'url': doc['pdf_url']});
    }
    if (doc['document_url'] != null && doc['document_url'].toString().isNotEmpty && doc['document_urls'] == null) {
      availableDocs.add({'label': 'Document', 'url': doc['document_url']});
    }

    if (availableDocs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noDocumentsAvailableForRequest)),
      );
      return;
    }

    if (availableDocs.length == 1) {
      _openSignedUrl(availableDocs.first['url']!);
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.chooseDocumentToPreview, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...availableDocs.map((d) => ListTile(
                    leading: const Icon(Icons.file_present_rounded, color: AppColors.primaryGreen),
                    title: Text(d['label']!),
                    onTap: () {
                      Navigator.pop(context);
                      _openSignedUrl(d['url']!);
                    },
                  )),
                ],
              ),
            ),
          );
        }
      );
    }
  }

  Future<void> _openSignedUrl(String urlOrPath) async {
    try {
      String finalUrl = urlOrPath;
      String path = urlOrPath;
      if (path.contains('/storage/v1/object/public/documents/')) {
        path = path.split('/storage/v1/object/public/documents/').last;
      } else if (path.contains('/storage/v1/object/sign/documents/')) {
        path = path.split('/storage/v1/object/sign/documents/').last.split('?').first;
      }

      if (!path.startsWith('http')) {
        finalUrl = await supabase.storage
            .from('documents')
            .createSignedUrl(path, 60);
      }

      final url = Uri.parse(finalUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.downloadError} ${e.toString()}'),
        ),
      );
    }
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.folder_open_outlined,
          size: 80,
          color: AppColors.accentGold.withValues(alpha: 0.5),
        ),
        SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.noDocumentsYet,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.colors.darkText,
          ),
        ),
        SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.documentsAppearHere,
          style: TextStyle(fontSize: 14, color: context.colors.slate500),
        ),
      ],
    ),
  );

  Widget _buildError(String error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 56, color: AppColors.rejected),
        SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.errorLoadingDocuments,
          style: TextStyle(color: context.colors.darkText, fontSize: 16),
        ),
        SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
          ),
          onPressed: () => setState(() => _fetch()),
          child: Text(
            AppLocalizations.of(context)!.retry,
            style: TextStyle(color: context.colors.slate100),
          ),
        ),
      ],
    ),
  );
}
