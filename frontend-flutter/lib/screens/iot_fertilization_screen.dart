import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';

class IoTFertilizationScreen extends StatefulWidget {
  const IoTFertilizationScreen({super.key});

  @override
  State<IoTFertilizationScreen> createState() => _IoTFertilizationScreenState();
}

class _IoTFertilizationScreenState extends State<IoTFertilizationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _moistureController = TextEditingController(text: '0');
  final TextEditingController _tempController = TextEditingController(text: '28.5');
  final TextEditingController _phController = TextEditingController(text: '6.5');
  final TextEditingController _nitrogenController = TextEditingController(text: '0');
  final TextEditingController _phosphorusController = TextEditingController(text: '0');
  final TextEditingController _potassiumController = TextEditingController(text: '0');
  final TextEditingController _humidityController = TextEditingController(text: '95');

  String _growthStage = 'tillering';
  String _riceVariety = 'Bg 300';

  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  // Firebase RTDB Live Sync States
  bool _autoSync = true;
  bool _syncing = false;
  DateTime? _lastSynced;
  String? _syncError;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _fetchFirebaseTelemetry();
    _startSyncTimer();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    if (_autoSync) {
      _syncTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _fetchFirebaseTelemetry();
      });
    }
  }

  Future<void> _fetchFirebaseTelemetry() async {
    if (!mounted) return;
    setState(() {
      _syncing = true;
      _syncError = null;
    });

    try {
      final data = await FirebaseService.fetchLatestTelemetry();
      if (data != null && mounted) {
        setState(() {
          if (data.containsKey('soilMoisturePercentage')) {
            _moistureController.text = data['soilMoisturePercentage'].toString();
          }
          if (data.containsKey('temperature')) {
            _tempController.text = data['temperature'].toString();
          }
          if (data.containsKey('humidity')) {
            _humidityController.text = data['humidity'].toString();
          }
          if (data.containsKey('nitrogen')) {
            _nitrogenController.text = data['nitrogen'].toString();
          }
          if (data.containsKey('phosphorus')) {
            _phosphorusController.text = data['phosphorus'].toString();
          }
          if (data.containsKey('potassium')) {
            _potassiumController.text = data['potassium'].toString();
          }
          _lastSynced = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncError = 'Firebase RTDB unreachable';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _syncing = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final payload = {
        'soil_moisture': double.parse(_moistureController.text),
        'soil_temp': double.parse(_tempController.text),
        'soil_ph': double.parse(_phController.text),
        'nitrogen': double.parse(_nitrogenController.text),
        'phosphorus': double.parse(_phosphorusController.text),
        'potassium': double.parse(_potassiumController.text),
        'humidity': double.parse(_humidityController.text),
        'growth_stage': _growthStage,
        'rice_variety': _riceVariety,
      };

      final response = await ApiService.predictFertilization(payload);
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
              title: const Text('Soil & Fertilizer Advisor'),
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
                  child: const Icon(Icons.water_drop_rounded,
                      color: AppTheme.primaryGreen, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soil Health & Fertilizer Advisor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Live soil sensor telemetry & precision NPK fertilizer dosage guidance',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Firebase Live Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.greenBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.greenLightBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cell_tower_rounded,
                        color: AppTheme.primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Live Field Sensors',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _syncing
                                    ? Colors.amber
                                    : _syncError != null
                                        ? Colors.red
                                        : AppTheme.accentEmerald,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Station: Soil Field Monitor ${_lastSynced != null ? "• Synced ${_lastSynced!.hour}:${_lastSynced!.minute}:${_lastSynced!.second}" : ""}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _syncing ? null : _fetchFirebaseTelemetry,
                    icon: Icon(Icons.refresh_rounded,
                        size: 16,
                        color: _syncing
                            ? AppTheme.textSecondary
                            : AppTheme.primaryGreen),
                    label: const Text('Sync Now',
                        style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.greenBorder),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(_autoSync ? 'Live ON' : 'Live OFF',
                        style: const TextStyle(fontSize: 11)),
                    selected: _autoSync,
                    selectedColor: AppTheme.greenLightBg,
                    onSelected: (val) {
                      setState(() {
                        _autoSync = val;
                      });
                      _startSyncTimer();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _buildFormCard(isMobile: false)),
                      const SizedBox(width: 24),
                      Expanded(flex: 5, child: _buildResultsCard()),
                    ],
                  )
                : Column(
                    children: [
                      _buildFormCard(isMobile: !isDesktop),
                      const SizedBox(height: 24),
                      _buildResultsCard(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Soil & Sensor Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.greenLightBg,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Text(
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

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1. SOIL TELEMETRY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
                Text('⚡ Sensor Synced',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (isMobile) ...[
              TextFormField(
                controller: _moistureController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Moisture (%)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tempController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Soil Temp (°C)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Soil pH',
                  helperText: 'Manual Input',
                  helperStyle: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _moistureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Moisture (%)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _tempController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Soil Temp (°C)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Soil pH',
                        helperText: 'Manual Input',
                        helperStyle: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '2. NPK NUTRIENT CONCENTRATION (kg/ha)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
                Text('⚡ Sensor Synced',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (isMobile) ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nitrogenController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nitrogen (N)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _phosphorusController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Phosphorus (P)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _potassiumController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Potassium (K)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _humidityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Humidity (%)'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nitrogenController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nitrogen (N)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _phosphorusController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Phosphorus (P)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _potassiumController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Potassium (K)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _humidityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Humidity (%)'),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '3. GROWTH STAGE & RICE VARIETY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
                Text('✏️ Field Data',
                    style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (isMobile) ...[
              DropdownButtonFormField<String>(
                initialValue: _growthStage,
                decoration: const InputDecoration(labelText: 'Growth Stage'),
                items: const [
                  DropdownMenuItem(
                      value: 'germination', child: Text('germination')),
                  DropdownMenuItem(
                      value: 'tillering', child: Text('tillering')),
                  DropdownMenuItem(
                      value: 'panicle initiation',
                      child: Text('panicle initiation')),
                  DropdownMenuItem(
                      value: 'heading', child: Text('heading')),
                  DropdownMenuItem(
                      value: 'grain filling', child: Text('grain filling')),
                ],
                onChanged: (val) => setState(() => _growthStage = val!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _riceVariety,
                decoration: const InputDecoration(labelText: 'Rice Variety'),
                items: const [
                  DropdownMenuItem(value: 'Bg 300', child: Text('Bg 300')),
                  DropdownMenuItem(value: 'Bg 352', child: Text('Bg 352')),
                  DropdownMenuItem(value: 'Bg 360', child: Text('Bg 360')),
                  DropdownMenuItem(value: 'Bg 366', child: Text('Bg 366')),
                  DropdownMenuItem(
                      value: 'Bg 94-1', child: Text('Bg 94-1')),
                  DropdownMenuItem(value: 'Bg 403', child: Text('Bg 403')),
                ],
                onChanged: (val) => setState(() => _riceVariety = val!),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _growthStage,
                      decoration: const InputDecoration(labelText: 'Growth Stage'),
                      items: const [
                        DropdownMenuItem(
                            value: 'germination', child: Text('germination')),
                        DropdownMenuItem(
                            value: 'tillering', child: Text('tillering')),
                        DropdownMenuItem(
                            value: 'panicle initiation',
                            child: Text('panicle initiation')),
                        DropdownMenuItem(
                            value: 'heading', child: Text('heading')),
                        DropdownMenuItem(
                            value: 'grain filling', child: Text('grain filling')),
                      ],
                      onChanged: (val) => setState(() => _growthStage = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _riceVariety,
                      decoration: const InputDecoration(labelText: 'Rice Variety'),
                      items: const [
                        DropdownMenuItem(value: 'Bg 300', child: Text('Bg 300')),
                        DropdownMenuItem(value: 'Bg 352', child: Text('Bg 352')),
                        DropdownMenuItem(value: 'Bg 360', child: Text('Bg 360')),
                        DropdownMenuItem(value: 'Bg 366', child: Text('Bg 366')),
                        DropdownMenuItem(
                            value: 'Bg 94-1', child: Text('Bg 94-1')),
                        DropdownMenuItem(value: 'Bg 403', child: Text('Bg 403')),
                      ],
                      onChanged: (val) => setState(() => _riceVariety = val!),
                    ),
                  ),
                ],
              ),
            ],

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
                onPressed: _loading ? null : _submitForm,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.speed_rounded),
                label: Text(_loading
                    ? 'Calculating Soil Nutrients...'
                    : 'Calculate Fertilizer Dosage'),
              ),
            ),
          ],
        ),
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
                'Fertilizer Guidance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Smart AI Analysis',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const Divider(height: 24, color: AppTheme.borderLight),

          if (_result == null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.water_drop_outlined,
                        size: 48, color: AppTheme.borderSubtle),
                    SizedBox(height: 12),
                    Text(
                      'No soil recommendation calculated yet',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Click Calculate Fertilizer Dosage',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _result!['fertilizer_needed'] == true
                    ? const Color(0xFFFFF7ED)
                    : AppTheme.greenLightBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _result!['fertilizer_needed'] == true
                      ? const Color(0xFFFFEDD5)
                      : AppTheme.greenBorder,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _result!['fertilizer_needed'] == true
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_rounded,
                    size: 36,
                    color: _result!['fertilizer_needed'] == true
                        ? const Color(0xFFEA580C)
                        : AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result!['fertilizer_needed'] == true
                        ? 'Fertilizer Required'
                        : 'No Fertilizer Needed',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _result!['fertilizer_needed'] == true
                          ? const Color(0xFFC2410C)
                          : AppTheme.primaryGreenDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgCanvas,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  const Text(
                    'RECOMMENDED DOSAGE QUANTITY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatNum(_result!['recommended_amount'])} ${_result!['unit'] ?? "kg/ha"}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Optimal fertilizer dosage calculated for your field',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
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
