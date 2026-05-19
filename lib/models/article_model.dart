class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String url;
  final String publishedAt;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}