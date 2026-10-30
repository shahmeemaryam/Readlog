class Book {
  final String id;
  final String title;
  final String author;
  final double rating;
  final String favouriteLine;
  final String review;
  final String? imageUrl;
  final String dateAdded;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.rating,
    required this.favouriteLine,
    required this.review,
    this.imageUrl,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'rating': rating,
      'favouriteLine': favouriteLine,
      'review': review,
      'imageUrl': imageUrl,
      'dateAdded': dateAdded,
    };
  }

  factory Book.fromMap(String id, Map<dynamic, dynamic> map) {
    return Book(
      id: id,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      favouriteLine: map['favouriteLine'] ?? '',
      review: map['review'] ?? '',
      imageUrl: map['imageUrl'],
      dateAdded: map['dateAdded'] ?? '',
    );
  }
}