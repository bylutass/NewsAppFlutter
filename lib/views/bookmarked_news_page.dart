import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:news_app/views/news_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkedNewsPage extends StatefulWidget {
  // ignore: use_super_parameters
  const BookmarkedNewsPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BookmarkedNewsPageState createState() => _BookmarkedNewsPageState();
}

class _BookmarkedNewsPageState extends State<BookmarkedNewsPage> {
  late SharedPreferences prefs;
  List<Map<String, dynamic>> bookmarkedNews = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarkedNews();
  }

  Future<void> _loadBookmarkedNews() async {
    prefs = await SharedPreferences.getInstance();
    final List<String>? bookmarkedNewsStringList =
        prefs.getStringList('bookmarked_news');
    if (bookmarkedNewsStringList != null) {
      setState(() {
        bookmarkedNews = bookmarkedNewsStringList
            .map((jsonString) => jsonDecode(jsonString) as Map<String, dynamic>)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked News'),
      ),
      body: bookmarkedNews.isEmpty
          ? const Center(
              child: Text(
                'No bookmarked news yet.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: bookmarkedNews.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> news = bookmarkedNews[index];
                return ListTile(
                  title: Text(news['newsTitle'].toString()),
                  subtitle: Text(news['source'].toString()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailsScreen(
                          author: news['author'].toString(),
                          newsImage: news['newsImage'].toString(),
                          newsDate: news['newsDate'].toString(),
                          newsTitle: news['newsTitle'].toString(),
                          description: news['description'].toString(),
                          content: news['content'].toString(),
                          source: news['source'].toString(),
                          url: news['url'].toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
