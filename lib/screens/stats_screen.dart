import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/book.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in again.'),
        ),
      );
    }

    final booksRef =
        FirebaseDatabase.instance.ref('users/${user.uid}/books');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Stats'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: booksRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load statistics.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data?.snapshot.value;

          if (data == null || data is! Map) {
            return const Center(
              child: Text(
                'Add some books to see your reading statistics.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final books = <Book>[];

          for (final entry in data.entries) {
            if (entry.value is Map) {
              final bookData =
                  Map<dynamic, dynamic>.from(entry.value as Map);

              books.add(
                Book.fromMap(
                  entry.key.toString(),
                  bookData,
                ),
              );
            }
          }

          if (books.isEmpty) {
            return const Center(
              child: Text(
                'Add some books to see your reading statistics.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final totalBooks = books.length;

          final averageRating =
              books.map((book) => book.rating).reduce((a, b) => a + b) /
                  totalBooks;

          final favouriteBook = books.reduce(
            (current, next) =>
                next.rating > current.rating ? next : current,
          );

          final ratingCounts = <double, int>{
            5.0: 0,
            4.5: 0,
            4.0: 0,
            3.5: 0,
            3.0: 0,
            2.5: 0,
            2.0: 0,
            1.5: 0,
            1.0: 0,
          };

          for (final book in books) {
            ratingCounts[book.rating] =
                (ratingCounts[book.rating] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Reading Overview',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.menu_book,
                            title: 'Total Books',
                            value: '$totalBooks',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.star,
                            title: 'Average Rating',
                            value:
                                '${averageRating.toStringAsFixed(1)} / 5',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '❤️ Favourite Book',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              favouriteBook.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text('by ${favouriteBook.author}'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.star),
                                const SizedBox(width: 6),
                                Text(
                                  '${favouriteBook.rating.toStringAsFixed(1)} / 5',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rating Breakdown',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            for (final entry in ratingCounts.entries)
                              if (entry.value > 0)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          entry.key
                                              .toStringAsFixed(1),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.star,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${entry.value} book${entry.value == 1 ? '' : 's'}',
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}