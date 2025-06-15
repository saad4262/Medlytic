// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
//
// enum TtsState { playing, stopped, paused, continued }
//
// class VoiceAssistantService {
//   FlutterTts flutterTts = FlutterTts();
//   TtsState ttsState = TtsState.stopped;
//
//   double volume = 1.0;
//   double pitch = 1.0;
//   double rate = 0.5; // Slower rate for better comprehension
//   String? language = 'en-US';
//   String? engine;
//   String? voice;
//
//   // Store current text for pause/resume functionality
//   String _currentText = '';
//   int _currentPosition = 0;
//
//   bool get isPlaying => ttsState == TtsState.playing;
//   bool get isStopped => ttsState == TtsState.stopped;
//   bool get isPaused => ttsState == TtsState.paused;
//
//   final currentWordObs = ''.obs;
//   String get currentWord => currentWordObs.value;
//
//   final _isInitialized = false.obs;
//   bool get isInitialized => _isInitialized.value;
//
//   final _availableVoices = <Map<String, String>>[].obs;
//   List<Map<String, String>> get availableVoices => _availableVoices;
//
//   final _availableLanguages = <String>[].obs;
//   List<String> get availableLanguages => _availableLanguages;
//
//   VoiceAssistantService() {
//     _initTts();
//   }
//
//   Future<void> _initTts() async {
//     try {
//       print('🔊 Initializing voice assistant...');
//
//       // Initialize TTS engine
//       await flutterTts.setSharedInstance(true);
//
//       // Set default language
//       if (await flutterTts.isLanguageAvailable(language!) == false) {
//         // If preferred language is not available, use default
//         final languages = await flutterTts.getLanguages;
//         if (languages is List && languages.isNotEmpty) {
//           language = languages.first.toString();
//           print('🔊 Default language not available, using: $language');
//         }
//       }
//
//       // Configure TTS settings
//       await flutterTts.setVolume(volume);
//       await flutterTts.setPitch(pitch);
//       await flutterTts.setSpeechRate(rate);
//       await flutterTts.setLanguage(language!);
//
//       // iOS-specific settings
//       if (!kIsWeb) {
//         try {
//           await flutterTts.setIosAudioCategory(
//             IosTextToSpeechAudioCategory.playback,
//             [
//               IosTextToSpeechAudioCategoryOptions.allowBluetooth,
//               IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
//               IosTextToSpeechAudioCategoryOptions.mixWithOthers,
//             ],
//             IosTextToSpeechAudioMode.defaultMode,
//           );
//         } catch (e) {
//           print('⚠️ iOS audio category setup failed: $e');
//         }
//       }
//
//       // Get available voices
//       try {
//         final voices = await flutterTts.getVoices;
//         if (voices is List && voices.isNotEmpty) {
//           for (var voice in voices) {
//             if (voice is Map) {
//               _availableVoices.add({
//                 'name': voice['name'] ?? '',
//                 'locale': voice['locale'] ?? '',
//               });
//             }
//           }
//           print('🔊 Found ${_availableVoices.length} available voices');
//         }
//       } catch (e) {
//         print('❌ Failed to get voices: $e');
//       }
//
//       // Get available languages
//       try {
//         final languages = await flutterTts.getLanguages;
//         if (languages is List && languages.isNotEmpty) {
//           for (var lang in languages) {
//             _availableLanguages.add(lang.toString());
//           }
//           print('🔊 Found ${_availableLanguages.length} available languages');
//         }
//       } catch (e) {
//         print('❌ Failed to get languages: $e');
//       }
//
//       // Set callbacks
//       flutterTts.setStartHandler(() {
//         print('🔊 TTS Started');
//         ttsState = TtsState.playing;
//       });
//
//       flutterTts.setCompletionHandler(() {
//         print('🔊 TTS Completed');
//         ttsState = TtsState.stopped;
//         currentWordObs.value = '';
//         _currentText = '';
//         _currentPosition = 0;
//       });
//
//       flutterTts.setCancelHandler(() {
//         print('🔊 TTS Cancelled');
//         ttsState = TtsState.stopped;
//         currentWordObs.value = '';
//         _currentText = '';
//         _currentPosition = 0;
//       });
//
//       flutterTts.setPauseHandler(() {
//         print('🔊 TTS Paused');
//         ttsState = TtsState.paused;
//       });
//
//       flutterTts.setContinueHandler(() {
//         print('🔊 TTS Continued');
//         ttsState = TtsState.playing;
//       });
//
//       flutterTts.setErrorHandler((error) {
//         print('❌ TTS Error: $error');
//         ttsState = TtsState.stopped;
//         currentWordObs.value = '';
//         _currentText = '';
//         _currentPosition = 0;
//       });
//
//       // Set progress handler if available
//       if (!kIsWeb) {
//         try {
//           flutterTts.setProgressHandler(
//                 (text, start, end, word) {
//               currentWordObs.value = word;
//               _currentPosition = start;
//             },
//           );
//         } catch (e) {
//           print('⚠️ Progress handler setup failed: $e');
//         }
//       }
//
//       _isInitialized.value = true;
//       print('✅ Voice Assistant initialized successfully');
//     } catch (e) {
//       print('❌ Voice Assistant initialization error: $e');
//       _isInitialized.value = false;
//     }
//   }
//
//   Future<void> speak(String text) async {
//     if (!_isInitialized.value) {
//       print('🔊 TTS not initialized, initializing now...');
//       await _initTts();
//     }
//
//     if (text.isEmpty) {
//       print('❌ Cannot speak empty text');
//       return;
//     }
//
//     try {
//       print('🔊 Speaking text of length: ${text.length}');
//       await stop();
//
//       // Prepare text for speech
//       String cleanText = prepareTextForSpeech(text);
//       _currentText = cleanText;
//       _currentPosition = 0;
//
//       // For long texts, we need to chunk it
//       if (cleanText.length > 4000) {
//         print('🔊 Text too long, chunking...');
//         List<String> chunks = _chunkText(cleanText, 4000);
//         for (var chunk in chunks) {
//           if (ttsState != TtsState.stopped) {
//             await flutterTts.speak(chunk);
//             ttsState = TtsState.playing;
//           }
//         }
//       } else {
//         await flutterTts.speak(cleanText);
//         ttsState = TtsState.playing;
//       }
//     } catch (e) {
//       print('❌ Error speaking text: $e');
//     }
//   }
//
//   Future<void> stop() async {
//     if (!_isInitialized.value) return;
//
//     try {
//       var result = await flutterTts.stop();
//       if (result == 1) {
//         ttsState = TtsState.stopped;
//         currentWordObs.value = '';
//         _currentText = '';
//         _currentPosition = 0;
//       }
//     } catch (e) {
//       print('❌ Error stopping TTS: $e');
//     }
//   }
//
//   Future<void> pause() async {
//     if (!_isInitialized.value) return;
//
//     try {
//       if (ttsState == TtsState.playing) {
//         var result = await flutterTts.pause();
//         if (result == 1) {
//           ttsState = TtsState.paused;
//           print('🔊 TTS Paused successfully');
//         }
//       } else if (ttsState == TtsState.paused) {
//         // Resume from where we left off
//         await resume();
//       }
//     } catch (e) {
//       print('❌ Error pausing TTS: $e');
//       // Fallback: stop and restart from current position
//       await stop();
//       if (_currentText.isNotEmpty && _currentPosition > 0) {
//         String remainingText = _currentText.substring(_currentPosition);
//         await speak(remainingText);
//       }
//     }
//   }
//
//   Future<void> resume() async {
//     if (!_isInitialized.value) return;
//
//     try {
//       if (ttsState == TtsState.paused) {
//         // Try to resume
//         var result = await flutterTts.speak('');
//         if (result == 1) {
//           ttsState = TtsState.playing;
//           print('🔊 TTS Resumed successfully');
//         } else {
//           // If resume doesn't work, restart from current position
//           if (_currentText.isNotEmpty && _currentPosition > 0) {
//             String remainingText = _currentText.substring(_currentPosition);
//             await speak(remainingText);
//           }
//         }
//       }
//     } catch (e) {
//       print('❌ Error resuming TTS: $e');
//       // Fallback: restart from current position
//       if (_currentText.isNotEmpty && _currentPosition > 0) {
//         String remainingText = _currentText.substring(_currentPosition);
//         await speak(remainingText);
//       }
//     }
//   }
//
//   Future<void> setVolume(double value) async {
//     if (!_isInitialized.value) return;
//
//     volume = value;
//     await flutterTts.setVolume(value);
//   }
//
//   Future<void> setPitch(double value) async {
//     if (!_isInitialized.value) return;
//
//     pitch = value;
//     await flutterTts.setPitch(value);
//   }
//
//   Future<void> setRate(double value) async {
//     if (!_isInitialized.value) return;
//
//     rate = value;
//     await flutterTts.setSpeechRate(value);
//   }
//
//   Future<void> setLanguage(String lang) async {
//     if (!_isInitialized.value) return;
//
//     if (await flutterTts.isLanguageAvailable(lang)) {
//       language = lang;
//       await flutterTts.setLanguage(lang);
//     }
//   }
//
//   Future<void> setVoice(String voiceName) async {
//     if (!_isInitialized.value) return;
//
//     voice = voiceName;
//     await flutterTts.setVoice({
//       "name": voiceName,
//       "locale": language ?? "en-US"
//     });
//   }
//
//   // Clean up resources
//   void dispose() {
//     flutterTts.stop();
//   }
//
//   // Prepare text for better TTS experience - FIXED VERSION
//   String prepareTextForSpeech(String text) {
//     // First, handle markdown formatting properly
//     String cleanText = text;
//
//     // Remove bold markers (**text**)
//     cleanText = cleanText.replaceAllMapped(
//       RegExp(r'\*\*(.*?)\*\*'),
//           (match) => match.group(1) ?? '',
//     );
//
//     // Remove italic markers (*text*)
//     cleanText = cleanText.replaceAllMapped(
//       RegExp(r'\*(.*?)\*'),
//           (match) => match.group(1) ?? '',
//     );
//
//     // Remove heading markers (# ## ###)
//     cleanText = cleanText.replaceAll(RegExp(r'#{1,6}\s+'), '');
//
//     // Replace special characters and emojis
//     cleanText = cleanText
//         .replaceAll('•', ', ')                        // Replace bullets with pauses
//         .replaceAll('- ', ', ')                       // Replace dashes with pauses
//         .replaceAll('✅', 'Good: ')                   // Replace checkmarks
//         .replaceAll('⚠️', 'Warning: ')                // Replace warning emoji
//         .replaceAll('❌', 'Alert: ')                  // Replace error emoji
//         .replaceAll('📋', '')                         // Remove clipboard emoji
//         .replaceAll('👨‍⚕️', 'doctor ')                 // Replace doctor emoji
//         .replaceAll('💊', 'medication ')              // Replace pill emoji
//         .replaceAll('🏥', 'hospital ')                // Replace hospital emoji
//         .replaceAll('📅', 'date ')                    // Replace calendar emoji
//         .replaceAll('📞', 'phone ')                   // Replace phone emoji
//         .replaceAll('❓', 'question ')                // Replace question emoji
//         .replaceAll('📝', 'note ')                    // Replace note emoji
//         .replaceAll('📁', 'file ')                    // Replace file emoji
//         .replaceAll('🔍', 'search ')                  // Replace search emoji
//         .replaceAll('🤖', 'AI ')                      // Replace robot emoji
//         .replaceAll('🎯', 'target ')                  // Replace target emoji
//         .replaceAll('🚀', 'rocket ')                  // Replace rocket emoji
//         .replaceAll('💡', 'idea ');                   // Replace lightbulb emoji
//
//     // Clean up special characters that might cause issues
//     cleanText = cleanText
//         .replaceAll(RegExp(r'\$\d+'), '')             // Remove dollar signs with numbers
//         .replaceAll(RegExp(r'\$'), 'dollar ')         // Replace remaining dollar signs
//         .replaceAll('&', ' and ')                     // Replace ampersand
//         .replaceAll('@', ' at ')                      // Replace at symbol
//         .replaceAll('#', ' number ')                  // Replace hash
//         .replaceAll('%', ' percent ')                 // Replace percent
//         .replaceAll('°', ' degrees ')                 // Replace degree symbol
//         .replaceAll('±', ' plus or minus ')           // Replace plus-minus
//         .replaceAll('×', ' times ')                   // Replace multiplication
//         .replaceAll('÷', ' divided by ')              // Replace division
//         .replaceAll('≤', ' less than or equal to ')   // Replace less than equal
//         .replaceAll('≥', ' greater than or equal to ') // Replace greater than equal
//         .replaceAll('≠', ' not equal to ')            // Replace not equal
//         .replaceAll('≈', ' approximately ')           // Replace approximately
//         .replaceAll('→', ' leads to ')                // Replace arrow
//         .replaceAll('←', ' comes from ')              // Replace left arrow
//         .replaceAll('↑', ' increases ')               // Replace up arrow
//         .replaceAll('↓', ' decreases ');              // Replace down arrow
//
//     // Improve readability for medical terms
//     cleanText = cleanText
//         .replaceAll('mg/dL', 'milligrams per deciliter')
//         .replaceAll('mg/dl', 'milligrams per deciliter')
//         .replaceAll('mmHg', 'millimeters of mercury')
//         .replaceAll('bpm', 'beats per minute')
//         .replaceAll('g/dL', 'grams per deciliter')
//         .replaceAll('g/dl', 'grams per deciliter')
//         .replaceAll('mL', 'milliliters')
//         .replaceAll('ml', 'milliliters')
//         .replaceAll('kg', 'kilograms')
//         .replaceAll('cm', 'centimeters')
//         .replaceAll('mm', 'millimeters')
//         .replaceAll('°C', ' degrees Celsius')
//         .replaceAll('°F', ' degrees Fahrenheit');
//
//     // Add natural pauses for better speech flow
//     cleanText = cleanText
//         .replaceAll('. ', '. ')                       // Keep sentence pauses
//         .replaceAll('! ', '! ')                       // Keep exclamation pauses
//         .replaceAll('? ', '? ')                       // Keep question pauses
//         .replaceAll(': ', ': ')                       // Keep colon pauses
//         .replaceAll('; ', '; ')                       // Keep semicolon pauses
//         .replaceAll('\n\n', '. ')                     // Replace double newlines with periods
//         .replaceAll('\n', '. ')                       // Replace single newlines with periods
//         .replaceAll('  ', ' ')                        // Remove double spaces
//         .trim();                                      // Remove leading/trailing spaces
//
//     // Final cleanup
//     cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
//
//     return cleanText;
//   }
//
//   List<String> _chunkText(String text, int maxLength) {
//     List<String> chunks = [];
//
//     // Try to split at sentence boundaries first
//     List<String> sentences = text.split(RegExp(r'[.!?]+\s+'));
//     String currentChunk = '';
//
//     for (String sentence in sentences) {
//       if ((currentChunk + sentence).length <= maxLength) {
//         currentChunk += sentence + '. ';
//       } else {
//         if (currentChunk.isNotEmpty) {
//           chunks.add(currentChunk.trim());
//           currentChunk = sentence + '. ';
//         } else {
//           // If single sentence is too long, split by words
//           List<String> words = sentence.split(' ');
//           String wordChunk = '';
//           for (String word in words) {
//             if ((wordChunk + word).length <= maxLength) {
//               wordChunk += word + ' ';
//             } else {
//               if (wordChunk.isNotEmpty) {
//                 chunks.add(wordChunk.trim());
//                 wordChunk = word + ' ';
//               }
//             }
//           }
//           if (wordChunk.isNotEmpty) {
//             currentChunk = wordChunk;
//           }
//         }
//       }
//     }
//
//     if (currentChunk.isNotEmpty) {
//       chunks.add(currentChunk.trim());
//     }
//
//     return chunks;
//   }
// }

// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
//
// enum TtsState { playing, stopped, paused, continued }
//
// class VoiceAssistantService {
//   FlutterTts flutterTts = FlutterTts();
//   TtsState ttsState = TtsState.stopped;
//
//   double volume = 1.0;
//   double pitch = 1.0;
//   double rate = 0.5;
//   String? language = 'en-US'; // Default to English
//
//   bool get isPlaying => ttsState == TtsState.playing;
//   bool get isStopped => ttsState == TtsState.stopped;
//   bool get isPaused => ttsState == TtsState.paused;
//
//   final currentWordObs = ''.obs;
//   String get currentWord => currentWordObs.value;
//
//   final _isInitialized = false.obs;
//   bool get isInitialized => _isInitialized.value;
//
//   final _availableLanguages = <String>[].obs;
//   List<String> get availableLanguages => _availableLanguages;
//
//   VoiceAssistantService() {
//     _initTts();
//   }
//
//   Future<void> _initTts() async {
//     try {
//       print('🔊 Initializing voice assistant...');
//
//       await flutterTts.setSharedInstance(true);
//
//       // Configure TTS settings
//       await flutterTts.setVolume(volume);
//       await flutterTts.setPitch(pitch);
//       await flutterTts.setSpeechRate(rate);
//       await flutterTts.setLanguage(language!);
//
//       // Get available languages and set up Urdu if available
//       try {
//         final languages = await flutterTts.getLanguages;
//         if (languages is List && languages.isNotEmpty) {
//           for (var lang in languages) {
//             _availableLanguages.add(lang.toString());
//           }
//           print('🔊 Found ${_availableLanguages.length} available languages');
//
//           // Check if Urdu is available
//           List<String> urduLanguages = _availableLanguages.where((lang) =>
//           lang.toLowerCase().contains('ur') ||
//               lang.toLowerCase().contains('urdu') ||
//               lang.toLowerCase().contains('pk')
//           ).toList();
//
//           if (urduLanguages.isNotEmpty) {
//             print('🔊 Urdu language found: ${urduLanguages.first}');
//           }
//         }
//       } catch (e) {
//         print('❌ Failed to get languages: $e');
//       }
//
//       // Set callbacks with proper state management
//       flutterTts.setStartHandler(() {
//         print('🔊 TTS Started');
//         ttsState = TtsState.playing;
//       });
//
//       flutterTts.setCompletionHandler(() {
//         print('🔊 TTS Completed');
//         ttsState = TtsState.stopped;
//         currentWordObs.value = '';
//       });
//
//       flutterTts.setCancelHandler(() {
//         print('🔊 TTS Cancelled/Stopped');
//         ttsState = TtsState.stopped;
//         currentWordObs.value = '';
//       });
//
//       flutterTts.setPauseHandler(() {
//         print('🔊 TTS Paused');
//         ttsState = TtsState.paused;
//       });
//
//       flutterTts.setContinueHandler(() {
//         print('🔊 TTS Continued');
//         ttsState = TtsState.playing;
//       });
//
//       flutterTts.setErrorHandler((error) {
//         print('❌ TTS Error: $error');
//         ttsState = TtsState.stopped;
//         currentWordObs.value = '';
//       });
//
//       // Progress handler for word highlighting
//       if (!kIsWeb) {
//         try {
//           flutterTts.setProgressHandler((text, start, end, word) {
//             currentWordObs.value = word;
//           });
//         } catch (e) {
//           print('⚠️ Progress handler setup failed: $e');
//         }
//       }
//
//       _isInitialized.value = true;
//       print('✅ Voice Assistant initialized successfully');
//     } catch (e) {
//       print('❌ Voice Assistant initialization error: $e');
//       _isInitialized.value = false;
//     }
//   }
//
//   Future<void> speak(String text, {String? targetLanguage}) async {
//     if (!_isInitialized.value) {
//       await _initTts();
//     }
//
//     if (text.isEmpty) {
//       print('❌ Cannot speak empty text');
//       return;
//     }
//
//     try {
//       print('🔊 Speaking text of length: ${text.length}');
//
//       // Stop any current speech first
//       await forceStop();
//
//       // Set language if specified
//       if (targetLanguage != null) {
//         await setLanguage(targetLanguage);
//       }
//
//       // Prepare and speak text
//       String cleanText = prepareTextForSpeech(text, targetLanguage ?? language ?? 'en-US');
//       await flutterTts.speak(cleanText);
//       ttsState = TtsState.playing;
//
//     } catch (e) {
//       print('❌ Error speaking text: $e');
//       ttsState = TtsState.stopped;
//     }
//   }
//
//   Future<void> stop() async {
//     await forceStop();
//   }
//
//   Future<void> forceStop() async {
//     if (!_isInitialized.value) return;
//
//     try {
//       print('🔊 Force stopping TTS...');
//
//       // Try multiple stop methods to ensure it stops
//       await flutterTts.stop();
//       await flutterTts.pause();
//
//       // Force state update
//       ttsState = TtsState.stopped;
//       currentWordObs.value = '';
//
//       print('✅ TTS Force stopped');
//     } catch (e) {
//       print('❌ Error force stopping TTS: $e');
//       // Force state update even if stop fails
//       ttsState = TtsState.stopped;
//       currentWordObs.value = '';
//     }
//   }
//
//   Future<void> pause() async {
//     if (!_isInitialized.value) return;
//
//     try {
//       if (ttsState == TtsState.playing) {
//         await flutterTts.pause();
//         ttsState = TtsState.paused;
//       }
//     } catch (e) {
//       print('❌ Error pausing TTS: $e');
//     }
//   }
//
//   Future<void> setVolume(double value) async {
//     if (!_isInitialized.value) return;
//     volume = value;
//     await flutterTts.setVolume(value);
//   }
//
//   Future<void> setPitch(double value) async {
//     if (!_isInitialized.value) return;
//     pitch = value;
//     await flutterTts.setPitch(value);
//   }
//
//   Future<void> setRate(double value) async {
//     if (!_isInitialized.value) return;
//     rate = value;
//     await flutterTts.setSpeechRate(value);
//   }
//
//   Future<void> setLanguage(String lang) async {
//     if (!_isInitialized.value) return;
//
//     try {
//       // Map language codes to TTS language codes
//       String ttsLanguage = _mapLanguageCode(lang);
//
//       if (await flutterTts.isLanguageAvailable(ttsLanguage)) {
//         language = ttsLanguage;
//         await flutterTts.setLanguage(ttsLanguage);
//         print('🔊 Language set to: $ttsLanguage');
//       } else {
//         print('⚠️ Language $ttsLanguage not available, keeping current: $language');
//       }
//     } catch (e) {
//       print('❌ Error setting language: $e');
//     }
//   }
//
//   String _mapLanguageCode(String lang) {
//     switch (lang.toLowerCase()) {
//       case 'ur':
//       case 'urdu':
//       // Try different Urdu language codes
//         List<String> urduCodes = ['ur-PK', 'ur-IN', 'ur'];
//         for (String code in urduCodes) {
//           if (_availableLanguages.any((l) => l.toLowerCase().contains(code.toLowerCase()))) {
//             return code;
//           }
//         }
//         return 'ur-PK'; // Default Urdu code
//       case 'en':
//       case 'english':
//         return 'en-US';
//       default:
//         return lang;
//     }
//   }
//
//   void dispose() {
//     forceStop();
//   }
//
//   String prepareTextForSpeech(String text, String targetLanguage) {
//     String cleanText = text;
//
//     // Language-specific text preparation
//     if (targetLanguage.toLowerCase().startsWith('ur')) {
//       return prepareUrduTextForSpeech(cleanText);
//     } else {
//       return prepareEnglishTextForSpeech(cleanText);
//     }
//   }
//
//   String prepareEnglishTextForSpeech(String text) {
//     String cleanText = text;
//
//     // Remove markdown formatting
//     cleanText = cleanText.replaceAllMapped(
//       RegExp(r'\*\*(.*?)\*\*'),
//           (match) => match.group(1) ?? '',
//     );
//
//     cleanText = cleanText.replaceAllMapped(
//       RegExp(r'\*(.*?)\*'),
//           (match) => match.group(1) ?? '',
//     );
//
//     cleanText = cleanText.replaceAll(RegExp(r'#{1,6}\s+'), '');
//
//     // Replace special characters
//     cleanText = cleanText
//         .replaceAll('•', ', ')
//         .replaceAll('- ', ', ')
//         .replaceAll('✅', 'Good: ')
//         .replaceAll('⚠️', 'Warning: ')
//         .replaceAll('❌', 'Alert: ')
//         .replaceAll('📋', '')
//         .replaceAll('👨‍⚕️', 'doctor ')
//         .replaceAll('💊', 'medication ')
//         .replaceAll('🏥', 'hospital ')
//         .replaceAll('📅', 'date ')
//         .replaceAll('📞', 'phone ')
//         .replaceAll('❓', 'question ')
//         .replaceAll('📝', 'note ')
//         .replaceAll('📁', 'file ');
//
//     // Clean up special characters
//     cleanText = cleanText
//         .replaceAll(RegExp(r'\$\d+'), '')
//         .replaceAll(RegExp(r'\$'), 'dollar ')
//         .replaceAll('&', ' and ')
//         .replaceAll('@', ' at ')
//         .replaceAll('#', ' number ')
//         .replaceAll('%', ' percent ');
//
//     // Medical terms
//     cleanText = cleanText
//         .replaceAll('mg/dL', 'milligrams per deciliter')
//         .replaceAll('mg/dl', 'milligrams per deciliter')
//         .replaceAll('mmHg', 'millimeters of mercury')
//         .replaceAll('bpm', 'beats per minute')
//         .replaceAll('g/dL', 'grams per deciliter')
//         .replaceAll('g/dl', 'grams per deciliter');
//
//     // Clean up spacing
//     cleanText = cleanText
//         .replaceAll('\n\n', '. ')
//         .replaceAll('\n', '. ')
//         .replaceAll(RegExp(r'\s+'), ' ')
//         .trim();
//
//     return cleanText;
//   }
//
//   String prepareUrduTextForSpeech(String text) {
//     String cleanText = text;
//
//     // Remove markdown formatting
//     cleanText = cleanText.replaceAllMapped(
//       RegExp(r'\*\*(.*?)\*\*'),
//           (match) => match.group(1) ?? '',
//     );
//
//     cleanText = cleanText.replaceAllMapped(
//       RegExp(r'\*(.*?)\*'),
//           (match) => match.group(1) ?? '',
//     );
//
//     cleanText = cleanText.replaceAll(RegExp(r'#{1,6}\s+'), '');
//
//     // Replace special characters with Urdu equivalents
//     cleanText = cleanText
//         .replaceAll('•', '، ')
//         .replaceAll('- ', '، ')
//         .replaceAll('✅', 'اچھا: ')
//         .replaceAll('⚠️', 'خبردار: ')
//         .replaceAll('❌', 'انتباہ: ')
//         .replaceAll('📋', '')
//         .replaceAll('👨‍⚕️', 'ڈاکٹر ')
//         .replaceAll('💊', 'دوا ')
//         .replaceAll('🏥', 'ہسپتال ')
//         .replaceAll('📅', 'تاریخ ')
//         .replaceAll('📞', 'فون ')
//         .replaceAll('❓', 'سوال ')
//         .replaceAll('📝', 'نوٹ ')
//         .replaceAll('📁', 'فائل ');
//
//     // Clean up special characters
//     cleanText = cleanText
//         .replaceAll(RegExp(r'\$\d+'), '')
//         .replaceAll(RegExp(r'\$'), 'ڈالر ')
//         .replaceAll('&', ' اور ')
//         .replaceAll('@', ' ایٹ ')
//         .replaceAll('#', ' نمبر ')
//         .replaceAll('%', ' فیصد ');
//
//     // Medical terms in Urdu context
//     cleanText = cleanText
//         .replaceAll('mg/dL', 'ملی گرام فی ڈیسی لیٹر')
//         .replaceAll('mg/dl', 'ملی گرام فی ڈیسی لیٹر')
//         .replaceAll('mmHg', 'ملی میٹر مرکری')
//         .replaceAll('bpm', 'دھڑکن فی منٹ')
//         .replaceAll('g/dL', 'گرام فی ڈیسی لیٹر')
//         .replaceAll('g/dl', 'گرام فی ڈیسی لیٹر');
//
//     // Clean up spacing
//     cleanText = cleanText
//         .replaceAll('\n\n', '۔ ')
//         .replaceAll('\n', '۔ ')
//         .replaceAll(RegExp(r'\s+'), ' ')
//         .trim();
//
//     return cleanText;
//   }
// }


