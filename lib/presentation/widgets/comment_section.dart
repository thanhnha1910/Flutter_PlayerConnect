import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/presentation/bloc/community/community_bloc.dart';
import 'package:player_connect/presentation/bloc/community/community_event.dart';
import 'package:player_connect/presentation/bloc/community/community_state.dart';
import 'package:player_connect/presentation/widgets/custom_button.dart';
import 'package:player_connect/presentation/widgets/custom_text_field.dart';

class CommentSection extends StatefulWidget {
  final int postId;

  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  int? _replyToCommentId;

  @override
  void initState() {
    super.initState();
    context.read<CommunityBloc>().add(FetchComments(widget.postId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _showReplyInput(int commentId) {
    setState(() {
      _replyToCommentId = commentId;
      _replyController.clear();
    });
  }

  void _hideReplyInput() {
    setState(() {
      _replyToCommentId = null;
      _replyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CommunityBloc, CommunityState>(
              builder: (context, state) {
                if (state is CommentsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CommentsLoaded) {
                  return ListView.builder(
                    itemCount: state.comments.length,
                    itemBuilder: (context, index) {
                      final comment = state.comments[index];
                      return _buildCommentItem(comment);
                    },
                  );
                } else if (state is CommentsError) {
                  return Center(child: Text(state.message));
                } else {
                  return const Center(child: Text('No comments yet.'));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Comment',
                        controller: _commentController,
                        hintText: 'Add a comment...',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (_commentController.text.isNotEmpty) {
                          context.read<CommunityBloc>().add(AddComment(
                              postId: widget.postId, content: _commentController.text));
                          _commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
                if (_replyToCommentId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Reply',
                            controller: _replyController,
                            hintText: 'Reply to comment...',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (_replyController.text.isNotEmpty) {
                              context.read<CommunityBloc>().add(ReplyComment(
                                  parentCommentId: _replyToCommentId!,
                                  postId: widget.postId,
                                  content: _replyController.text));
                              _hideReplyInput();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _hideReplyInput,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentResponse comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(comment.userAvatar ?? ''),
                ),
                const SizedBox(width: 8.0),
                Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(comment.content),
            const SizedBox(height: 8.0),
            Row(
              children: [
                IconButton(
                  icon: Icon(comment.userLikeStatus == 1 ? Icons.thumb_up : Icons.thumb_up_alt_outlined),
                  onPressed: () {
                    context.read<CommunityBloc>().add(LikeComment(commentId: comment.id, postId: widget.postId));
                  },
                ),
                const SizedBox(width: 16.0),
                TextButton(
                  onPressed: () {
                    _showReplyInput(comment.id);
                  },
                  child: const Text('Reply'),
                ),
              ],
            ),
            if (comment.childComments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  children: comment.childComments.map((child) => _buildCommentItem(child)).toList(),
                ),
              )
          ],
        ),
      ),
    );
  }
}