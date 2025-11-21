import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParkDetailPage extends StatefulWidget {
  final String parkId;
  const ParkDetailPage({super.key, required this.parkId});

  @override
  State<ParkDetailPage> createState() => _ParkDetailPageState();
}

class _ParkDetailPageState extends State<ParkDetailPage> {
  Map<String, dynamic>? parkData;
  bool _loading = true;
  final reviewCtrl = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _loadParkData();
  }

  Future<void> _loadParkData() async {
    final doc = await FirebaseFirestore.instance
        .collection('parks')
        .doc(widget.parkId)
        .get();

    if (doc.exists) {
      setState(() {
        parkData = doc.data();
        _loading = false;
      });
    }
  }

  Future<void> _addReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Nombre de usuario (displayName o parte del correo)
    final userName = user.displayName ?? user.email!.split('@')[0];

    final review = {
      'user': userName,
      'comment': reviewCtrl.text.trim(),
      'stars': _rating,
    };

    await FirebaseFirestore.instance
        .collection('parks')
        .doc(widget.parkId)
        .update({
      'reviews': FieldValue.arrayUnion([review]),
    });

    reviewCtrl.clear();
    _loadParkData();
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0A4CFF);

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1F44),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // ---- LECTURA CORRECTA SEGÚN LA ESTRUCTURA FIRESTORE ----
    final images = List<String>.from(parkData!['images'] ?? []);
    final equipment = List<String>.from(parkData!['equipment'] ?? []);
    final reviews = parkData!['reviews'] == null
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(parkData!['reviews']);
    // -----------------------------------------------------------

    return Scaffold(
      backgroundColor: const Color(0xFF0A1F44),
      appBar: AppBar(
        title: Text(
          parkData!['name'] ?? 'Parque',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A1F44),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          images[index],
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Text(
              '⭐ ${parkData!['rating'] ?? 0}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Equipamiento:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...equipment.map(
              (e) => Text(
                '• $e',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white30),
            const Text(
              'Reseñas:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...reviews.map(
              (r) => ListTile(
                title: Text(
                  r['user'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                subtitle: Text(
                  r['comment'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  '⭐ ${r['stars']}',
                  style: const TextStyle(color: Color(0xFFFFFFFF)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white30),
            const Text(
              'Deja tu reseña:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (i) => IconButton(
                  icon: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = i + 1),
                ),
              ),
            ),
            TextField(
              controller: reviewCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe tu opinión...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF0A1F44),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _addReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: const Text('Enviar reseña'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
