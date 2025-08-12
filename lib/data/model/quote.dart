// lib/data/model/quote.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Quote {
  final String id;
  final String text;
  final int? pageNumber;

  Quote({
    required this.id,
    required this.text,
    this.pageNumber,
  });

  factory Quote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quote(
      id: doc.id,
      text: data['text'] ?? '',
      pageNumber: data['pageNumber'],
    );
  }
}