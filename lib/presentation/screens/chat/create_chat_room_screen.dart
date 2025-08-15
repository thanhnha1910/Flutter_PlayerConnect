import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../bloc/chat_messages/chat_rooms_bloc.dart';
import '../../bloc/chat_messages/chat_rooms_event.dart';
import '../../bloc/chat_messages/chat_rooms_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class CreateChatRoomScreen extends StatefulWidget {
  final ChatRoomsBloc? chatRoomsBloc;
  
  const CreateChatRoomScreen({Key? key, this.chatRoomsBloc}) : super(key: key);

  @override
  State<CreateChatRoomScreen> createState() => _CreateChatRoomScreenState();
}

class _CreateChatRoomScreenState extends State<CreateChatRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.chatRoomsBloc ?? getIt<ChatRoomsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Chat Room'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<ChatRoomsBloc, ChatRoomsState>(
          listener: (context, state) {
            if (state is ChatRoomsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ChatRoomCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat room created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Room Details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create a new chat room to start conversations with other players.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: _nameController,
                          label: 'Room Name',
                          hintText: 'Enter room name',
                          prefixIcon: Icons.chat_bubble_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Room name is required';
                            }
                            if (value.trim().length < 3) {
                              return 'Room name must be at least 3 characters';
                            }
                            if (value.trim().length > 50) {
                              return 'Room name must be less than 50 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _descriptionController,
                          label: 'Description (Optional)',
                          hintText: 'Enter room description',
                          prefixIcon: Icons.description_outlined,
                          maxLines: 3,
                          validator: (value) {
                            if (value != null && value.trim().length > 200) {
                              return 'Description must be less than 200 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'Create Room',
                          onPressed: state is ChatRoomsCreating ? null : _createRoom,
                          backgroundColor: Colors.blue[600]!,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: state is ChatRoomsCreating
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                LoadingOverlay(
                  isLoading: state is ChatRoomsCreating,
                  child: const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _createRoom() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      
      // Get current user ID
      final authRepository = getIt<AuthRepository>();
      final userResult = await authRepository.getCurrentUser();
      
      userResult.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi lấy thông tin người dùng: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (user) {
          if (user != null) {
            final bloc = widget.chatRoomsBloc ?? getIt<ChatRoomsBloc>();
            bloc.add(
              CreateChatRoomEvent(
                name: name,
                description: description.isEmpty ? null : description,
                creatorUserId: user.id,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng đăng nhập để tạo phòng chat'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    }
  }
}