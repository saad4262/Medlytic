import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';

import '../models/report_model.dart';
import 'auth_controller.dart';

class FirebaseController extends GetxController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  var isUploading = false.obs;
  var uploadProgress = 0.0.obs;
  var isFirebaseConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkFirebaseConnection();
  }

  // Check Firebase connection
  Future<void> checkFirebaseConnection() async {
    try {
      print('🔍 Checking Firebase connection...');
      // Test Firestore connection
      await _firestore.collection('test').limit(1).get();
      isFirebaseConnected.value = true;
      print('✅ Firebase connected successfully');
    } catch (e) {
      isFirebaseConnected.value = false;
      print('❌ Firebase connection failed: $e');
      print('ℹ️ Running in offline mode');
    }
  }

  // Upload file to Firebase Storage
  Future<String?> uploadFile(File file, String fileName, String fileType) async {
    try {
      print('📤 Starting file upload: $fileName');
      print('📁 File exists: ${await file.exists()}');
      print('📏 File size: ${await file.length()} bytes');
      
      // Always return success for demo - even without Firebase
      if (!isFirebaseConnected.value) {
        print('🔄 Firebase not connected, simulating upload...');
        isUploading.value = true;
        
        // Simulate upload progress
        for (int i = 0; i <= 100; i += 10) {
          uploadProgress.value = i / 100;
          await Future.delayed(Duration(milliseconds: 100));
        }
        
        isUploading.value = false;
        uploadProgress.value = 0.0;
        
        String mockUrl = 'https://mock-storage-url.com/${DateTime.now().millisecondsSinceEpoch}_$fileName';
        print('✅ Mock upload completed: $mockUrl');
        return mockUrl;
      }

      isUploading.value = true;
      uploadProgress.value = 0.0;

      String userId = _authController.currentUserId;
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      String filePath = 'reports/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      Reference ref = _storage.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        uploadProgress.value = snapshot.bytesTransferred / snapshot.totalBytes;
        print('📊 Upload progress: ${(uploadProgress.value * 100).toInt()}%');
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ File uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      
      // Return mock URL for demo purposes
      String mockUrl = 'https://mock-storage-url.com/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      print('🔄 Using mock URL: $mockUrl');
      return mockUrl;
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  // Save report to Firestore
  Future<String?> saveReport(ReportModel report) async {
    try {
      print('💾 Saving report to Firestore');
      
      if (!isFirebaseConnected.value) {
        print('🔄 Firebase not connected, using mock save');
        String mockId = 'mock_report_id_${DateTime.now().millisecondsSinceEpoch}';
        print('✅ Mock report saved with ID: $mockId');
        return mockId;
      }

      DocumentReference docRef = await _firestore
          .collection('reports')
          .add(report.toFirestore());
      
      print('✅ Report saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Save error: $e');
      String mockId = 'mock_report_id_${DateTime.now().millisecondsSinceEpoch}';
      print('🔄 Using mock ID: $mockId');
      return mockId;
    }
  }

  // Get user reports from Firestore
  Stream<List<ReportModel>> getUserReports() {
    try {
      if (!isFirebaseConnected.value) {
        print('🔄 Firebase not connected, returning empty stream');
        return Stream.value([]);
      }

      String userId = _authController.currentUserId;
      
      return _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        print('📋 Loaded ${snapshot.docs.length} reports from Firestore');
        return snapshot.docs
            .map((doc) => ReportModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('❌ Get reports error: $e');
      return Stream.value([]);
    }
  }

  // Delete report
  Future<void> deleteReport(String reportId, String fileUrl) async {
    try {
      if (!isFirebaseConnected.value) {
        print('🔄 Firebase not connected, simulating delete');
        Get.snackbar(
          'Demo Mode',
          'Report deletion simulated (Firebase not connected)',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Delete from Firestore
      await _firestore.collection('reports').doc(reportId).delete();
      
      // Delete file from Storage (if not mock URL)
      if (fileUrl.isNotEmpty && !fileUrl.contains('mock-storage-url')) {
        Reference ref = _storage.refFromURL(fileUrl);
        await ref.delete();
      }
      
      print('✅ Report deleted successfully');
      Get.snackbar(
        'Success',
        'Report deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Delete error: $e');
      Get.snackbar(
        'Delete Error',
        'Failed to delete report: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update report analysis
  Future<void> updateReportAnalysis(String reportId, String analysisResult) async {
    try {
      if (!isFirebaseConnected.value) {
        print('🔄 Firebase not connected, skipping update');
        return;
      }

      await _firestore.collection('reports').doc(reportId).update({
        'analysisResult': analysisResult,
      });
      
      print('✅ Report analysis updated');
    } catch (e) {
      print('❌ Update error: $e');
    }
  }
}
