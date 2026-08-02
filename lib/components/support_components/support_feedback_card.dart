import 'package:flutter/material.dart';

class SupportFeedbackCard extends StatelessWidget {
  final VoidCallback onStartFeedback;

  const SupportFeedbackCard({
    super.key,
    required this.onStartFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFE5DF), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFD0F0EA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.thumb_up_alt_outlined,
              color: Color(0xFF1E705F),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Góp ý cùng Drivio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E705F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ý kiến của bạn sẽ giúp chúng tôi cải thiện chất lượng dịch vụ tốt hơn mỗi ngày.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onStartFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42B883),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
