import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/models/category_news_models.dart';
import 'package:news_app/models/news_channel_headlines_model.dart';

class NewsRepository {
  Future<NewsChannelsHeadlinesModel> fetchNewsChannelHeadlinesApi(
      String channelName) async {
    String url =
        // ignore: unnecessary_brace_in_string_interps
        'https://newsapi.org/v2/top-headlines?sources=${channelName}&apiKey='Your Api Key'';
    // ignore: avoid_print
    print(url);

    // ignore: unused_local_variable
    final response = await http.get(Uri.parse(url));
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return NewsChannelsHeadlinesModel.fromJson(body);
    }
    throw Exception('Error');
  }

  Future<CategoryNewsModel> fetchCategoriesNewsApi(String category) async {
    String url =
        // ignore: unnecessary_brace_in_string_interps
        'https://newsapi.org/v2/everything?q=${category}&apiKey='Your Api Key'';

    // ignore: unused_local_variable
    final response = await http.get(Uri.parse(url));
    if (kDebugMode) {
      print(response.body);
    }
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return CategoryNewsModel.fromJson(body);
    }
    throw Exception('Error');
  }

  Future<NewsChannelsHeadlinesModel> searchNews(String query) async {
    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/everything?q=$query&apiKey='Your Api Key''));

    if (response.statusCode == 200) {
      return NewsChannelsHeadlinesModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to search news');
    }
  }
}
