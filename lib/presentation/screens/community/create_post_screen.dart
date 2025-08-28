import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:player_connect/data/models/post_models.dart';
import 'package:player_connect/presentation/bloc/community/community_bloc.dart';
import 'package:player_connect/presentation/bloc/community/community_event.dart';
import 'package:player_connect/presentation/bloc/community/community_state.dart';
import 'package:player_connect/presentation/widgets/custom_button.dart';
import 'package:player_connect/presentation/widgets/custom_text_field.dart';

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
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        print('Image picked: ${image.path}');
        print('Image name: ${image.name}');
        print('Image size: ${await image.length()} bytes');
        
        setState(() {
          _imageFile = image;
        });
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _generateAiContent() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    try {
      final Uint8List imageBytes = await _imageFile!.readAsBytes();
      context.read<CommunityBloc>().add(GenerateAiContent(imageBytes));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reading image: $e')),
      );
    }
  }

  void _createPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    MultipartFile? multipartFile;
    if (_imageFile != null) {
      final bytes = await _imageFile!.readAsBytes();
      multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: _imageFile!.name,
        contentType: MediaType('image', 'jpeg'),
      );
    }

    final postRequest = PostRequest(
      title: _titleController.text,
      content: _contentController.text,
      userId: 1, // TODO: Get actual user ID from authentication
      image: multipartFile,
    );

    context.read<CommunityBloc>().add(CreatePost(postRequest));
    // Don't pop immediately - wait for success/failure in BlocListener
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is CreatePostSuccess) {
          // Refresh the posts list before going back
          context.read<CommunityBloc>().add(FetchPosts());
          Navigator.of(context).pop(); // Go back to community screen
        } else if (state is CreatePostFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create post: ${state.message}')),
          );
        } else if (state is AiContentGenerated) {
          setState(() {
            _titleController.text = state.title;
            _contentController.text = state.content;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI content generated successfully!')),
          );
        } else if (state is AiContentGenerationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI generation failed: ${state.message}')),
          );
        }
      },
      child: BlocBuilder<CommunityBloc, CommunityState>(
        builder: (context, state) {
          final isLoading = state is CommunityLoading;
          final isGeneratingAi = state is AiContentGenerating;
          
          return Scaffold(
            appBar: AppBar(
              title: const Text('Create New Post'),
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          controller: _titleController,
                          label: 'Title',
                          hintText: 'Enter post title',
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16.0),
                        CustomTextField(
                          controller: _contentController,
                          label: 'Content',
                          hintText: 'Enter post content',
                          maxLines: 5,
                          enabled: !isLoading,
                        ),
                        const SizedBox(height: 16.0),
                        
                        const SizedBox(height: 16.0),
                        _imageFile == null
                            ? CustomButton(
                                text: 'Pick Image',
                                onPressed: isLoading ? null : _pickImage,
                              )
                            : Column(
                                children: [
                                  Container(
                                    height: 150,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_imageFile!.path),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.error, color: Colors.red),
                                                  Text('Error loading image'),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          text: 'Change Image',
                                          onPressed: isLoading ? null : _pickImage,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: CustomButton(
                                          text: isGeneratingAi ? 'Generating...' : 'Generate with AI',
                                          onPressed: (isLoading || isGeneratingAi) ? null : _generateAiContent,
                                          backgroundColor: Colors.purple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                        const SizedBox(height: 16.0),
                        CustomButton(
                          text: isLoading ? 'Creating...' : 'Create Post',
                          onPressed: isLoading ? null : _createPost,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading || isGeneratingAi)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            isGeneratingAi ? 'Generating AI content...' : 'Creating post...',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}