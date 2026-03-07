import 'package:flutter/material.dart';

import '../../../core/booking/booking_models.dart';
import '../../../core/booking/booking_store.dart';
import '../../../core/theme/app_colors.dart';
import 'booking_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.therapistId,
    required this.patientId,
    required this.patientName,
    required this.type,
    required this.slot,
  });

  final String therapistId;
  final String patientId;
  final String patientName;
  final SessionType type;
  final BookingSlot slot;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _method;

  List<PaymentMethod> get _options {
    // onsite => VISA, CliQ, Cash
    // video  => VISA, CliQ
    if (widget.type == SessionType.onsite) {
      return [PaymentMethod.visa, PaymentMethod.cliq, PaymentMethod.cash];
    }
    return [PaymentMethod.visa, PaymentMethod.cliq];
  }

  String _label(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.visa:
        return "VISA";
      case PaymentMethod.cliq:
        return "CliQ";
      case PaymentMethod.cash:
        return "Cash";
    }
  }

  String _formatSlot(BuildContext context, DateTime dt) {
    final date =
        "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    final time = TimeOfDay.fromDateTime(dt).format(context);
    return "$date • $time";
  }

  void _payNow() {
    if (_method == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Choose a payment method."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final booking = BookingStore.instance.createBooking(
      patientId: widget.patientId,
      patientName: widget.patientName,
      therapistId: widget.therapistId,
      type: widget.type,
      slot: widget.slot,
      paymentMethod: _method!,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSuccessScreen(bookingId: booking.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeText = widget.type == SessionType.onsite ? "On-site" : "Video call";

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Session summary card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primaryTeal,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Session: $typeText\nTime: ${_formatSlot(context, widget.slot.start)}",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choose payment method",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Force teal selection for Radio tiles
            Theme(
              data: Theme.of(context).copyWith(
                radioTheme: RadioThemeData(
                  fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppColors.primaryTeal;
                    }
                    return AppColors.textSecondary;
                  }),
                ),
              ),
              child: Column(
                children: _options.map((m) {
                  final selected = _method == m;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryTeal.withOpacity(0.45)
                            : AppColors.border,
                      ),
                      color: AppColors.surface,
                    ),
                    child: RadioListTile<PaymentMethod>(
                      value: m,
                      groupValue: _method,
                      onChanged: (v) => setState(() => _method = v),
                      title: Text(
                        _label(m),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        widget.type == SessionType.onsite && m == PaymentMethod.cash
                            ? "Pay at the clinic"
                            : "Secure payment",
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      activeColor: AppColors.primaryTeal,
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                  );
                }).toList(),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _payNow,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text("Pay & Request booking"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
