import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/colors.dart';

class DriverEarningsScreen extends StatefulWidget {
  const DriverEarningsScreen({super.key});
  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _weeklyData = [35000.0, 42000.0, 28000.0, 45000.0, 38000.0, 25000.0, 15000.0];
  final _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final _transactions = [
    {'id': '#1001', 'hotel': 'Marriott Hotel', 'type': 'UCO Collection', 'amount': 15000, 'date': 'Today 09:15 AM', 'status': 'paid'},
    {'id': '#1002', 'hotel': 'Serena Hotel', 'type': 'Glass Collection', 'amount': 8000, 'date': 'Today 11:30 AM', 'status': 'paid'},
    {'id': '#1003', 'hotel': 'Radisson Blu', 'type': 'Cardboard Collection', 'amount': 12000, 'date': 'Yesterday 02:00 PM', 'status': 'paid'},
    {'id': '#1004', 'hotel': 'Kigali Marriott', 'type': 'UCO Collection', 'amount': 18000, 'date': 'Mar 4, 10:00 AM', 'status': 'paid'},
    {'id': '#1005', 'hotel': 'Lemigo Hotel', 'type': 'Plastic Collection', 'amount': 6000, 'date': 'Mar 3, 03:00 PM', 'status': 'paid'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Earnings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.file_download_outlined), onPressed: () => _generateReport()),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Transactions')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOverview(), _buildTransactions()],
      ),
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildTodayCard(),
        const SizedBox(height: 16),
        _buildWeeklyChart(),
        const SizedBox(height: 16),
        _buildMonthlyStats(),
        const SizedBox(height: 16),
        _buildWithdrawButton(),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildTodayCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF064e3b), Color(0xFF0e7490)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(children: [
        const Text("Today's Earnings", style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        const Text('25,000 RWF', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: const Text('+12% from yesterday', style: TextStyle(color: Colors.white, fontSize: 11))),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _earningMetric('4', 'Collections', Icons.local_shipping),
          _vDivider(),
          _earningMetric('42 km', 'Distance', Icons.speed),
          _vDivider(),
          _earningMetric('6.5 hrs', 'Online', Icons.timer),
        ]),
      ]),
    );
  }

  Widget _earningMetric(String val, String label, IconData icon) => Column(children: [
    Icon(icon, color: Colors.white70, size: 18),
    const SizedBox(height: 4),
    Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
    Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
  ]);

  Widget _vDivider() => Container(width: 1, height: 36, color: Colors.white24);

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Weekly Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)), child: const Text('228K RWF total', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 55000,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, gi, rod, ri) => BarTooltipItem('${_weekDays[group.x]}\n${(rod.toY / 1000).toStringAsFixed(0)}K', const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => Text(_weekDays[v.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)), reservedSize: 20)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) => v % 20000 == 0 ? Text('${(v / 1000).toInt()}K', style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)) : const SizedBox.shrink(), reservedSize: 28)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(_weeklyData.length, (i) => BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: _weeklyData[i], color: i == 3 ? AppColors.secondary : AppColors.primary, width: 22, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
            ])),
          )),
        ),
      ]),
    );
  }

  Widget _buildMonthlyStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('This Month', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _statCard('124', 'Total Jobs', Icons.check_circle, Colors.green)),
          const SizedBox(width: 10),
          Expanded(child: _statCard('350K', 'RWF Earned', Icons.payments, AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: _statCard('4.8★', 'Rating', Icons.star, Colors.amber)),
        ]),
      ]),
    );
  }

  Widget _statCard(String val, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildWithdrawButton() {
    return ElevatedButton.icon(
      onPressed: () => _showWithdrawModal(),
      icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
      label: const Text('Withdraw Earnings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    );
  }

  Widget _buildTransactions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (_, i) {
        final t = _transactions[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.payments, color: Colors.green, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t['hotel'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(t['type'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(t['date'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('+RWF ${t['amount']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('Paid', style: TextStyle(color: Colors.green, fontSize: 10)),
              ),
            ]),
          ]),
        );
      },
    );
  }

  void _showWithdrawModal() {
    final amountCtrl = TextEditingController();
    String _method = 'mobile';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, setModal) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const Text('Withdraw Earnings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Available balance: 125,000 RWF', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount (RWF)', prefixText: 'RWF ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 12),
          const Text('Withdraw to', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => setModal(() => _method = 'mobile'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _method == 'mobile' ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: _method == 'mobile' ? AppColors.primary : Colors.grey.shade200)),
                child: Column(children: [Icon(Icons.phone_android, color: _method == 'mobile' ? AppColors.primary : Colors.grey), const SizedBox(height: 4), Text('Mobile Money', style: TextStyle(fontSize: 11, color: _method == 'mobile' ? AppColors.primary : Colors.grey))]),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => setModal(() => _method = 'bank'),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _method == 'bank' ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: _method == 'bank' ? AppColors.primary : Colors.grey.shade200)),
                child: Column(children: [Icon(Icons.account_balance, color: _method == 'bank' ? AppColors.primary : Colors.grey), const SizedBox(height: 4), Text('Bank Account', style: TextStyle(fontSize: 11, color: _method == 'bank' ? AppColors.primary : Colors.grey))]),
              ),
            )),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Withdrawal of RWF ${amountCtrl.text} requested via ${_method == 'mobile' ? 'Mobile Money' : 'Bank'}'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Request Withdrawal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ]),
      )),
    );
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating earnings report PDF...'), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating));
  }
}
