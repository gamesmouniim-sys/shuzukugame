import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import '../theme/app_theme.dart';
import '../utils/ad_action_gate.dart';
import '../widgets/glass_card.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({Key? key}) : super(key: key);

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  bool isMonitoring = false;
  Timer? _timer;
  List<FlSpot> fpsData = [];
  double cpuUsage = 0.45;
  double ramUsage = 0.60;
  double gpuUsage = 0.52;
  double batteryTemp = 42.5;
  int networkPing = 68;
  int fpsCounter = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeFpsData();
  }

  void _initializeFpsData() {
    fpsData = List.generate(
      24,
      (i) => FlSpot(i.toDouble(), 58 + sin(i / 3) * 9),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    setState(() {
      isMonitoring = true;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        fpsCounter++;

        if (fpsData.length >= 24) {
          fpsData.removeAt(0);
          for (int i = 0; i < fpsData.length; i++) {
            fpsData[i] = FlSpot(i.toDouble(), fpsData[i].y);
          }
        }

        final previousFps = fpsData.isEmpty ? 60.0 : fpsData.last.y;
        final targetFps =
            (previousFps + (_random.nextDouble() * 10 - 5)).clamp(45.0, 96.0);
        final newFps = lerpDouble(previousFps, targetFps, 0.45) ?? targetFps;
        fpsData.add(FlSpot(fpsData.length.toDouble(), newFps));

        cpuUsage =
            (cpuUsage + (_random.nextDouble() * 0.12 - 0.06)).clamp(0.25, 0.88);
        ramUsage =
            (ramUsage + (_random.nextDouble() * 0.08 - 0.04)).clamp(0.42, 0.82);
        gpuUsage =
            (gpuUsage + (_random.nextDouble() * 0.1 - 0.05)).clamp(0.3, 0.85);
        batteryTemp = (batteryTemp + (_random.nextDouble() * 1.2 - 0.6))
            .clamp(38.0, 48.0);
        networkPing = max(8, (networkPing + _random.nextInt(8) - 4).toInt());
      });
    });
  }

  void _stopMonitoring() {
    _timer?.cancel();
    setState(() {
      isMonitoring = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildControlButton(),
          const SizedBox(height: 24),
          _buildFpsChart(),
          const SizedBox(height: 24),
          _buildCpuGpuGauges(),
          const SizedBox(height: 24),
          _buildRamUsageBar(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildExportButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Performance Monitor',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (isMonitoring)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.6),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildControlButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => AdActionGate.run(
          context,
          action: isMonitoring ? _stopMonitoring : _startMonitoring,
        ),
        icon: Icon(
          isMonitoring ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
        ),
        label: Text(
          isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isMonitoring ? Colors.red[600] : AppColors.accentPurple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFpsChart() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FPS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: fpsData,
                    isCurved: true,
                    color: AppColors.accent,
                    barWidth: 3,
                    curveSmoothness: 0.28,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.accent.withValues(alpha: 0.12),
                    ),
                  ),
                ],
                minX: 0,
                maxX: 23,
                minY: 30,
                maxY: 110,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCpuGpuGauges() {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: CircularGaugePainter(
                      usage: cpuUsage,
                      color: Colors.green[400]!,
                    ),
                    child: Center(
                      child: Text(
                        '${(cpuUsage * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'CPU Usage',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: CircularGaugePainter(
                      usage: gpuUsage,
                      color: AppColors.accentPurple,
                    ),
                    child: Center(
                      child: Text(
                        '${(gpuUsage * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'GPU Usage',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRamUsageBar() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RAM Usage',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(ramUsage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [
                  Colors.green[400]!,
                  AppColors.accentPurple,
                ],
              ),
            ),
            child: FractionallySizedBox(
              widthFactor: ramUsage,
              alignment: Alignment.centerLeft,
              child: Container(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(ramUsage * 8).toStringAsFixed(1)} / 8 GB',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.thermostat,
                      color: _getTemperatureColor(),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${batteryTemp.toStringAsFixed(1)}°',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getTemperatureColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Battery Temp',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi,
                      color: _getPingColor(),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$networkPing',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getPingColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Network Ping',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => AdActionGate.run(
          context,
          action: () => _showExportBottomSheet(context),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.accent),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Performance Report',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Color _getTemperatureColor() {
    if (batteryTemp < 40) return Colors.green[400]!;
    if (batteryTemp < 45) return Colors.orange[400]!;
    return Colors.red[400]!;
  }

  Color _getPingColor() {
    if (networkPing < 30) return Colors.green[400]!;
    if (networkPing < 100) return Colors.orange[400]!;
    return Colors.red[400]!;
  }

  void _showExportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DateTime.now().toString(),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildReportRow('Avg FPS',
                        '${(fpsData.isNotEmpty ? fpsData.fold(0.0, (sum, spot) => sum + spot.y) / fpsData.length : 60).toStringAsFixed(1)}'),
                    _buildReportRow('Peak FPS',
                        '${(fpsData.isNotEmpty ? fpsData.map((e) => e.y).reduce((a, b) => a > b ? a : b) : 120).toStringAsFixed(0)}'),
                    _buildReportRow('Min FPS',
                        '${(fpsData.isNotEmpty ? fpsData.map((e) => e.y).reduce((a, b) => a < b ? a : b) : 45).toStringAsFixed(0)}'),
                    _buildReportRow(
                        'Avg CPU', '${(cpuUsage * 100).toStringAsFixed(1)}%'),
                    _buildReportRow(
                        'Avg RAM', '${(ramUsage * 8).toStringAsFixed(1)} GB'),
                    _buildReportRow(
                        'Avg GPU', '${(gpuUsage * 100).toStringAsFixed(1)}%'),
                    _buildReportRow(
                        'Peak Temp', '${batteryTemp.toStringAsFixed(1)}°C'),
                    _buildReportRow('Avg Ping', '$networkPing ms'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final report = _buildReportText();
                      Clipboard.setData(ClipboardData(text: report));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report copied to clipboard'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Copy Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _buildReportText() {
    final avgFps = fpsData.isNotEmpty
        ? fpsData.fold(0.0, (sum, spot) => sum + spot.y) / fpsData.length
        : 60.0;
    final peakFps = fpsData.isNotEmpty
        ? fpsData.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 120.0;
    final minFps = fpsData.isNotEmpty
        ? fpsData.map((e) => e.y).reduce((a, b) => a < b ? a : b)
        : 45.0;

    return [
      'Performance Report',
      'Generated: ${DateTime.now()}',
      '',
      'FPS',
      '- Avg FPS: ${avgFps.toStringAsFixed(1)}',
      '- Peak FPS: ${peakFps.toStringAsFixed(0)}',
      '- Min FPS: ${minFps.toStringAsFixed(0)}',
      '',
      'System',
      '- CPU Usage: ${(cpuUsage * 100).toStringAsFixed(1)}%',
      '- RAM Usage: ${(ramUsage * 8).toStringAsFixed(1)} GB',
      '- GPU Usage: ${(gpuUsage * 100).toStringAsFixed(1)}%',
      '- Peak Temp: ${batteryTemp.toStringAsFixed(1)} C',
      '- Ping: $networkPing ms',
    ].join('\n');
  }
}

class CircularGaugePainter extends CustomPainter {
  final double usage;
  final Color color;

  CircularGaugePainter({
    required this.usage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final gaugePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    const startAngle = -3.14159 / 2;
    const sweepAngle = 3.14159 * 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * usage,
      false,
      gaugePaint,
    );
  }

  @override
  bool shouldRepaint(CircularGaugePainter oldDelegate) =>
      oldDelegate.usage != usage;
}
