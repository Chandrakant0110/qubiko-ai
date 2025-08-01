import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/instagram_post.dart';
import '../constants/api_constants.dart';
import 'exceptions/app_exceptions.dart';

/// Service interface for Instagram-related operations
/// This abstraction allows for easy testing and implementation switching
abstract class InstagramService {
  /// Fetches Instagram posts from the API
  /// Returns a list of [InstagramPost] objects
  /// Throws [NetworkException] for network-related errors
  /// Throws [DataException] for data parsing errors
  Future<List<InstagramPost>> fetchPosts();
}

/// Implementation of Instagram service using HTTP API
/// This class handles all Instagram-related API operations
class HttpInstagramService implements InstagramService {
  final http.Client _httpClient;

  /// Creates an instance with an optional HTTP client
  /// If no client is provided, a default one will be created
  HttpInstagramService({http.Client? httpClient}) 
    : _httpClient = httpClient ?? http.Client();

  @override
  Future<List<InstagramPost>> fetchPosts() async {
    try {
      // Make HTTP request with timeout
      final response = await _httpClient
          .get(
            Uri.parse(ApiConstants.instagramPostsUrl),
            headers: ApiConstants.defaultHeaders,
          )
          .timeout(ApiConstants.timeout);

      // Handle different HTTP status codes
      if (response.statusCode == 200) {
        return _parsePostsResponse(response.body);
      } else if (response.statusCode >= 500) {
        throw NetworkException.serverError(response.statusCode);
      } else {
        throw NetworkException(
          'Failed to fetch posts: ${response.statusCode}',
          code: 'HTTP_${response.statusCode}',
        );
      }
    } on NetworkException {
      // Re-throw network exceptions as-is
      rethrow;
    } on http.ClientException catch (e) {
      // Handle HTTP client exceptions
      throw NetworkException.connectionFailed();
    } catch (e, stackTrace) {
      // Handle any other unexpected errors
      if (e.toString().contains('timeout')) {
        throw NetworkException.timeout();
      }
      
      throw NetworkException(
        'Unexpected error occurred while fetching posts.',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Parses the API response and converts it to InstagramPost objects
  List<InstagramPost> _parsePostsResponse(String responseBody) {
    try {
      final jsonData = json.decode(responseBody);
      
      // Validate response structure
      if (jsonData is! Map<String, dynamic>) {
        throw DataException.invalidFormat();
      }

      final data = jsonData['data'];
      if (data == null) {
        throw DataException.notFound();
      }

      if (data is! List) {
        throw DataException.invalidFormat();
      }

      // Convert each item to InstagramPost
      final posts = <InstagramPost>[];
      for (final postJson in data) {
        if (postJson is Map<String, dynamic>) {
          try {
            final post = InstagramPost.fromJson(postJson);
            posts.add(post);
          } catch (e) {
            // Log individual post parsing errors but continue processing
            // In a production app, you might want to use a proper logging service
            print('Warning: Failed to parse post: $e');
          }
        }
      }

      return posts;
    } on FormatException catch (e) {
      throw DataException.parsingFailed(e);
    } catch (e) {
      if (e is DataException) rethrow;
      throw DataException.parsingFailed(e);
    }
  }

  /// Cleanup method to dispose of the HTTP client
  void dispose() {
    _httpClient.close();
  }
}

/// Mock implementation for testing purposes
/// This allows for reliable testing without network dependencies
class MockInstagramService implements InstagramService {
  final List<InstagramPost> _mockPosts;
  final Duration _delay;
  final Exception? _errorToThrow;

  MockInstagramService({
    List<InstagramPost>? mockPosts,
    Duration delay = const Duration(milliseconds: 500),
    Exception? errorToThrow,
  }) : _mockPosts = mockPosts ?? _generateMockPosts(),
       _delay = delay,
       _errorToThrow = errorToThrow;

  @override
  Future<List<InstagramPost>> fetchPosts() async {
    // Simulate network delay
    await Future.delayed(_delay);

    // Throw error if specified (for testing error scenarios)
    if (_errorToThrow != null) {
      throw _errorToThrow!;
    }

    return List.from(_mockPosts);
  }

  /// Generates sample mock posts for testing
  static List<InstagramPost> _generateMockPosts() {
    return [
      InstagramPost(
        id: 'mock_1',
        caption: 'Test post 1 caption',
        mediaType: 'IMAGE',
        mediaUrl: 'https://example.com/image1.jpg',
        permalink: 'https://instagram.com/p/mock1',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      InstagramPost(
        id: 'mock_2',
        caption: 'Test video post with a longer caption to test truncation',
        mediaType: 'VIDEO',
        mediaUrl: 'https://example.com/video1.mp4',
        permalink: 'https://instagram.com/p/mock2',
        thumbnailUrl: 'https://example.com/thumb2.jpg',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}