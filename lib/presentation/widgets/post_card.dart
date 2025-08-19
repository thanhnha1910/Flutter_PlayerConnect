import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player_connect/data/models/post_models.dart';
import 'package:player_connect/presentation/bloc/community/community_bloc.dart';
import 'package:player_connect/presentation/bloc/community/community_event.dart';
import 'package:player_connect/presentation/widgets/comment_section.dart';

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
            Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                TextButton.icon(
                  icon: Icon(post.userLikeStatus == 1 ? Icons.thumb_up : Icons.thumb_up_alt_outlined, color: post.userLikeStatus == 1 ? Colors.blue : Colors.grey),
                  label: Text('${post.likeCount} Likes'),
                  onPressed: () {
                    context.read<CommunityBloc>().add(LikePost(post.id));
                  },
                ),
                const SizedBox(width: 16.0),
                TextButton.icon(
                  icon: const Icon(Icons.comment),
                  label: Text('${post.commentCount} Comments'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CommentSection(postId: post.id)));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
