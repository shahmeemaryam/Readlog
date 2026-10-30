import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'edit_book_screen.dart';
import '../models/book.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  Future<void> deleteBook(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Text(
            'Are you sure you want to delete "${book.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseDatabase.instance
          .ref('users/${user.uid}/books/${book.id}')
          .remove();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book deleted successfully.'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete book: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        actions: [
          IconButton(
            onPressed: () => deleteBook(context),
            icon: const Icon(Icons.delete),
            tooltip: 'Delete book',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               if (book.imageUrl != null &&
    book.imageUrl!.isNotEmpty)
  Hero(
    tag: 'book-${book.id}',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        book.imageUrl!,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            height: 250,
            child: Center(
              child: Icon(
                Icons.broken_image,
                size: 60,
              ),
            ),
          );
        },
      ),
    ),
  ),

                const SizedBox(height: 24),

                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                Text(
                  'by ${book.author}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(Icons.star),
                    const SizedBox(width: 8),
                    Text(
  '${book.rating.toStringAsFixed(1)} / 5',
                      
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (book.favouriteLine.isNotEmpty) ...[
                  Text(
                    'Favourite Line',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '"${book.favouriteLine}"',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (book.review.isNotEmpty) ...[
                  Text(
                    'My Review',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.review,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                   onPressed: () async {
  final updated = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => EditBookScreen(
        book: book,
      ),
    ),
  );

  if (updated == true && context.mounted) {
    Navigator.pop(context);
  }
},
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Book'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}