import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player_connect/data/models/post_models.dart';
import 'package:player_connect/presentation/bloc/community/community_bloc.dart';
import 'package:player_connect/presentation/bloc/community/community_event.dart';
import 'package:player_connect/presentation/widgets/custom_button.dart';
import 'package:player_connect/presentation/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  void _createPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    http.MultipartFile? multipartFile;
    if (_imageFile != null) {
      final bytes = await _imageFile!.readAsBytes();
      multipartFile = http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: _imageFile!.name,
      );
    }

    final postRequest = PostRequest(
      title: _titleController.text,
      content: _contentController.text,
      userId: 1, // TODO: Get actual user ID from authentication
      image: multipartFile,
    );

    context.read<CommunityBloc>().add(CreatePost(postRequest));
    Navigator.of(context).pop(); // Go back to community screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hintText: 'Enter post title',
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                controller: _contentController,
                label: 'Content',
                hintText: 'Enter post content',
                maxLines: 5,
              ),
              const SizedBox(height: 16.0),
              
              const SizedBox(height: 16.0),
              _imageFile == null
                  ? CustomButton(
                      text: 'Pick Image',
                      onPressed: _pickImage,
                    )
                  : Image.network(_imageFile!.path, height: 150),
              const SizedBox(height: 16.0),
              CustomButton(
                text: 'Create Post',
                onPressed: _createPost,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
