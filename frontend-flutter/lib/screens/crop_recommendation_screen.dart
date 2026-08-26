import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _moistureController = TextEditingController(text: '65');
  final TextEditingController _tempController = TextEditingController(text: '28');
  final TextEditingController _humidityController = TextEditingController(text: '80');
  final TextEditingController _nitrogenController = TextEditingController(text: '90');
  final TextEditingController _phosphorusController = TextEditingController(text: '40');
  final TextEditingController _potassiumController = TextEditingController(text: '40');
  final TextEditingController _monthController = TextEditingController(text: '4');
  final TextEditingController _lagPriceController = TextEditingController(text: '120');

  String _season = 'Yala';

  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final double currentPrice = double.tryParse(_lagPriceController.text) ?? 120.0;
      final double lag1 = currentPrice - 5;
      final double lag2 = currentPrice - 10;
      final double lag3 = currentPrice - 20;

      final payload = {
        'soil_moisture': double.parse(_moistureController.text),
        'temperature': double.parse(_tempController.text),
        'humidity': double.parse(_humidityController.text),
        'nitrogen': double.parse(_nitrogenController.text),
        'phosphorus': double.parse(_phosphorusController.text),
        'potassium': double.parse(_potassiumController.text),
        'season': _season,
        'market_data': {
          'month_num': int.parse(_monthController.text),
          'lag_price': currentPrice,
          'lag_1': lag1,
          'lag_2': lag2,
          'lag_3': lag3,
        }
      };

      final response = await ApiService.predictCropRecommendation(payload);
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
              title: const Text('Smart Crop & Market Guide'),
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
                  child: const Icon(Icons.grass_rounded,
                      color: AppTheme.primaryGreen, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paddy Variety & Market Guide',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Find optimal paddy varieties for your soil & climate and view predicted market prices',
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
                  'Field & Market Conditions',
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

            // Soil & Climate
            const Text(
              '1. SOIL & CLIMATE CONDITIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            if (isMobile) ...[
              TextFormField(
                controller: _moistureController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Moisture (%)'),
                validator: (val) => val == null || val.isEmpty ? 'Req' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tempController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Temp (°C)'),
                validator: (val) => val == null || val.isEmpty ? 'Req' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _humidityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Humidity (%)'),
                validator: (val) => val == null || val.isEmpty ? 'Req' : null,
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _moistureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Moisture (%)'),
                      validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _tempController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Temp (°C)'),
                      validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _humidityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Humidity (%)'),
                      validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // NPK Nutrients
            const Text(
              '2. NPK SOIL NUTRIENTS (kg/ha)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            if (isMobile) ...[
              TextFormField(
                controller: _nitrogenController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Nitrogen (N)'),
                validator: (val) => val == null || val.isEmpty ? 'Req' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phosphorusController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Phosphorus (P)'),
                validator: (val) => val == null || val.isEmpty ? 'Req' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _potassiumController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Potassium (K)'),
                validator: (val) => val == null || val.isEmpty ? 'Req' : null,
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nitrogenController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nitrogen (N)'),
                      validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phosphorusController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Phosphorus (P)'),
                      validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _potassiumController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Potassium (K)'),
                      validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Season & Month
            const Text(
              '3. SEASON & HARVEST TIMING',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            if (isMobile) ...[
              DropdownButtonFormField<String>(
                initialValue: _season,
                decoration: const InputDecoration(labelText: 'Season'),
                items: const [
                  DropdownMenuItem(value: 'Maha', child: Text('Maha')),
                  DropdownMenuItem(value: 'Yala', child: Text('Yala')),
                ],
                onChanged: (val) => setState(() => _season = val!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _monthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harvest Month (1-12)'),
                validator: (val) => val == null || val.isEmpty ? 'Req' : null,
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _season,
                      decoration: const InputDecoration(labelText: 'Season'),
                      items: const [
                        DropdownMenuItem(value: 'Maha', child: Text('Maha')),
                        DropdownMenuItem(value: 'Yala', child: Text('Yala')),
                      ],
                      onChanged: (val) => setState(() => _season = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _monthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harvest Month (1-12)'),
                      validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Market Lags
            const Text(
              '4. CURRENT MARKET PRICE (Rs./kg)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lagPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current Paddy Market Price (Rs./kg)',
                prefixIcon: Icon(Icons.attach_money_rounded, size: 20),
                hintText: '120',
              ),
              validator: (val) => val == null || val.isEmpty ? 'Please enter current market price' : null,
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
                onPressed: _loading ? null : _submitForm,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.psychology_rounded),
                label: Text(_loading
                    ? 'Analyzing Best Crop Varieties...'
                    : 'Find Best Crops & Market Forecast'),
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
                'Best Crop Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'Smart AI Forecast',
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
                    Icon(Icons.grass_outlined,
                        size: 48, color: AppTheme.borderSubtle),
                    SizedBox(height: 12),
                    Text(
                      'No recommendation generated',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Fill parameters and click Recommend',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // High Profit Recommendation Box
            if (_result!['recommendations']?['high_profit'] != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.greenLightBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.greenBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.emoji_events_rounded,
                            color: AppTheme.primaryGreen, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'HIGH PROFIT RECOMMENDATION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreenDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _result!['recommendations']['high_profit']['crop']
                              .toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${_formatNum(_result!['recommendations']['high_profit']['predicted_price'])}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                            const Text('/ kg forecasted',
                                style: TextStyle(
                                    fontSize: 10, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Balanced & Safe Grid
            Row(
              children: [
                if (_result!['recommendations']?['balanced'] != null)
                  Expanded(
                    child: _buildRankTile(
                      'Balanced Rank #2',
                      _result!['recommendations']['balanced']['crop'].toString(),
                      _formatNum(_result!['recommendations']['balanced']['predicted_price']),
                    ),
                  ),
                if (_result!['recommendations']?['balanced'] != null &&
                    _result!['recommendations']?['safe'] != null)
                  const SizedBox(width: 12),
                if (_result!['recommendations']?['safe'] != null)
                  Expanded(
                    child: _buildRankTile(
                      'Safe Rank #3',
                      _result!['recommendations']['safe']['crop'].toString(),
                      _formatNum(_result!['recommendations']['safe']['predicted_price']),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRankTile(String label, String crop, String price) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Text(crop,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(
            'Rs. $price / kg',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNum(dynamic val) {
    if (val == null) return '—';
    final num? n = num.tryParse(val.toString());
    if (n == null) return '—';
    return n.toStringAsFixed(2);
  }
}
