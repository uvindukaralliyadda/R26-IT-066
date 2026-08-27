import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _filename;

  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _filename = file.name;
          _result = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed selecting image: $e';
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImageBytes = null;
      _filename = null;
      _result = null;
      _error = null;
    });
  }

  double _parseConfidence(dynamic val) {
    if (val == null) return 0.0;
    final num? n = num.tryParse(val.toString());
    if (n == null) return 0.0;
    if (n <= 1.0 && n > 0.0) {
      return n * 100.0;
    }
    return n.toDouble();
  }

  Future<void> _analyzeDisease() async {
    if (_selectedImageBytes == null || _filename == null) {
      setState(() {
        _error = 'Please select a paddy leaf photo first.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ApiService.predictDiseaseImage(
        imageBytes: _selectedImageBytes!,
        filename: _filename!,
      );

      final double conf = _parseConfidence(response['confidence']);
      
      // Enforce < 55% confidence threshold check
      if (conf < 55.0) {
        response['is_rice_leaf'] = false;
        response['disease'] = 'Not a Rice Leaf Detected';
        response['severity'] = 'Unrecognized';
      } else {
        response['is_rice_leaf'] = true;
      }

      setState(() {
        _result = response;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Leaf Health Scanner'),
            ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.greenLightBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.greenBorder),
                  ),
                  child: const Icon(Icons.center_focus_strong_rounded,
                      color: AppTheme.primaryGreen, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leaf Health & Disease Scanner',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Upload or take a paddy leaf photo for instant AI disease diagnosis',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _buildUploadCard()),
                      const SizedBox(width: 24),
                      Expanded(flex: 5, child: _buildResultsCard()),
                    ],
                  )
                : Column(
                    children: [
                      _buildUploadCard(),
                      const SizedBox(height: 24),
                      _buildResultsCard(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Paddy Leaf Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppTheme.greenLightBg,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Text(
                  'AI Assisted',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreenDark,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppTheme.borderLight),

          // Upload / Preview Box
          if (_selectedImageBytes == null)
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: AppTheme.bgCanvas,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.borderSubtle,
                      width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.greenLightBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.greenBorder),
                      ),
                      child: const Icon(Icons.add_a_photo_rounded,
                          color: AppTheme.primaryGreen, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Paddy Leaf Photo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Click to browse gallery or upload photo file',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_rounded, size: 16),
                          label: const Text('Gallery'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_rounded, size: 16),
                          label: const Text('Camera'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _selectedImageBytes!,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              size: 18, color: Colors.black),
                          onPressed: _clearImage,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _filename ?? 'leaf_image.jpg',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearImage,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Change'),
                    ),
                  ],
                ),
              ],
            ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Text(_error!,
                  style: const TextStyle(
                      color: Color(0xFFDC2626), fontSize: 12)),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  (_loading || _selectedImageBytes == null) ? null : _analyzeDisease,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.center_focus_strong_rounded),
              label: Text(_loading
                  ? 'Diagnosing Paddy Leaf Photo...'
                  : 'Scan Leaf Health'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Diagnosis Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Smart AI Scanner',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const Divider(height: 24, color: AppTheme.borderLight),

          if (_result == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.bug_report_outlined,
                        size: 48, color: AppTheme.borderSubtle),
                    SizedBox(height: 12),
                    Text(
                      'No leaf image analyzed yet',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upload photo and click Scan Leaf Health',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Builder(
              builder: (context) {
                final double conf = _parseConfidence(_result!['confidence']);
                final bool isLowConfidence = conf < 55.0;
                final String diseaseText = isLowConfidence
                    ? 'Not a Rice Leaf Detected'
                    : (_result!['disease']?.toString() ?? 'Healthy');
                
                final bool isHealthy = !isLowConfidence &&
                    (diseaseText.toLowerCase() == 'healthy');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Condition Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isLowConfidence
                            ? AppTheme.orangeLightBg
                            : (isHealthy ? AppTheme.greenLightBg : const Color(0xFFFEF2F2)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isLowConfidence
                              ? AppTheme.orangeBorder
                              : (isHealthy ? AppTheme.greenBorder : const Color(0xFFFCA5A5)),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isLowConfidence ? 'AI SCAN WARNING' : 'DETECTED CONDITION',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isLowConfidence)
                                const Icon(Icons.warning_amber_rounded, color: AppTheme.accentOrange, size: 24)
                              else if (isHealthy)
                                const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 24)
                              else
                                const Icon(Icons.bug_report_rounded, color: Color(0xFFDC2626), size: 24),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  diseaseText.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isLowConfidence ? 18 : 22,
                                    fontWeight: FontWeight.w900,
                                    color: isLowConfidence
                                        ? AppTheme.accentOrange
                                        : (isHealthy ? AppTheme.primaryGreenDark : const Color(0xFFDC2626)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isLowConfidence ? AppTheme.orangeBorder : AppTheme.borderLight,
                              ),
                            ),
                            child: Text(
                              isLowConfidence
                                  ? 'Confidence: ${conf.toStringAsFixed(1)}% (Below 55% Threshold)'
                                  : 'Severity: ${_result!['severity'] ?? "None"}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isLowConfidence ? AppTheme.accentOrange : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isLowConfidence) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.orangeLightBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.orangeBorder),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppTheme.accentOrange, size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Confidence is below 55%. The AI system could not verify this photo as a paddy/rice leaf. Please capture or upload a clear, well-lit photo of a paddy leaf.',
                                style: TextStyle(fontSize: 11, color: AppTheme.textPrimary, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Confidence & Spread Grid
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCanvas,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Confidence',
                                    style: TextStyle(
                                        fontSize: 11, color: AppTheme.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  '${conf.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: isLowConfidence ? AppTheme.accentOrange : AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCanvas,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Infection Spread',
                                    style: TextStyle(
                                        fontSize: 11, color: AppTheme.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  isLowConfidence ? 'N/A' : '${_formatNum(_result!['spread_area_percent'])}%',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: isLowConfidence ? AppTheme.textMuted : const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  String _formatNum(dynamic val) {
    if (val == null) return '0.00';
    final num? n = num.tryParse(val.toString());
    if (n == null) return '0.00';
    return n.toStringAsFixed(2);
  }
}
