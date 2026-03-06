import 'package:flutter/material.dart';

class WithdrawalModal extends StatefulWidget {
  final double availableBalance;
  final Function(double) onWithdraw;
  const WithdrawalModal({super.key, required this.availableBalance, required this.onWithdraw});
  @override
  State<WithdrawalModal> createState() => _WithdrawalModalState();
}
class _WithdrawalModalState extends State<WithdrawalModal> {
  final _ctrl = TextEditingController();
  String _method = 'MTN Mobile Money';
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Request Withdrawal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('Available: RWF ${widget.availableBalance.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF6B7280))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _method,
          items: ['MTN Mobile Money', 'Airtel Money', 'Bank Transfer'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (v) => setState(() => _method = v!),
          decoration: InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
        const SizedBox(height: 12),
        TextField(controller: _ctrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Amount (RWF)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () { final v = double.tryParse(_ctrl.text); if (v != null && v > 0) { widget.onWithdraw(v); Navigator.pop(context); } },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
          child: const Text('Withdraw'),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
}


