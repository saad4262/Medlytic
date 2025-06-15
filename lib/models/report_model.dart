import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String userId;
  final String fileName;
  final String fileUrl;
  final String extractedText;
  final String analysisResult;
  final DateTime createdAt;
  final String fileType; // 'image' or 'pdf'

  ReportModel({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.fileUrl,
    required this.extractedText,
    required this.analysisResult,
    required this.createdAt,
    required this.fileType,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      extractedText: data['extractedText'] ?? '',
      analysisResult: data['analysisResult'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      fileType: data['fileType'] ?? 'image',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'extractedText': extractedText,
      'analysisResult': analysisResult,
      'createdAt': Timestamp.fromDate(createdAt),
      'fileType': fileType,
    };
  }

  String get summary {
    if (analysisResult.isEmpty) return 'No analysis available';
    
    // Extract first meaningful line from analysis
    List<String> lines = analysisResult.split('\n');
    for (String line in lines) {
      String cleanLine = line.trim();
      if (cleanLine.isNotEmpty && 
          !cleanLine.startsWith('**') && 
          !cleanLine.startsWith('•') &&
          cleanLine.length > 20) {
        return cleanLine.length > 100 ? '${cleanLine.substring(0, 100)}...' : cleanLine;
      }
    }
    
    return 'Medical report analysis completed';
  }
}
