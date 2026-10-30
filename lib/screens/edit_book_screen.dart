import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/book.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({
    super.key,
    required this.book,
  });

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late final TextEditingController titleController;
  late final TextEditingController authorController;
  late final TextEditingController quoteController;
  late final TextEditingController reviewController;
  late final TextEditingController imageUrlController;

  late double rating;
  bool isLoading = false;

  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.book.title,
    );

    authorController = TextEditingController(
      text: widget.book.author,
    );

    quoteController = TextEditingController(
      text: widget.book.favouriteLine,
    );

    reviewController = TextEditingController(
      text: widget.book.review,
    );

    imageUrlController = TextEditingController(
      text: widget.book.imageUrl ?? '',
    );

    rating = widget.book.rating;
  }

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

  Future<void> updateBook() async {
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
        throw Exception('You must be logged in.');
      }

      String imageUrl = imageUrlController.text.trim();

      // Upload a new image only if the user selected one.
      // Otherwise, keep the existing image URL.
      if (selectedImage != null) {
        final uploadedUrl = await uploadToCloudinary(selectedImage!);

        if (uploadedUrl == null) {
          throw Exception('Could not upload the new image.');
        }

        imageUrl = uploadedUrl;
      }

      await FirebaseDatabase.instance
          .ref('users/${user.uid}/books/${widget.book.id}')
          .update({
        'title': titleController.text.trim(),
        'author': authorController.text.trim(),
        'rating': rating,
        'favouriteLine': quoteController.text.trim(),
        'review': reviewController.text.trim(),
        'imageUrl': imageUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book updated successfully!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update book: $e'),
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
        title: const Text('Edit Book'),
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
                  'Edit your book',
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

                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Book Cover Image URL (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image),
                  ),
                ),

                const SizedBox(height: 16),

                // Preview the newly selected photo.
                if (selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),

                if (selectedImage != null)
                  const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: isLoading ? null : takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    selectedImage == null
                        ? 'Take New Photo'
                        : 'Retake Photo',
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : updateBook,
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
                      isLoading ? 'Saving...' : 'Save Changes',
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