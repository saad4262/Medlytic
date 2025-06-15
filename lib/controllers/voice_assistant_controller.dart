// import 'package:get/get.dart';
//
// import '../services/voice_assistant_service.dart';
//
// class VoiceAssistantController extends GetxController {
//   final VoiceAssistantService _voiceService = VoiceAssistantService();
//
//   final isPlaying = false.obs;
//   final isPaused = false.obs;
//   final currentWord = ''.obs;
//   final isInitialized = false.obs;
//
//   // Settings
//   final volume = 1.0.obs;
//   final pitch = 1.0.obs;
//   final rate = 0.5.obs;
//   final language = 'en-US'.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _initVoiceAssistant();
//   }
//
//   Future<void> _initVoiceAssistant() async {
//     try {
//       print('🎤 Initializing voice assistant controller...');
//       isInitialized.value = _voiceService.isInitialized;
//
//       // Set up listeners
//       ever(_voiceService.currentWordObs, (word) {
//         currentWord.value = word;
//       });
//
//       // Initialize settings from service
//       volume.value = _voiceService.volume;
//       pitch.value = _voiceService.pitch;
//       rate.value = _voiceService.rate;
//       if (_voiceService.language != null) {
//         language.value = _voiceService.language!;
//       }
//
//       print('✅ Voice assistant controller initialized');
//     } catch (e) {
//       print('❌ Error initializing voice assistant controller: $e');
//     }
//   }
//
//   Future<void> speak(String text) async {
//     try {
//       if (text.isEmpty) {
//         print('❌ Cannot speak empty text');
//         return;
//       }
//
//       print('🎤 Speaking text of length: ${text.length}');
//       await _voiceService.speak(text);
//       isPlaying.value = true;
//       isPaused.value = false;
//
//       // Update status when speech completes
//       _voiceService.flutterTts.setCompletionHandler(() {
//         isPlaying.value = false;
//         isPaused.value = false;
//         currentWord.value = '';
//       });
//
//       // Update status when speech is cancelled
//       _voiceService.flutterTts.setCancelHandler(() {
//         isPlaying.value = false;
//         isPaused.value = false;
//         currentWord.value = '';
//       });
//     } catch (e) {
//       print('❌ Error in voice controller speak: $e');
//     }
//   }
//
//   Future<void> stop() async {
//     if (!isInitialized.value) return;
//
//     await _voiceService.stop();
//     isPlaying.value = false;
//     isPaused.value = false;
//     currentWord.value = '';
//   }
//
//   Future<void> pause() async {
//     if (!isInitialized.value) return;
//
//     if (isPlaying.value && !isPaused.value) {
//       // Pause the speech
//       await _voiceService.pause();
//       isPaused.value = true;
//       print('🎤 Voice paused');
//     } else if (isPaused.value) {
//       // Resume the speech
//       await _voiceService.resume();
//       isPaused.value = false;
//       print('🎤 Voice resumed');
//     }
//   }
//
//   Future<void> setVolume(double value) async {
//     volume.value = value;
//     await _voiceService.setVolume(value);
//   }
//
//   Future<void> setPitch(double value) async {
//     pitch.value = value;
//     await _voiceService.setPitch(value);
//   }
//
//   Future<void> setRate(double value) async {
//     rate.value = value;
//     await _voiceService.setRate(value);
//   }
//
//   Future<void> setLanguage(String lang) async {
//     language.value = lang;
//     await _voiceService.setLanguage(lang);
//   }
//
//   List<String> get availableLanguages => _voiceService.availableLanguages;
//
//   @override
//   void onClose() {
//     _voiceService.dispose();
//     super.onClose();
//   }
// }

import 'dart:async';

import 'package:get/get.dart';

import '../services/voice_assistant_service.dart';

class VoiceAssistantController extends GetxController {
  final VoiceAssistantService _voiceService = VoiceAssistantService();

  final isPlaying = false.obs;
  final isPaused = false.obs;
  final currentWord = ''.obs;
  final isInitialized = false.obs;

  // Settings
  final volume = 1.0.obs;
  final pitch = 1.0.obs;
  final rate = 0.5.obs;
  final language = 'en-US'.obs;

  @override
  void onInit() {
    super.onInit();
    _initVoiceAssistant();
  }

  Future<void> _initVoiceAssistant() async {
    try {
      print('🎤 Initializing voice assistant controller...');

      // Set up listeners for real-time updates
      ever(_voiceService.currentWordObs, (word) {
        currentWord.value = word;
      });

      // Monitor TTS state changes
      Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (_voiceService.isPlaying && !isPlaying.value) {
          isPlaying.value = true;
          isPaused.value = false;
        } else if (_voiceService.isStopped && isPlaying.value) {
          isPlaying.value = false;
          isPaused.value = false;
          currentWord.value = '';
        } else if (_voiceService.isPaused && !isPaused.value) {
          isPaused.value = true;
        }
      });

      isInitialized.value = _voiceService.isInitialized;
      print('✅ Voice assistant controller initialized');
    } catch (e) {
      print('❌ Error initializing voice assistant controller: $e');
    }
  }

  Future<void> speak(String text) async {
    try {
      if (text.isEmpty) {
        print('❌ Cannot speak empty text');
        return;
      }

      print('🎤 Controller: Starting speech');
      await _voiceService.speak(text);

      // Force update state
      isPlaying.value = true;
      isPaused.value = false;

    } catch (e) {
      print('❌ Error in voice controller speak: $e');
    }
  }

  Future<void> stop() async {
    print('🎤 Controller: Stopping speech');
    await _voiceService.forceStop();

    // Force update state immediately
    isPlaying.value = false;
    isPaused.value = false;
    currentWord.value = '';
  }

  Future<void> pause() async {
    if (isPlaying.value && !isPaused.value) {
      await _voiceService.pause();
      isPaused.value = true;
    }
  }

  Future<void> setVolume(double value) async {
    volume.value = value;
    await _voiceService.setVolume(value);
  }

  Future<void> setPitch(double value) async {
    pitch.value = value;
    await _voiceService.setPitch(value);
  }

  Future<void> setRate(double value) async {
    rate.value = value;
    await _voiceService.setRate(value);
  }

  Future<void> setLanguage(String lang) async {
    language.value = lang;
    await _voiceService.setLanguage(lang);
  }

  List<String> get availableLanguages => _voiceService.availableLanguages;

  @override
  void onClose() {
    _voiceService.dispose();
    super.onClose();
  }
}

