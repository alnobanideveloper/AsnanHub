import 'package:flutter/material.dart';
import '../models/case.dart';

class CaseCard extends StatelessWidget {
  final Case caseItem;

  const CaseCard({
    super.key,
    required this.caseItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 1️⃣ Case image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: caseItem.imageUrl.isNotEmpty
                ? Image.network(
                    caseItem.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
          ),

          /// 2️⃣ Case info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Type + Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medical_services_rounded, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          caseItem.type.label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _statusChip(caseItem.state),
                  ],
                ),

                const SizedBox(height: 12),

                /// Description
                if (caseItem.description != null)
                  Text(
                    caseItem.description!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),

                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 8),

                /// Date & shift
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(caseItem.date),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      caseItem.shift.name,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _statusChip(CaseState state) {
    Color color;
    String text;

    switch (state) {
      case CaseState.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case CaseState.booked:
        color = Colors.blue;
        text = 'Booked';
        break;
      case CaseState.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case CaseState.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
