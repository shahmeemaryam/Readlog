import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/book.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

 
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
        title: const Text('My Reading Library'),
        
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load your books.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data?.snapshot.value;

          if (data == null) {
            return const Center(
              child: Text(
                'No books found.',
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          if (data is! Map) {
            return const Center(
              child: Text(
                'Unexpected data format.',
                style: TextStyle(fontSize: 20),
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
                'No books found.',
                style: TextStyle(fontSize: 20),
              ),
            );
          }

          return OrientationBuilder(
  builder: (context, orientation) {
    if (orientation == Orientation.landscape) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return _BookCard(book: books[index]);
        },
      );
    }

    final isSmallWidth = MediaQuery.of(context).size.width < 400;

return ListView.builder(
  padding: EdgeInsets.all(isSmallWidth ? 10 : 16),
  itemCount: books.length,
  itemBuilder: (context, index) {
    return _BookCard(book: books[index]);
  },
);
  },
);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBookScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ),
    );
  }
}

class _BookCard extends StatefulWidget {
  final Book book;

  const _BookCard({
    required this.book,
  });

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          isHovered ? -3 : 0,
          0,
        ),
        child: Card(
          elevation: isHovered ? 6 : 1,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(
                    book: widget.book,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(isLandscape ? 10 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.book.imageUrl != null &&
                      widget.book.imageUrl!.isNotEmpty) ...[
                    Hero(
                      tag: 'book-${widget.book.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.book.imageUrl!,
                          width: double.infinity,
                          height: isLandscape ? 100 : 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              height: isLandscape ? 100 : 180,
                              child: const Center(
                                child: Icon(Icons.broken_image),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 6 : 12),
                  ],

                  Text(
                    widget.book.title,
                    style:
                        Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'by ${widget.book.author}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.book.rating.toStringAsFixed(1)} / 5',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (widget.book.review.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.book.review,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      'View details',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}