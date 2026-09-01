import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';

class YieldTreatmentScreen extends StatefulWidget {
  const YieldTreatmentScreen({super.key});

  @override
  State<YieldTreatmentScreen> createState() => _YieldTreatmentScreenState();
}

class _YieldTreatmentScreenState extends State<YieldTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Input Controllers initialized with exact reference values
  final TextEditingController _nitrogenController = TextEditingController(
    text: '45',
  );
  final TextEditingController _phosphorusController = TextEditingController(
    text: '28',
  );
  final TextEditingController _potassiumController = TextEditingController(
    text: '110',
  );
  final TextEditingController _severityController = TextEditingController(
    text: '35',
  );

  String _growthStage = 'maturity';
  String _season = 'Maha';
  String _variety = 'BG300';
  String _disease = 'Blast';

  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFirebaseTelemetry();
  }

  Future<void> _fetchFirebaseTelemetry() async {
    try {
      final data = await FirebaseService.fetchLatestTelemetry();
      if (data != null && mounted) {
        setState(() {
          if (data.containsKey('nitrogen')) {
            _nitrogenController.text = data['nitrogen'].toString();
          }
          if (data.containsKey('phosphorus')) {
            _phosphorusController.text = data['phosphorus'].toString();
          }
          if (data.containsKey('potassium')) {
            _potassiumController.text = data['potassium'].toString();
          }
        });
      }
    } catch (e) {
      debugPrint('[YieldTreatmentScreen] Telemetry fetch error: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final double n = double.tryParse(_nitrogenController.text) ?? 100;
      final double p = double.tryParse(_phosphorusController.text) ?? 48;
      final double k = double.tryParse(_potassiumController.text) ?? 44;
      final double severity = double.tryParse(_severityController.text) ?? 35;

      final payload = {
        'nitrogen': n,
        'phosphorus': p,
        'potassium': k,
        'growth_stage': _growthStage,
        'season': _season,
        'variety': _variety,
        'disease': _disease,
        'severity': severity,
      };

      try {
        final response = await ApiService.predictYieldDecision(payload);
        setState(() {
          _result = response;
        });
      } catch (apiErr) {
        setState(() {
          _result = null;
          _error = apiErr.toString().replaceAll('Exception: ', '');
        });
      }
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppTheme.bgCanvas,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 28 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header (Back Arrow, Title, Subtitle, User Avatar)
            _buildTopHeader(context, isDesktop),

            const SizedBox(height: 24),

            // Main Content Row / Column
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Input Information Card (Flex 6)
                      Expanded(
                        flex: 6,
                        child: _buildInputInformationCard(isMobile: false),
                      ),
                      const SizedBox(width: 24),
                      // Right Column: Prediction Results Card (Flex 5)
                      Expanded(flex: 5, child: _buildPredictionResultsCard()),
                    ],
                  )
                : Column(
                    children: [
                      _buildInputInformationCard(isMobile: true),
                      const SizedBox(height: 24),
                      _buildPredictionResultsCard(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // ── 1. Header Bar ──
  Widget _buildTopHeader(BuildContext context, bool isDesktop) {
    return Row(
      children: [
        // Circular Back Button
        InkWell(
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Title & Subtitle
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Yield Prediction & Treatment Decision',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Predict yield, disease loss and get treatment recommendation.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Right Header Icons
        if (isDesktop) ...[
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.wb_sunny_outlined,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            tooltip: 'Theme Toggle',
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.greenLightBg,
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Farmer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── 2. Left Card: Input Information ──
  Widget _buildInputInformationCard({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.greenLightBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Input Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryGreenDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Group 1: Soil Nutrient Data (NPK)
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soil Nutrient Data (NPK)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '⚡ Sensor Synced',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (isMobile) ...[
              _buildInputField(
                _nitrogenController,
                'Nitrogen (N) (kg/ha)',
                '100',
              ),
              const SizedBox(height: 10),
              _buildInputField(
                _phosphorusController,
                'Phosphorus (P) (kg/ha)',
                '48',
              ),
              const SizedBox(height: 10),
              _buildInputField(
                _potassiumController,
                'Potassium (K) (kg/ha)',
                '44',
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      _nitrogenController,
                      'Nitrogen (N) (kg/ha)',
                      '100',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      _phosphorusController,
                      'Phosphorus (P) (kg/ha)',
                      '48',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInputField(
                      _potassiumController,
                      'Potassium (K) (kg/ha)',
                      '44',
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Group 2: Crop Information
            const Text(
              'Crop Information',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (isMobile) ...[
              _buildDropdownField(
                label: 'Growth Stage',
                value: _growthStage,
                items: const [
                  DropdownMenuItem(
                    value: 'germination',
                    child: Text('germination'),
                  ),
                  DropdownMenuItem(
                    value: 'tillering',
                    child: Text('tillering'),
                  ),
                  DropdownMenuItem(value: 'panicle', child: Text('panicle')),
                  DropdownMenuItem(value: 'heading', child: Text('heading')),
                  DropdownMenuItem(value: 'maturity', child: Text('maturity')),
                ],
                onChanged: (val) => setState(() => _growthStage = val!),
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                label: 'Season',
                value: _season,
                items: const [
                  DropdownMenuItem(value: 'Maha', child: Text('Maha')),
                  DropdownMenuItem(value: 'Yala', child: Text('Yala')),
                ],
                onChanged: (val) => setState(() => _season = val!),
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                label: 'Variety',
                value: _variety,
                items: const [
                  DropdownMenuItem(value: 'BG300', child: Text('BG300')),
                  DropdownMenuItem(value: 'AT362', child: Text('AT362')),
                  DropdownMenuItem(value: 'BG352', child: Text('BG352')),
                ],
                onChanged: (val) => setState(() => _variety = val!),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Growth Stage',
                      value: _growthStage,
                      items: const [
                        DropdownMenuItem(
                          value: 'germination',
                          child: Text('germination'),
                        ),
                        DropdownMenuItem(
                          value: 'tillering',
                          child: Text('tillering'),
                        ),
                        DropdownMenuItem(
                          value: 'panicle',
                          child: Text('panicle'),
                        ),
                        DropdownMenuItem(
                          value: 'heading',
                          child: Text('heading'),
                        ),
                        DropdownMenuItem(
                          value: 'maturity',
                          child: Text('maturity'),
                        ),
                      ],
                      onChanged: (val) => setState(() => _growthStage = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Season',
                      value: _season,
                      items: const [
                        DropdownMenuItem(value: 'Maha', child: Text('Maha')),
                        DropdownMenuItem(value: 'Yala', child: Text('Yala')),
                      ],
                      onChanged: (val) => setState(() => _season = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Variety',
                      value: _variety,
                      items: const [
                        DropdownMenuItem(value: 'BG300', child: Text('BG300')),
                        DropdownMenuItem(value: 'AT362', child: Text('AT362')),
                        DropdownMenuItem(value: 'BG352', child: Text('BG352')),
                      ],
                      onChanged: (val) => setState(() => _variety = val!),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Group 3: Disease Information
            const Text(
              'Disease Information',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (isMobile) ...[
              _buildDropdownField(
                label: 'Disease',
                value: _disease,
                items: const [
                  DropdownMenuItem(value: 'Blast', child: Text('Blast')),
                  DropdownMenuItem(
                    value: 'BrownSpot',
                    child: Text('Brown Spot'),
                  ),
                  DropdownMenuItem(
                    value: 'BacterialBlight',
                    child: Text('Bacterial Blight'),
                  ),
                  DropdownMenuItem(value: 'None', child: Text('None')),
                ],
                onChanged: (val) => setState(() => _disease = val!),
              ),
              const SizedBox(height: 10),
              _buildInputField(_severityController, 'Severity (%)', '35'),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDropdownField(
                      label: 'Disease',
                      value: _disease,
                      items: const [
                        DropdownMenuItem(value: 'Blast', child: Text('Blast')),
                        DropdownMenuItem(
                          value: 'BrownSpot',
                          child: Text('Brown Spot'),
                        ),
                        DropdownMenuItem(
                          value: 'BacterialBlight',
                          child: Text('Bacterial Blight'),
                        ),
                        DropdownMenuItem(value: 'None', child: Text('None')),
                      ],
                      onChanged: (val) => setState(() => _disease = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildInputField(
                      _severityController,
                      'Severity (%)',
                      '35',
                    ),
                  ),
                ],
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.redLightBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: AppTheme.accentRed,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreenDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Predict Yield & Decision',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.play_arrow_rounded, size: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppTheme.primaryGreen,
                width: 1.5,
              ),
            ),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppTheme.primaryGreen,
                width: 1.5,
              ),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ── 3. Right Card: Prediction Results ──
  Widget _buildPredictionResultsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _result == null ? Colors.white : const Color(0xFFF6FAF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _result == null ? AppTheme.borderLight : AppTheme.greenBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.greenLightBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Prediction Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryGreenDark,
                ),
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
                    Icon(
                      Icons.eco_outlined,
                      size: 48,
                      color: AppTheme.borderSubtle,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No yield prediction calculated yet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Fill parameters and click Predict Yield & Decision',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Builder(
              builder: (context) {
                final double baseYield =
                    (_result!['base_yield'] as num?)?.toDouble() ?? 0.0;
                final double diseaseLoss =
                    (_result!['disease_loss'] as num?)?.toDouble() ?? 0.0;
                final double untreatedYield =
                    (_result!['untreated_yield'] as num?)?.toDouble() ?? 0.0;
                final double treatedYield =
                    (_result!['treated_yield'] as num?)?.toDouble() ?? 0.0;
                final String decision =
                    _result!['decision']?.toString() ?? 'N/A';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Base Yield (Healthy)
                    _buildResultRow(
                      icon: Icons.grass_rounded,
                      iconBgColor: AppTheme.greenLightBg,
                      iconColor: AppTheme.primaryGreen,
                      label: 'Base Yield (Healthy)',
                      valueText: baseYield.toStringAsFixed(2),
                      unitText: 'kg/ha',
                      valueColor: AppTheme.primaryGreenDark,
                    ),
                    const SizedBox(height: 12),

                    // Row 2: Disease Loss
                    _buildResultRow(
                      icon: Icons.coronavirus_outlined,
                      iconBgColor: AppTheme.redLightBg,
                      iconColor: AppTheme.accentRed,
                      label: 'Disease Loss',
                      valueText: diseaseLoss.toStringAsFixed(2),
                      unitText: '%',
                      valueColor: AppTheme.accentRed,
                    ),
                    const SizedBox(height: 12),

                    // Row 3: Untreated Yield
                    _buildResultRow(
                      icon: Icons.filter_vintage_outlined,
                      iconBgColor: AppTheme.orangeLightBg,
                      iconColor: AppTheme.accentOrange,
                      label: 'Untreated Yield',
                      valueText: untreatedYield.toStringAsFixed(2),
                      unitText: 'kg/ha',
                      valueColor: const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 12),

                    // Row 4: Treated Yield
                    _buildResultRow(
                      icon: Icons.medical_services_outlined,
                      iconBgColor: AppTheme.blueLightBg,
                      iconColor: AppTheme.accentBlue,
                      label: 'Treated Yield',
                      valueText: treatedYield.toStringAsFixed(2),
                      unitText: 'kg/ha',
                      valueColor: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 16),

                    // Row 5: Decision Callout Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.greenLightBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.greenBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.primaryGreen,
                                size: 22,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Decision',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.eco_outlined,
                                color: AppTheme.primaryGreenDark,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                decision,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.primaryGreenDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Footnote
                    const Text(
                      '* Treated yield is calculated assuming treatment reduces disease loss by 60%.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
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

  Widget _buildResultRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String valueText,
    required String unitText,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unitText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: valueColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
