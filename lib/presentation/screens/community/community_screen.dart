import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player_connect/data/models/post_models.dart';
import 'package:player_connect/presentation/bloc/community/community_bloc.dart';
import 'package:player_connect/presentation/bloc/community/community_event.dart';
import 'package:player_connect/presentation/bloc/community/community_state.dart';
import 'package:player_connect/presentation/widgets/post_card.dart';
import 'package:player_connect/presentation/screens/community/create_post_screen.dart';

import '../../../core/di/injection.dart';
import '../../bloc/community/comments_bloc.dart';
import 'comments_screen.dart'; // Added

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CommunityBloc>().add(FetchPosts());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is CreatePostSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully!')),
          );
          context.read<CommunityBloc>().add(FetchPosts()); // Refresh posts
        } else if (state is CreatePostFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create post: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
        ),
        body: BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, state) {
            if (state is CommunityLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CommunityLoaded) {
              return ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return PostCard(post: post);
                },
              );
            } else if (state is CommunityError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No Posts Yet'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'community_fab',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreatePostScreen()));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// Placeholder for PostCard - will be created in a separate file
class PostCard extends StatelessWidget {
  final PostResponse post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.userAvatar != null
                      ? NetworkImage(post.userAvatar!)
                      : null,
                  child: post.userAvatar == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
                const SizedBox(width: 8.0),
                Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(post.title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4.0),
            Text(post.content),
            if (post.imageUrl != null) ...[
              const SizedBox(height: 8.0),
              Image.network(post.imageUrl!),
            ],
            const SizedBox(height: 8.0),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up, color: post.userLikeStatus == 1 ? Colors.blue : Colors.grey),
                  onPressed: () {
                    context.read<CommunityBloc>().add(LikePost(post.id));
                  },
                ),
                Text('${post.likeCount} Likes'),
                const SizedBox(width: 16.0),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => getIt<CommentsBloc>(),
                          child: CommentsScreen(postId: post.id),
                        ),
                      ),
                    );
                  },
                ),
                Text('${post.commentCount} Comments'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
