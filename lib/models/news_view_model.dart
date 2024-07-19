import 'dart:convert';
// ignore: library_prefixes
import 'package:news_app/models/category_news_models.dart' as categoryModel;
// ignore: library_prefixes
import 'package:news_app/models/news_channel_headlines_model.dart'
    // ignore: library_prefixes
    as headlineModel;
import 'package:news_app/repository/news_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsViewModel {
  final _rep = NewsRepository();

  Future<headlineModel.NewsChannelsHeadlinesModel> fetchNewChannelHeadlinesApi(
      String channelName) async {
    final response = await _rep.fetchNewsChannelHeadlinesApi(channelName);

    final filteredArticles = response.articles?.where((article) {
      return article.title != null &&
          article.urlToImage != null &&
          !article.title!.toLowerCase().contains("removed");
    }).toList();

    return headlineModel.NewsChannelsHeadlinesModel(
      status: response.status,
      totalResults: response.totalResults,
      articles: filteredArticles,
    );
  }

  Future<categoryModel.CategoryNewsModel> fetchCategoriesNewsApi(
      String category) async {
    final response = await _rep.fetchCategoriesNewsApi(category);

    final filteredArticles = response.articles?.where((article) {
      return article.title != null &&
          article.urlToImage != null &&
          !article.title!.toLowerCase().contains("removed");
    }).toList();

    return categoryModel.CategoryNewsModel(
      status: response.status,
      totalResults: response.totalResults,
      articles: filteredArticles,
    );
  }

  Future<List<headlineModel.Articles>> searchNews(String query) async {
    final response = await _rep.searchNews(query);
    return response.articles?.where((article) {
          return article.title != null &&
              article.urlToImage != null &&
              !article.title!.toLowerCase().contains("removed");
        }).toList() ??
        [];
  }

  Future<void> saveArticle(headlineModel.Articles article) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? bookmarks = prefs.getStringList('bookmarks') ?? [];
    bookmarks.add(jsonEncode(article.toJson()));
    await prefs.setStringList('bookmarks', bookmarks);
  }

  Future<List<headlineModel.Articles>?> getSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? bookmarks = prefs.getStringList('bookmarks');
    if (bookmarks == null || bookmarks.isEmpty) {
      return null;
    }
    return bookmarks.map((bookmark) {
      return headlineModel.Articles.fromJson(jsonDecode(bookmark));
    }).toList();
  }
}
