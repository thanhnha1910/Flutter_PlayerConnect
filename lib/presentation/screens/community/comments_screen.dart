import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player_connect/presentation/bloc/community/comments_bloc.dart';
import 'package:player_connect/presentation/bloc/community/comments_event.dart';
import 'package:player_connect/presentation/bloc/community/comments_state.dart';

import '../../../data/models/comment_model.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CommentsBloc>().add(FetchComments(widget.postId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Comments'),
            pinned: true,
            floating: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          BlocConsumer<CommentsBloc, CommentsState>(
            listener: (context, state) {
              if (state is CommentAdded) {
                _commentController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Comment added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is CommentAddError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add comment: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is CommentsLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is CommentsLoaded) {
                if (state.comments.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('No comments yet. Be the first to comment!'),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final comment = state.comments[index];
                      return _CommentWidget(comment: comment);
                    },
                    childCount: state.comments.length,
                  ),
                );
              } else if (state is CommentsError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, MediaQuery.of(context).viewInsets.bottom + 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            BlocBuilder<CommentsBloc, CommentsState>(
              builder: (context, state) {
                return IconButton(
                  icon: state is CommentAdding
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: state is CommentAdding
                      ? null
                      : () {
                          if (_commentController.text.isNotEmpty) {
                            context.read<CommentsBloc>().add(
                                  AddComment(
                                    postId: widget.postId,
                                    content: _commentController.text,
                                  ),
                                );
                          }
                        },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentWidget extends StatelessWidget {
  final CommentResponse comment;

  const _CommentWidget({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: comment.level * 16.0),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(comment.userName.substring(0, 1).toUpperCase()),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    comment.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(comment.content),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<CommentsBloc>().add(LikeComment(comment.id));
                    },
                    child: Row(
                      children: [
                        Icon(Icons.thumb_up, color: comment.userLikeStatus == 1 ? Colors.blue : Colors.grey),
                        const SizedBox(width: 4.0),
                        Text('Like'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  TextButton(
                    onPressed: () {
                      _showReplyDialog(context, comment.id);
                    },
                    child: const Text('Reply'),
                  ),
                ],
              ),
              if (comment.childComments.isNotEmpty)
                TextButton(
                  onPressed: () {
                    context
                        .read<CommentsBloc>()
                        .add(ToggleCommentExpansion(comment.id));
                  },
                  child: Text(comment.isExpanded ? 'Hide Replies' : 'Show Replies'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReplyDialog(BuildContext commentContext, int parentCommentId) {
    final TextEditingController replyController = TextEditingController();
    showDialog(
      context: commentContext,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reply to comment'),
          content: TextField(
            controller: replyController,
            decoration: const InputDecoration(hintText: 'Enter your reply'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (replyController.text.isNotEmpty) {
                  commentContext.read<CommentsBloc>().add(ReplyToComment(
                      parentCommentId: parentCommentId,
                      content: replyController.text));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
  }
}