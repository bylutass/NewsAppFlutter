import 'package:flutter/material.dart';
import 'package:news_app/models/news_view_model.dart';
// ignore: library_prefixes
import 'package:news_app/models/news_channel_headlines_model.dart'
    // ignore: library_prefixes
    as headlineModel;
import 'package:news_app/views/news_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  NewsViewModel newsViewModel = NewsViewModel();
  Future<List<headlineModel.Articles>>? searchResults;

  void searchNews(String query) {
    setState(() {
      searchResults = newsViewModel.searchNews(query).then((articles) {
        return articles.where((article) {
          // "removed" içermeyen ve gerekli bilgileri eksik olmayan haberleri filtreleme
          return article.urlToImage != null &&
              article.title != null &&
              article.content != null &&
              article.source != null &&
              article.publishedAt != null &&
              !article.title!.toLowerCase().contains("removed") &&
              !article.description!.toLowerCase().contains("removed") &&
              !article.content!.toLowerCase().contains("removed");
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search news...',
            border: InputBorder.none,
          ),
          onSubmitted: (query) {
            searchNews(query);
          },
        ),
      ),
      body: FutureBuilder<List<headlineModel.Articles>>(
        future: searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No results found.'),
            );
          } else {
            var articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                var article = articles[index];
                return ListTile(
                  leading: article.urlToImage != null
                      ? Image.network(article.urlToImage!)
                      : null,
                  title: Text(article.title!),
                  subtitle: Text(article.description!),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailsScreen(
                          author: article.author.toString(),
                          newsImage: article.urlToImage.toString(),
                          newsDate: article.publishedAt.toString(),
                          newsTitle: article.title.toString(),
                          description: article.description.toString(),
                          content: article.content.toString(),
                          source: article.source!.name.toString(),
                          url: article.url.toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
