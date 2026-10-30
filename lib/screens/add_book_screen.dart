import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final quoteController = TextEditingController();
  final reviewController = TextEditingController();
  final imageUrlController = TextEditingController();

  double rating = 3.0;
  bool isLoading = false;

File? selectedImage;
final ImagePicker imagePicker = ImagePicker();

Future<void> takePhoto() async {
  try {
    final XFile? photo = await imagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (photo == null) {
      return;
    }

    setState(() {
      selectedImage = File(photo.path);
    });
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not access the camera. Please check camera permission.',
        ),
      ),
    );
  }
}

  Future<void> saveBook() async {
    if (titleController.text.trim().isEmpty ||
        authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the book title and author.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('You must be logged in to add a book.');
  }

  final booksRef = FirebaseDatabase.instance
      .ref('users/${user.uid}/books');

  final bookRef = booksRef.push();

  String imageUrl = imageUrlController.text.trim();

  if (selectedImage != null) {
    final uploadedUrl = await uploadToCloudinary(selectedImage!);

    if (uploadedUrl != null) {
      imageUrl = uploadedUrl;
    }
  }

  await bookRef.set({
    'title': titleController.text.trim(),
    'author': authorController.text.trim(),
    'rating': rating,
    'favouriteLine': quoteController.text.trim(),
    'review': reviewController.text.trim(),
    'imageUrl': imageUrl,
    'dateAdded': DateTime.now().toIso8601String(),
  });
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book added successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save book: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  Future<String?> uploadToCloudinary(File imageFile) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.cloudinary.com/v1_1/dfwh5sjl/image/upload',
      ),
    );

    request.fields['upload_preset'] = 'readlogPreset';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();

      final data = jsonDecode(responseBody);

      return data['secure_url'];
    }

    return null;
  } catch (e) {
    return null;
  }
}

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    quoteController.dispose();
    reviewController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add a book to your library',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Book Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(
                    labelText: 'Author',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Rating',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Slider(
                  value: rating,
                  min: 1,
                  max: 5,
                  divisions: 8,
                  label: rating.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      rating = value;
                    });
                  },
                ),

                Center(
                  child: Text(
                    '${rating.toStringAsFixed(1)} / 5',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: quoteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Favourite Line / Quote',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.format_quote),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: reviewController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Review',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.rate_review),
                  ),
                ),

               const SizedBox(height: 16),

if (selectedImage != null)
  ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.file(
      selectedImage!,
      width: double.infinity,
      height: 250,
      fit: BoxFit.cover,
    ),
  ),

if (selectedImage != null)
  const SizedBox(height: 12),

SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: takePhoto,
    icon: const Icon(Icons.camera_alt),
    label: const Text('Take Photo of Book'),
  ),
),

const SizedBox(height: 16),

TextField(
  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Book Cover Image URL (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : saveBook,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      isLoading ? 'Saving...' : 'Save Book',
                    ),
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