import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

enum TtsState { playing, stopped, paused, continued }

class VoiceAssistantService {
  FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;

  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  String? language = 'en-US';

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;

  final currentWordObs = ''.obs;
  String get currentWord => currentWordObs.value;

  final _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  final _availableLanguages = <String>[].obs;
  List<String> get availableLanguages => _availableLanguages;

  final _availableVoices = <Map<String, String>>[].obs;
  List<Map<String, String>> get availableVoices => _availableVoices;

  VoiceAssistantService() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      print('🔊 Initializing voice assistant...');

      await flutterTts.setSharedInstance(true);

      // Get available languages first
      try {
        final languages = await flutterTts.getLanguages;
        if (languages is List && languages.isNotEmpty) {
          _availableLanguages.clear();
          for (var lang in languages) {
            _availableLanguages.add(lang.toString());
          }
          print('🔊 Available languages: ${_availableLanguages.take(10).join(', ')}...');
        }
      } catch (e) {
        print('❌ Failed to get languages: $e');
      }

      // Get available voices
      try {
        final voices = await flutterTts.getVoices;
        if (voices is List && voices.isNotEmpty) {
          _availableVoices.clear();
          for (var voice in voices) {
            if (voice is Map) {
              _availableVoices.add({
                'name': voice['name']?.toString() ?? '',
                'locale': voice['locale']?.toString() ?? '',
              });
            }
          }
          print('🔊 Found ${_availableVoices.length} available voices');
        }
      } catch (e) {
        print('❌ Failed to get voices: $e');
      }

