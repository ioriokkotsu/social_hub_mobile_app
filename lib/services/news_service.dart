import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/article_model.dart';

class NewsService {
  final String apiKey = '2b2301d2f9ed4340a671e69888930172';

  Future<List<Article>> fetchNews() async {
    final url = Uri.parse(
      'https://newsapi.org/v2/everything?'
      'q=charity OR donation OR volunteering OR ngo OR fundraising'
      '&language=en'
      '&sortBy=publishedAt'
      '&pageSize=20'
      '&apiKey=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List articles = data['articles'];

      return articles.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
