// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
//
// import '../controllers/app_controller.dart';
// import '../controllers/voice_assistant_controller.dart';
// import '../models/report_model.dart';
// import '../theme/app_theme.dart';
// import '../widgets/empty_state.dart';
// import '../widgets/history_card.dart';
// import '../widgets/premium_card.dart';
// import '../widgets/voice_assistant_button.dart';
//
//
// class HistoryScreen extends StatelessWidget {
//   HistoryScreen({Key? key}) : super(key: key);
//
//   final AppController controller = Get.find<AppController>();
//   final VoiceAssistantController voiceController = Get.find<VoiceAssistantController>();
//   final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: AppTheme.backgroundGradient,
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Custom App Bar
//               Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Row(
//                   children: [
//                     // Container(
//                     //   decoration: BoxDecoration(
//                     //     color: AppTheme.surfaceColor,
//                     //     borderRadius: BorderRadius.circular(12),
//                     //     boxShadow: AppTheme.cardShadow,
//                     //   ),
//                     //   child: IconButton(
//                     //     icon: const Icon(Icons.arrow_back_rounded),
//                     //     onPressed: () => Get.back(),
//                     //     color: AppTheme.textPrimary,
//                     //   ),
//                     // ),
//                     const SizedBox(width: 50),
//                     const Expanded(
//                       child: Text(
//                         'Report History',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w700,
//                           color: AppTheme.textPrimary,
//                         ),
//                       ),
//                     ),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: AppTheme.surfaceColor,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: AppTheme.cardShadow,
//                       ),
//                       child: IconButton(
//                         icon: const Icon(Icons.refresh_rounded),
//                         onPressed: () {
//                           controller.loadReportHistory();
//                           Get.snackbar(
//                             'Refreshed',
//                             'Report history has been updated',
//                             snackPosition: SnackPosition.BOTTOM,
//                             backgroundColor: AppTheme.successColor.withOpacity(0.1),
//                             colorText: AppTheme.successColor,
//                             duration: const Duration(seconds: 2),
//                           );
//                         },
//                         color: AppTheme.primaryColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Content
//               Expanded(
//                 child: Obx(() {
//                   if (controller.reportHistory.isEmpty) {
//                     return EmptyState(
//                       icon: Icons.history_rounded,
//                       title: 'No Reports Yet',
//                       subtitle: 'Your analyzed medical reports will appear here. Upload your first report to get started!',
//                       buttonText: 'Upload Report',
//                       onButtonPressed: () {
//                         Get.back();
//                         // Small delay to ensure navigation is complete
//                         Future.delayed(const Duration(milliseconds: 100), () {
//                           // Scroll to upload section or trigger upload
//                         });
//                       },
//                     );
//                   }
//
//                   return RefreshIndicator(
//                     onRefresh: () async {
//                       controller.loadReportHistory();
//                       await Future.delayed(const Duration(seconds: 1));
//                     },
//                     color: AppTheme.primaryColor,
//                     child: ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                       itemCount: controller.reportHistory.length,
//                       itemBuilder: (context, index) {
//                         final report = controller.reportHistory[index];
//                         return HistoryCard(
//                           report: report,
//                           onTap: () => _showReportDetails(context, report),
//                           onDelete: () => _showDeleteDialog(context, report),
//                         );
//                       },
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showReportDetails(BuildContext context, ReportModel report) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.7,
//           maxChildSize: 0.95,
//           minChildSize: 0.5,
//           builder: (context, scrollController) {
//             return Container(
//               decoration: const BoxDecoration(
//                 color: AppTheme.surfaceColor,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//               ),
//               child: Column(
//                 children: [
//                   // Handle
//                   Container(
//                     margin: const EdgeInsets.only(top: 12),
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//
//                   // Header
//                   Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: _getFileTypeColor(report.fileType).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(
//                             _getFileTypeIcon(report.fileType),
//                             color: _getFileTypeColor(report.fileType),
//                             size: 24,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 report.fileName,
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                   color: AppTheme.textPrimary,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 dateFormat.format(report.createdAt),
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: AppTheme.textSecondary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () => Get.back(),
//                           icon: const Icon(Icons.close_rounded),
//                           color: AppTheme.textSecondary,
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Content
//                   Expanded(
//                     child: SingleChildScrollView(
//                       controller: scrollController,
//                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Analysis Section
//                           PremiumCard(
//                             margin: const EdgeInsets.only(bottom: 16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: BoxDecoration(
//                                         color: AppTheme.accentColor.withOpacity(0.1),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: const Icon(
//                                         Icons.analytics_rounded,
//                                         color: AppTheme.accentColor,
//                                         size: 20,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 12),
//                                     const Text(
//                                       'AI Analysis',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w600,
//                                         color: AppTheme.textPrimary,
//                                       ),
//                                     ),
//                                     const Spacer(),
//                                     VoiceAssistantButton(
//                                       text: report.analysisResult,
//                                       size: 36,
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: AppTheme.cardColor,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(
//                                       color: Colors.grey.shade200,
//                                     ),
//                                   ),
//                                   child: report.analysisResult.isNotEmpty
//                                       ? Markdown(
//                                     data: report.analysisResult,
//                                     shrinkWrap: true,
//                                     physics: const NeverScrollableScrollPhysics(),
//                                     styleSheet: MarkdownStyleSheet(
//                                       p: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.textPrimary),
//                                       h1: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
//                                       h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
//                                       h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
//                                       strong: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
//                                       em: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textPrimary),
//                                       listBullet: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
//                                     ),
//                                   )
//                                       : const Text(
//                                     'No analysis available for this report.',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       height: 1.6,
//                                       color: AppTheme.textPrimary,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           // Extracted Text Section
//                           if (report.extractedText.isNotEmpty)
//                             PremiumCard(
//                               margin: const EdgeInsets.only(bottom: 24),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Container(
//                                         padding: const EdgeInsets.all(8),
//                                         decoration: BoxDecoration(
//                                           color: AppTheme.primaryColor.withOpacity(0.1),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         child: const Icon(
//                                           Icons.text_snippet_rounded,
//                                           color: AppTheme.primaryColor,
//                                           size: 20,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       const Text(
//                                         'Extracted Text',
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w600,
//                                           color: AppTheme.textPrimary,
//                                         ),
//                                       ),
//                                       const Spacer(),
//                                       VoiceAssistantButton(
//                                         text: report.extractedText,
//                                         size: 36,
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Container(
//                                     padding: const EdgeInsets.all(16),
//                                     decoration: BoxDecoration(
//                                       color: AppTheme.cardColor,
//                                       borderRadius: BorderRadius.circular(12),
//                                       border: Border.all(
//                                         color: Colors.grey.shade200,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       report.extractedText,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         height: 1.6,
//                                         color: AppTheme.textPrimary,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   // Action buttons
//                   Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton.icon(
//                             onPressed: () {
//                               // Implement share functionality
//                               Get.snackbar(
//                                 'Share',
//                                 'Share functionality will be implemented',
//                                 snackPosition: SnackPosition.BOTTOM,
//                               );
//                             },
//                             icon: const Icon(Icons.share_rounded),
//                             label: const Text('Share'),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () {
//                               Get.back();
//                               _showDeleteDialog(context, report);
//                             },
//                             icon: const Icon(Icons.delete_outline_rounded),
//                             label: const Text('Delete'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppTheme.errorColor,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   void _showDeleteDialog(BuildContext context, ReportModel report) {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Text(
//           'Delete Report',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         content: Text(
//           'Are you sure you want to delete "${report.fileName}"? This action cannot be undone.',
//           style: const TextStyle(
//             fontSize: 16,
//             color: AppTheme.textSecondary,
//             height: 1.5,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(
//                 color: AppTheme.textSecondary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.errorColor,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: () {
//               Get.back();
//               controller.deleteReport(report);
//             },
//             child: const Text(
//               'Delete',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Color _getFileTypeColor(String fileType) {
//     switch (fileType.toLowerCase()) {
//       case 'pdf':
//         return AppTheme.errorColor;
//       case 'image':
//         return AppTheme.primaryColor;
//       default:
//         return AppTheme.textSecondary;
//     }
//   }
//
//   IconData _getFileTypeIcon(String fileType) {
//     switch (fileType.toLowerCase()) {
//       case 'pdf':
//         return Icons.picture_as_pdf_rounded;
//       case 'image':
//         return Icons.image_rounded;
//       default:
//         return Icons.insert_drive_file_rounded;
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/app_controller.dart';
import '../controllers/voice_assistant_controller.dart';
import '../models/report_model.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/history_card.dart';
import '../widgets/premium_card.dart';
import '../widgets/voice_assistant_button.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({Key? key}) : super(key: key);

  final AppController controller = Get.find<AppController>();
  final VoiceAssistantController voiceController = Get.find<VoiceAssistantController>();
  final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Report History',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              controller.loadReportHistory();
              Get.snackbar(
                'Refreshed',
                'Report history updated successfully.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.successColor.withOpacity(0.9),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
              );
            },
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Your Analyzed Reports',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'View and manage your medical report history.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.reportHistory.isEmpty) {
                    return EmptyState(
                      icon: Icons.history_rounded,
                      title: 'No Reports Yet',
                      subtitle: 'Your analyzed medical reports will appear here. Upload your first report to get started!',
                      buttonText: 'Upload Report',
                      onButtonPressed: () {
                        Get.back();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          // Scroll to upload section or trigger upload
                        });
                      },
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      controller.loadReportHistory();
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    color: AppTheme.primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemCount: controller.reportHistory.length,
                      itemBuilder: (context, index) {
                        final report = controller.reportHistory[index];
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: HistoryCard(
                            report: report,
                            onTap: () => _showReportDetails(context, report),
                            onDelete: () => _showDeleteDialog(context, report),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetails(BuildContext context, ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getFileTypeColor(report.fileType).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getFileTypeIcon(report.fileType),
                            color: _getFileTypeColor(report.fileType),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.fileName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                dateFormat.format(report.createdAt),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary.withOpacity(0.8),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close_rounded, size: 28),
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Analysis Section
                          PremiumCard(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.analytics_rounded,
                                        color: AppTheme.accentColor,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'AI Analysis',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    VoiceAssistantButton(
                                      text: report.analysisResult,
                                      size: 40,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: report.analysisResult.isNotEmpty
                                      ? Markdown(
                                    data: report.analysisResult,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.textPrimary),
                                      h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                      h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                      h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                      strong: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                      em: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textPrimary),
                                      listBullet: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
                                    ),
                                  )
                                      : const Text(
                                    'No analysis available for this report.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Extracted Text Section
                          if (report.extractedText.isNotEmpty)
                            PremiumCard(
                              margin: const EdgeInsets.only(bottom: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.text_snippet_rounded,
                                          color: AppTheme.primaryColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Extracted Text',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const Spacer(),
                                      VoiceAssistantButton(
                                        text: report.extractedText,
                                        size: 40,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      report.extractedText,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.6,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Get.snackbar(
                                'Share',
                                'Share functionality will be implemented',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                                borderRadius: 12,
                                margin: const EdgeInsets.all(16),
                              );
                            },
                            icon: const Icon(Icons.share_rounded, size: 22),
                            label: const Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.back();
                              _showDeleteDialog(context, report);
                            },
                            icon: const Icon(Icons.delete_outline_rounded, size: 22),
                            label: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                              shadowColor: AppTheme.errorColor.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ReportModel report) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Delete Report',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${report.fileName}"? This action cannot be undone.',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary.withOpacity(0.8),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 3,
            ),
            onPressed: () {
              Get.back();
              controller.deleteReport(report);
              Get.snackbar(
                'Deleted',
                'Report "${report.fileName}" deleted successfully.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.errorColor.withOpacity(0.9),
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return AppTheme.errorColor;
      case 'image':
        return AppTheme.primaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'image':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}