      // Set default language - ensure English is available
      await _setDefaultLanguage();

      // Configure TTS settings
      await flutterTts.setVolume(volume);
      await flutterTts.setPitch(pitch);
      await flutterTts.setSpeechRate(rate);

      // iOS-specific settings
      if (!kIsWeb) {
        try {
          await flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            ],
            IosTextToSpeechAudioMode.defaultMode,
          );
        } catch (e) {
          print('⚠️ iOS audio category setup failed: $e');
        }
      }

      // Set callbacks
      _setupCallbacks();

      _isInitialized.value = true;
      print('✅ Voice Assistant initialized successfully with language: $language');
    } catch (e) {
      print('❌ Voice Assistant initialization error: $e');
      _isInitialized.value = false;
    }
  }

  Future<void> _setDefaultLanguage() async {
    // Try to find and set English language
    List<String> englishOptions = [
      'en-US', 'en-GB', 'en-AU', 'en-CA', 'en-IN', 'en'
    ];

    for (String englishLang in englishOptions) {
      try {
        bool isAvailable = await flutterTts.isLanguageAvailable(englishLang);
        if (isAvailable) {
          language = englishLang;
          await flutterTts.setLanguage(englishLang);
          print('🔊 Set English language to: $englishLang');
          return;
        }
      } catch (e) {
        print('⚠️ Failed to check language $englishLang: $e');
      }
    }

    // Fallback to first available language
    if (_availableLanguages.isNotEmpty) {
      language = _availableLanguages.first;
      await flutterTts.setLanguage(language!);
      print('🔊 Fallback to first available language: $language');
    }
  }

  void _setupCallbacks() {
    flutterTts.setStartHandler(() {
      print('🔊 TTS Started');
      ttsState = TtsState.playing;
    });

    flutterTts.setCompletionHandler(() {
      print('🔊 TTS Completed');
      ttsState = TtsState.stopped;
      currentWordObs.value = '';
    });

    flutterTts.setCancelHandler(() {
      print('🔊 TTS Cancelled/Stopped');
      ttsState = TtsState.stopped;
      currentWordObs.value = '';
    });

    flutterTts.setPauseHandler(() {
      print('🔊 TTS Paused');
      ttsState = TtsState.paused;
    });

    flutterTts.setContinueHandler(() {
      print('🔊 TTS Continued');
      ttsState = TtsState.playing;
    });

    flutterTts.setErrorHandler((error) {
      print('❌ TTS Error: $error');
      ttsState = TtsState.stopped;
      currentWordObs.value = '';
    });

    // Progress handler for word highlighting
    if (!kIsWeb) {
      try {
        flutterTts.setProgressHandler((text, start, end, word) {
          currentWordObs.value = word;
        });
      } catch (e) {
        print('⚠️ Progress handler setup failed: $e');
      }
    }
  }

  Future<void> speak(String text, {String? targetLanguage}) async {
    if (!_isInitialized.value) {
      print('🔊 TTS not initialized, initializing now...');
      await _initTts();
    }

    if (text.isEmpty) {
      print('❌ Cannot speak empty text');
      return;
    }

    try {
      print('🔊 Speaking text of length: ${text.length}');
      print('🔊 Target language: ${targetLanguage ?? language}');

      // Stop any current speech first
      await forceStop();

      // Set language if specified
      if (targetLanguage != null && targetLanguage != language) {
        await setLanguage(targetLanguage);
      }

      // Prepare text for speech
      String cleanText = prepareTextForSpeech(text, targetLanguage ?? language ?? 'en-US');
      print('🔊 Clean text preview: ${cleanText.substring(0, cleanText.length > 100 ? 100 : cleanText.length)}...');

      // Speak the text
      var result = await flutterTts.speak(cleanText);
      if (result == 1) {
        ttsState = TtsState.playing;
        print('✅ TTS speak command successful');
      } else {
        print('⚠️ TTS speak command returned: $result');
      }

    } catch (e) {
      print('❌ Error speaking text: $e');
      ttsState = TtsState.stopped;
    }
  }

  Future<void> stop() async {
    await forceStop();
  }

  Future<void> forceStop() async {
    if (!_isInitialized.value) return;

    try {
      print('🔊 Force stopping TTS...');
      var result = await flutterTts.stop();
      print('🔊 Stop result: $result');

      // Force state update
      ttsState = TtsState.stopped;
      currentWordObs.value = '';

      print('✅ TTS Force stopped');
    } catch (e) {
      print('❌ Error force stopping TTS: $e');
      ttsState = TtsState.stopped;
      currentWordObs.value = '';
    }
  }

  Future<void> pause() async {
    if (!_isInitialized.value) return;

    try {
      if (ttsState == TtsState.playing) {
        var result = await flutterTts.pause();
        if (result == 1) {
          ttsState = TtsState.paused;
          print('🔊 TTS Paused successfully');
        }
      }
    } catch (e) {
      print('❌ Error pausing TTS: $e');
    }
  }

  Future<void> setVolume(double value) async {
    if (!_isInitialized.value) return;
    volume = value;
    await flutterTts.setVolume(value);
    print('🔊 Volume set to: $value');
  }

  Future<void> setPitch(double value) async {
    if (!_isInitialized.value) return;
    pitch = value;
    await flutterTts.setPitch(value);
    print('🔊 Pitch set to: $value');
  }

  Future<void> setRate(double value) async {
    if (!_isInitialized.value) return;
    rate = value;
    await flutterTts.setSpeechRate(value);
    print('🔊 Rate set to: $value');
  }

  Future<void> setLanguage(String lang) async {
    if (!_isInitialized.value) return;

    try {
      String ttsLanguage = _mapLanguageCode(lang);
      print('🔊 Attempting to set language: $lang -> $ttsLanguage');

      bool isAvailable = await flutterTts.isLanguageAvailable(ttsLanguage);
      if (isAvailable) {
        language = ttsLanguage;
        var result = await flutterTts.setLanguage(ttsLanguage);
        print('🔊 Language set successfully to: $ttsLanguage (result: $result)');
      } else {
        print('⚠️ Language $ttsLanguage not available');
        // Try to find similar language
        String? similarLang = _findSimilarLanguage(ttsLanguage);
        if (similarLang != null) {
          language = similarLang;
          await flutterTts.setLanguage(similarLang);
          print('🔊 Using similar language: $similarLang');
        }
      }
    } catch (e) {
      print('❌ Error setting language: $e');
    }
  }

  String? _findSimilarLanguage(String targetLang) {
    String langPrefix = targetLang.split('-')[0].toLowerCase();

    for (String availableLang in _availableLanguages) {
      if (availableLang.toLowerCase().startsWith(langPrefix)) {
        return availableLang;
      }
    }
    return null;
  }

  String _mapLanguageCode(String lang) {
    String lowerLang = lang.toLowerCase();

    if (lowerLang.contains('ur') || lowerLang.contains('urdu')) {
      // Try different Urdu language codes
      List<String> urduCodes = ['ur-PK', 'ur-IN', 'ur'];
      for (String code in urduCodes) {
        if (_availableLanguages.any((l) => l.toLowerCase() == code.toLowerCase())) {
          return code;
        }
      }
      return 'ur-PK';
    } else if (lowerLang.contains('en') || lowerLang.contains('english')) {
      // Try different English language codes
      List<String> englishCodes = ['en-US', 'en-GB', 'en-AU', 'en-CA', 'en'];
      for (String code in englishCodes) {
        if (_availableLanguages.any((l) => l.toLowerCase() == code.toLowerCase())) {
          return code;
        }
      }
      return 'en-US';
    }

    return lang;
  }

  void dispose() {
    forceStop();
  }

  String prepareTextForSpeech(String text, String targetLanguage) {
    if (targetLanguage.toLowerCase().startsWith('ur')) {
      return prepareUrduTextForSpeech(text);
    } else {
      return prepareEnglishTextForSpeech(text);
    }
  }

  String prepareEnglishTextForSpeech(String text) {
    String cleanText = text;

    // Remove markdown formatting
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
          (match) => match.group(1) ?? '',
    );

    cleanText = cleanText.replaceAllMapped(
      RegExp(r'\*(.*?)\*'),
          (match) => match.group(1) ?? '',
    );

    cleanText = cleanText.replaceAll(RegExp(r'#{1,6}\s+'), '');

    // Replace emojis and special characters
    cleanText = cleanText
        .replaceAll('•', ', ')
        .replaceAll('- ', ', ')
        .replaceAll('✅', 'Good: ')
        .replaceAll('⚠️', 'Warning: ')
        .replaceAll('❌', 'Alert: ')
        .replaceAll('📋', '')
        .replaceAll('👨‍⚕️', 'doctor ')
        .replaceAll('💊', 'medication ')
        .replaceAll('🏥', 'hospital ')
        .replaceAll('📅', 'date ')
        .replaceAll('📞', 'phone ')
        .replaceAll('❓', 'question ')
        .replaceAll('📝', 'note ')
        .replaceAll('📁', 'file ')
        .replaceAll('🔍', 'search ')
        .replaceAll('🤖', 'AI ')
        .replaceAll('🎯', 'target ')
        .replaceAll('🚀', 'rocket ')
        .replaceAll('💡', 'idea ');

    // Clean up special characters
    cleanText = cleanText
        .replaceAll(RegExp(r'\$\d+'), '')
        .replaceAll(RegExp(r'\$'), 'dollar ')
        .replaceAll('&', ' and ')
        .replaceAll('@', ' at ')
        .replaceAll('#', ' number ')
        .replaceAll('%', ' percent ')
        .replaceAll('°', ' degrees ')
        .replaceAll('±', ' plus or minus ')
        .replaceAll('×', ' times ')
        .replaceAll('÷', ' divided by ');

    // Medical terms
    cleanText = cleanText
        .replaceAll('mg/dL', 'milligrams per deciliter')
        .replaceAll('mg/dl', 'milligrams per deciliter')
        .replaceAll('mmHg', 'millimeters of mercury')
        .replaceAll('bpm', 'beats per minute')
        .replaceAll('g/dL', 'grams per deciliter')
        .replaceAll('g/dl', 'grams per deciliter')
        .replaceAll('mL', 'milliliters')
        .replaceAll('ml', 'milliliters')
        .replaceAll('kg', 'kilograms')
        .replaceAll('cm', 'centimeters')
        .replaceAll('mm', 'millimeters')
        .replaceAll('°C', ' degrees Celsius')
        .replaceAll('°F', ' degrees Fahrenheit');

    // Clean up spacing and line breaks
    cleanText = cleanText
        .replaceAll('\n\n', '. ')
        .replaceAll('\n', '. ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Ensure proper sentence endings
    if (!cleanText.endsWith('.') && !cleanText.endsWith('!') && !cleanText.endsWith('?')) {
      cleanText += '.';
    }

    return cleanText;
  }

  String prepareUrduTextForSpeech(String text) {
    String cleanText = text;

    // Remove markdown formatting
    cleanText = cleanText.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
          (match) => match.group(1) ?? '',
    );

    cleanText = cleanText.replaceAllMapped(
      RegExp(r'\*(.*?)\*'),
          (match) => match.group(1) ?? '',
    );

    cleanText = cleanText.replaceAll(RegExp(r'#{1,6}\s+'), '');

    // Replace emojis with Urdu equivalents
    cleanText = cleanText
        .replaceAll('•', '، ')
        .replaceAll('- ', '، ')
        .replaceAll('✅', 'اچھا: ')
        .replaceAll('⚠️', 'خبردار: ')
        .replaceAll('❌', 'انتباہ: ')
        .replaceAll('📋', '')
        .replaceAll('👨‍⚕️', 'ڈاکٹر ')
        .replaceAll('💊', 'دوا ')
        .replaceAll('🏥', 'ہسپتال ')
        .replaceAll('📅', 'تاریخ ')
        .replaceAll('📞', 'فون ')
        .replaceAll('❓', 'سوال ')
        .replaceAll('📝', 'نوٹ ')
        .replaceAll('📁', 'فائل ');

    // Clean up special characters
    cleanText = cleanText
        .replaceAll(RegExp(r'\$\d+'), '')
        .replaceAll(RegExp(r'\$'), 'ڈالر ')
        .replaceAll('&', ' اور ')
        .replaceAll('@', ' ایٹ ')
        .replaceAll('#', ' نمبر ')
        .replaceAll('%', ' فیصد ');

    // Medical terms in Urdu
    cleanText = cleanText
        .replaceAll('mg/dL', 'ملی گرام فی ڈیسی لیٹر')
        .replaceAll('mg/dl', 'ملی گرام فی ڈیسی لیٹر')
        .replaceAll('mmHg', 'ملی میٹر مرکری')
        .replaceAll('bpm', 'دھڑکن فی منٹ')
        .replaceAll('g/dL', 'گرام فی ڈیسی لیٹر')
        .replaceAll('g/dl', 'گرام فی ڈیسی لیٹر');

    // Clean up spacing
    cleanText = cleanText
        .replaceAll('\n\n', '۔ ')
        .replaceAll('\n', '۔ ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleanText;
  }

  // Helper method to test TTS with simple text
  Future<void> testTTS() async {
    print('🔊 Testing TTS...');
    await speak('Hello, this is a test of the text to speech system.', targetLanguage: 'en-US');
  }

  // Helper method to get TTS info
  void printTTSInfo() {
    print('🔊 Current TTS Info:');
    print('   Language: $language');
    print('   Volume: $volume');
    print('   Pitch: $pitch');
    print('   Rate: $rate');
    print('   State: $ttsState');
    print('   Available Languages: ${_availableLanguages.take(5).join(', ')}...');
  }
}
