import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/instagram_post.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_colors.dart';

/// Widget for displaying Instagram posts in a selectable grid
/// This is a reusable component that handles post selection UI
class PostSelectionGrid extends ConsumerWidget {
  final List<InstagramPost> posts;
  final String? selectedPostId;
  final ValueChanged<String?> onPostSelected;
  final bool enabled;

  const PostSelectionGrid({
    super.key,
    required this.posts,
    this.selectedPostId,
    required this.onPostSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (posts.isEmpty) {
      return const PostSelectionEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingLarge),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: UIConstants.postsGridCrossAxisCount,
        crossAxisSpacing: UIConstants.postsGridSpacing,
        mainAxisSpacing: UIConstants.postsGridSpacing,
        childAspectRatio: UIConstants.postsGridAspectRatio,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final isSelected = selectedPostId == post.id;
        
        return PostGridItem(
          post: post,
          isSelected: isSelected,
          enabled: enabled,
          onTap: () => onPostSelected(isSelected ? null : post.id),
        );
      },
    );
  }
}

/// Individual post item in the grid
class PostGridItem extends StatelessWidget {
  final InstagramPost post;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const PostGridItem({
    super.key,
    required this.post,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: UIConstants.animationFast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLightBlue
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: PostThumbnail(
                post: post,
                isSelected: isSelected,
              ),
            ),
            Expanded(
              flex: 2,
              child: PostInfo(post: post),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnail section of the post item
class PostThumbnail extends StatelessWidget {
  final InstagramPost post;
  final bool isSelected;

  const PostThumbnail({
    super.key,
    required this.post,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(UIConstants.borderRadiusMedium),
          topRight: Radius.circular(UIConstants.borderRadiusMedium),
        ),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(UIConstants.borderRadiusMedium),
          topRight: Radius.circular(UIConstants.borderRadiusMedium),
        ),
        child: Stack(
          children: [
            // Main image
            Image.network(
              post.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const PostThumbnailError();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const PostThumbnailLoading();
              },
            ),
            
            // Video indicator
            if (post.isVideo)
              const Positioned(
                top: UIConstants.paddingSmall,
                right: UIConstants.paddingSmall,
                child: PostVideoIndicator(),
              ),
            
            // Selection indicator
            if (isSelected)
              const Positioned(
                top: UIConstants.paddingSmall,
                left: UIConstants.paddingSmall,
                child: PostSelectionIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Video indicator overlay
class PostVideoIndicator extends StatelessWidget {
  const PostVideoIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: UIConstants.iconSizeSmall,
      ),
    );
  }
}

/// Selection indicator overlay
class PostSelectionIndicator extends StatelessWidget {
  const PostSelectionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.primaryLightBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: UIConstants.iconSizeSmall,
      ),
    );
  }
}

/// Post information section
class PostInfo extends StatelessWidget {
  final InstagramPost post;

  const PostInfo({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              post.getTruncatedCaption(UIConstants.maxCaptionLength),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          Text(
            post.formattedTimeAgo,
            style: GoogleFonts.urbanist(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading state for post thumbnails
class PostThumbnailLoading extends StatelessWidget {
  const PostThumbnailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }
}

/// Error state for post thumbnails
class PostThumbnailError extends StatelessWidget {
  const PostThumbnailError({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: UIConstants.iconSizeMedium,
      ),
    );
  }
}

/// Empty state when no posts are available
class PostSelectionEmptyState extends StatelessWidget {
  const PostSelectionEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          Text(
            'No posts available',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          Text(
            'No Instagram posts were found to automate',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}