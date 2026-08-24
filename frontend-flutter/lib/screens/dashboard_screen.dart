import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../widgets/dashboard_painters.dart';
import 'login_screen.dart';
import 'yield_treatment_screen.dart';
import 'crop_recommendation_screen.dart';
import 'iot_fertilization_screen.dart';
import 'disease_detection_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _telemetryData;
  bool _isLoadingTelemetry = false;

  @override
  void initState() {
    super.initState();
    _loadTelemetry();
  }

  Future<void> _loadTelemetry() async {
    setState(() => _isLoadingTelemetry = true);
    final data = await FirebaseService.fetchLatestTelemetry();
    if (mounted) {
      setState(() {
        _telemetryData = data;
        _isLoadingTelemetry = false;
      });
    }
  }

  void _openLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isDesktop = sw >= 900;

    return ValueListenableBuilder<UserModel?>(
      valueListenable: FirebaseService.currentUserNotifier,
      builder: (context, currentUser, _) {
        final user = currentUser ?? UserModel.defaultGuest();

        return Scaffold(
          backgroundColor: AppTheme.bgCanvas,
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 28 : 16,
              vertical: isDesktop ? 24 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row (Greeting, System Status, User Avatar)
                _buildHeaderBar(context, user, isDesktop),

                const SizedBox(height: 20),

                // 2. Top 5 Metric Strip Cards
                _buildTopMetricsStrip(isDesktop),

                const SizedBox(height: 24),

                // 3. Main Grid Row 1 (IoT Telemetry Monitor + Alerts & Quick Actions)
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: IoT Monitor (Flex 6)
                      Expanded(flex: 6, child: _buildIotRealtimeMonitorCard()),
                      const SizedBox(width: 20),
                      // Right Column: Alerts & Quick Actions (Flex 4)
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            _buildAlertsCard(),
                            const SizedBox(height: 20),
                            _buildQuickActionsCard(context),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildIotRealtimeMonitorCard(),
                      const SizedBox(height: 20),
                      _buildAlertsCard(),
                      const SizedBox(height: 20),
                      _buildQuickActionsCard(context),
                    ],
                  ),

                const SizedBox(height: 24),

                // 4. Main Grid Row 2 (Sensor Trends & AI Insights + Recommendations + Recent Activity)
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Sensor Trends & AI Insights (Flex 5)
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildSensorTrendsCard(),
                            const SizedBox(height: 20),
                            _buildAiInsightsCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Middle Column: Upcoming Recommendations (Flex 4)
                      Expanded(flex: 4, child: _buildUpcomingRecommendationsCard()),
                      const SizedBox(width: 20),
                      // Right Column: Recent Activity (Flex 3)
                      Expanded(flex: 3, child: _buildRecentActivityCard()),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildSensorTrendsCard(),
                      const SizedBox(height: 20),
                      _buildAiInsightsCard(),
                      const SizedBox(height: 20),
                      _buildUpcomingRecommendationsCard(),
                      const SizedBox(height: 20),
                      _buildRecentActivityCard(),
                    ],
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 1. Top Header Bar ──
  Widget _buildHeaderBar(BuildContext context, UserModel user, bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Good morning, ${user.fullName.split(' ').first}! 🌾',
                    style: TextStyle(
                      fontSize: isDesktop ? 22 : 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Welcome back to your smart farming dashboard.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        // System Status Pill
        if (isDesktop)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: AppTheme.primaryGreen, size: 8),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'System Status',
                      style: TextStyle(fontSize: 9, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'All Systems Online',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(width: 14),
        // Notifications Bell Button
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: const Icon(Icons.notifications_none_rounded, color: AppTheme.textSecondary, size: 20),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.accentRed,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // User Profile Dropdown Button
        InkWell(
          onTap: _openLoginScreen,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.greenLightBg,
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'F',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.split(' ').first,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const Text(
                      'Active User',
                      style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 2. Top Metrics Strip Cards ──
  Widget _buildTopMetricsStrip(bool isDesktop) {
    final metrics = [
      _MetricStripData(
        title: 'Field Health Score',
        value: '87%',
        subtitle: 'Very Good',
        color: AppTheme.primaryGreen,
        icon: Icons.shield_rounded,
        sparkline: [60, 65, 70, 68, 75, 82, 87],
      ),
      _MetricStripData(
        title: 'Expected Yield',
        value: '4,320 kg/ha',
        subtitle: '↑ 12% from last week',
        color: AppTheme.accentOrange,
        icon: Icons.scale_rounded,
        sparkline: [3500, 3700, 3900, 3850, 4100, 4320],
      ),
      _MetricStripData(
        title: 'Water Level',
        value: 'Optimal',
        subtitle: 'Good',
        color: AppTheme.accentBlue,
        icon: Icons.water_drop_rounded,
        sparkline: [50, 60, 55, 70, 65, 68.5],
      ),
      _MetricStripData(
        title: 'Fertilizer Status',
        value: 'Recommended',
        subtitle: 'Check IoT Module',
        color: AppTheme.primaryGreen,
        icon: Icons.grain_rounded,
        sparkline: [40, 50, 45, 60, 58, 62],
      ),
      _MetricStripData(
        title: 'Disease Risk',
        value: 'Low',
        subtitle: 'Keep Monitoring',
        color: AppTheme.accentPurple,
        icon: Icons.security_rounded,
        sparkline: [80, 85, 90, 88, 92, 94],
      ),
    ];

    if (isDesktop) {
      return Row(
        children: metrics.map((m) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildMetricStripCard(m),
            ),
          );
        }).toList(),
      );
    } else {
      // Mobile: Horizontal Scrollable Strip
      return SizedBox(
        height: 94,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            return Container(
              width: 190,
              margin: const EdgeInsets.only(right: 12),
              child: _buildMetricStripCard(metrics[index]),
            );
          },
        ),
      );
    }
  }

  Widget _buildMetricStripCard(_MetricStripData m) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: m.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(m.icon, color: m.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  m.title,
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  m.value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  m.subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: m.subtitle.startsWith('↑') ? AppTheme.primaryGreenDark : AppTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Mini Sparkline Graph
          SizedBox(
            width: 38,
            height: 24,
            child: CustomPaint(
              painter: SparklinePainter(values: m.sparkline, lineColor: m.color),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. IoT Real-time Monitor Card ──
  Widget _buildIotRealtimeMonitorCard() {
    final double moisture = (_telemetryData?['moisture'] as num?)?.toDouble() ?? 90.0;
    final double temp = (_telemetryData?['temperature'] as num?)?.toDouble() ?? 28.5;
    final double humidity = (_telemetryData?['humidity'] as num?)?.toDouble() ?? 95.0;
    final double n = (_telemetryData?['nitrogen'] as num?)?.toDouble() ?? 12.0;
    final double p = (_telemetryData?['phosphorus'] as num?)?.toDouble() ?? 28.0;
    final double k = (_telemetryData?['potassium'] as num?)?.toDouble() ?? 78.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'IoT Real-time Monitor',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.greenLightBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: AppTheme.primaryGreen, size: 6),
                        SizedBox(width: 4),
                        Text('LIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark)),
                      ],
                    ),
                  ),
                ],
              ),
              const Text(
                'Last Updated: 10:24:30 AM',
                style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 6 Telemetry Tiles Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 500 ? 3 : 2;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _buildIotTile('Soil Moisture', '${moisture.toInt()} %', 'Saturated', Icons.water_drop_outlined, const Color(0xFF3B82F6), [60, 70, 75, 80, 88, 90]),
                  _buildIotTile('Temperature', '$temp °C', 'Normal', Icons.thermostat_outlined, const Color(0xFFF97316), [25, 26, 27, 28, 28.2, 28.5]),
                  _buildIotTile('Humidity', '${humidity.toInt()} %', 'High', Icons.water_outlined, const Color(0xFF3B82F6), [70, 80, 85, 90, 92, 95]),
                  _buildIotTile('Nitrogen (N)', '${n.toInt()} mg/kg', 'Low', Icons.grass_outlined, const Color(0xFF10B981), [20, 18, 15, 14, 13, 12]),
                  _buildIotTile('Phosphorus (P)', '${p.toInt()} mg/kg', 'Medium', Icons.grain_outlined, const Color(0xFFF97316), [22, 24, 25, 27, 26, 28]),
                  _buildIotTile('Potassium (K)', '${k.toInt()} mg/kg', 'Optimal', Icons.bolt_outlined, const Color(0xFF8B5CF6), [65, 70, 72, 75, 76, 78]),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.borderLight),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.circle, color: AppTheme.primaryGreen, size: 6),
                  SizedBox(width: 6),
                  Text('Data Source: Firebase Realtime Database', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ],
              ),
              InkWell(
                onTap: _isLoadingTelemetry ? null : _loadTelemetry,
                child: Row(
                  children: [
                    const Text('Auto refresh every 5 sec ', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    _isLoadingTelemetry
                        ? const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5))
                        : const Icon(Icons.refresh_rounded, size: 12, color: AppTheme.textMuted),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIotTile(String title, String value, String status, IconData icon, Color color, List<double> sparkline) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 18,
            child: CustomPaint(
              painter: SparklinePainter(values: sparkline, lineColor: color),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Alerts & Notifications Card ──
  Widget _buildAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alerts & Notifications',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 20)),
                child: const Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAlertItem(Icons.water_drop_rounded, AppTheme.accentBlue, 'High Humidity Detected', 'Humidity is 95%. Monitor for fungal diseases.', '2 min ago'),
          const SizedBox(height: 10),
          _buildAlertItem(Icons.science_rounded, AppTheme.accentOrange, 'Low Nitrogen', 'Nitrogen level is low. Fertilizer may be required.', '10 min ago'),
          const SizedBox(height: 10),
          _buildAlertItem(Icons.check_circle_rounded, AppTheme.primaryGreen, 'System Status', 'All IoT sensors are working normally.', '15 min ago'),
        ],
      ),
    );
  }

  Widget _buildAlertItem(IconData icon, Color color, String title, String body, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text(body, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        Text(time, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ],
    );
  }

  // ── 6. Quick Actions (The 4 Component Buttons!) ──
  Widget _buildQuickActionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              _buildActionButton(
                context,
                title: 'Yield & Treatment',
                subtitle: 'Predict yield & make treatment decisions',
                icon: Icons.trending_up_rounded,
                color: AppTheme.primaryGreen,
                route: const YieldTreatmentScreen(),
              ),
              _buildActionButton(
                context,
                title: 'Crop Recommendation',
                subtitle: 'Find best crop & market prediction',
                icon: Icons.grass_rounded,
                color: AppTheme.accentBlue,
                route: const CropRecommendationScreen(),
              ),
              _buildActionButton(
                context,
                title: 'IoT Fertilization',
                subtitle: 'Check fertilizer requirement',
                icon: Icons.wifi_tethering_rounded,
                color: AppTheme.accentOrange,
                route: const IoTFertilizationScreen(),
              ),
              _buildActionButton(
                context,
                title: 'Disease Detection',
                subtitle: 'Upload leaf image & detect disease',
                icon: Icons.center_focus_strong_rounded,
                color: AppTheme.accentPurple,
                route: const DiseaseDetectionScreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required Widget route}) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.bgCanvas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(subtitle, style: const TextStyle(fontSize: 8, color: AppTheme.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 7. Sensor Trends Line Chart Card ──
  Widget _buildSensorTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sensor Trends (Last 24 Hours)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              const Row(
                children: [
                  _LegendDot(color: Color(0xFF3B82F6), label: 'Moisture'),
                  SizedBox(width: 8),
                  _LegendDot(color: Color(0xFFF97316), label: 'Temp'),
                  SizedBox(width: 8),
                  _LegendDot(color: Color(0xFF10B981), label: 'Humidity'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Multi-series Custom Chart
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: TrendsChartPainter(
                moistureData: [60, 68, 62, 70, 72, 78, 75, 82, 85, 80],
                tempData: [28, 27, 29, 32, 35, 30, 28, 29, 30, 28.5],
                humidityData: [85, 88, 90, 92, 94, 95, 93, 94, 95, 95],
                timeLabels: ['10:00', '14:00', '18:00', '22:00', '02:00', '06:00', '10:00'],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
              Text('14:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
              Text('18:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
              Text('22:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
              Text('02:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
              Text('06:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
              Text('10:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  // ── 8. AI Insights Box ──
  Widget _buildAiInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.greenLightBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greenBorder),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryGreen, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insights',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark),
                ),
                SizedBox(height: 2),
                Text(
                  'Soil moisture is very high. Ensure proper drainage to avoid root damage. Nitrogen level is low - consider fertilization.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textPrimary, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 9. Upcoming Recommendations Card ──
  Widget _buildUpcomingRecommendationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Recommendations',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 14),
          _buildRecItem(Icons.water_drop_outlined, AppTheme.primaryGreen, 'Irrigation', 'No irrigation needed today', 'Optimal', AppTheme.greenLightBg),
          const SizedBox(height: 10),
          _buildRecItem(Icons.science_outlined, AppTheme.accentOrange, 'Fertilizer', 'Nitrogen fertilizer recommended', 'In 1 day', AppTheme.orangeLightBg),
          const SizedBox(height: 10),
          _buildRecItem(Icons.security_outlined, AppTheme.accentPurple, 'Pest Control', 'Low risk. Continue monitoring', 'In 2 days', AppTheme.purpleLightBg),
          const SizedBox(height: 10),
          _buildRecItem(Icons.grass_outlined, AppTheme.accentBlue, 'Weed Control', 'Weed level is acceptable', 'In 3 days', AppTheme.blueLightBg),
        ],
      ),
    );
  }

  Widget _buildRecItem(IconData icon, Color color, String title, String desc, String badge, Color badgeBg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCanvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(desc, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
            child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  // ── 10. Recent Activity Card ──
  Widget _buildRecentActivityCard() {
    final activities = [
      _ActivityItem('10:24 AM', 'Sensor data updated', 'All sensors data refreshed', AppTheme.primaryGreen),
      _ActivityItem('10:15 AM', 'IoT Fertilization checked', 'Fertilizer recommended: 33.72 kg/ha', AppTheme.accentOrange),
      _ActivityItem('10:05 AM', 'Disease detection completed', 'Leaf image analyzed - No disease detected', AppTheme.accentPurple),
      _ActivityItem('09:50 AM', 'Yield prediction completed', 'Expected yield: 4,320 kg/ha', AppTheme.primaryGreen),
      _ActivityItem('09:30 AM', 'System initialized', 'All systems online and working', AppTheme.accentBlue),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 20)),
                child: const Text('View All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreenDark)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: activities.map((a) => _buildTimelineItem(a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(_ActivityItem a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 54,
            child: Text(a.time, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
          ),
          Icon(Icons.circle, color: a.color, size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(a.desc, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Auxiliary Data & Legend Helpers ──
class _MetricStripData {
  final String title, value, subtitle;
  final Color color;
  final IconData icon;
  final List<double> sparkline;
  _MetricStripData({required this.title, required this.value, required this.subtitle, required this.color, required this.icon, required this.sparkline});
}



class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 6),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ],
    );
  }
}

class _ActivityItem {
  final String time, title, desc;
  final Color color;
  _ActivityItem(this.time, this.title, this.desc, this.color);
}
