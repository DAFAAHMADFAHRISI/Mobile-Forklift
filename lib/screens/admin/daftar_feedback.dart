import 'package:flutter/material.dart';

class DaftarFeedback extends StatefulWidget {
  const DaftarFeedback({super.key});

  @override
  State<DaftarFeedback> createState() => _DaftarFeedbackState();
}

class _DaftarFeedbackState extends State<DaftarFeedback> {
  final List<Map<String, dynamic>> _feedbacks = [
    {
      'id': 1,
      'order_id': 1,
      'user_name': 'Pengguna Test',
      'rating': 4,
      'komentar': 'Pelayanan sangat baik, operator ramah dan profesional.',
      'tanggal': '2024-03-20',
    },
    {
      'id': 2,
      'order_id': 2,
      'user_name': 'Pengguna Test 2',
      'rating': 5,
      'komentar': 'Forklift dalam kondisi sangat baik, pengiriman tepat waktu.',
      'tanggal': '2024-03-21',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Feedback')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _feedbacks.length,
        itemBuilder: (context, index) {
          final feedback = _feedbacks[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Feedback #${feedback['id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        feedback['tanggal'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Pemesanan #${feedback['order_id']}'),
                  Text('Dari: ${feedback['user_name']}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Rating: '),
                      ...List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          size: 20,
                          color:
                              index < feedback['rating']
                                  ? Colors.orange
                                  : Colors.grey,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Komentar:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(feedback['komentar']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
