import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailsScreen extends StatefulWidget {
  final String newsImage,
      newsTitle,
      newsDate,
      author,
      description,
      content,
      source,
      url;

  const NewsDetailsScreen({
    super.key,
    required this.author,
    required this.newsImage,
    required this.newsDate,
    required this.newsTitle,
    required this.description,
    required this.content,
    required this.source,
    required this.url,
  });

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  final format = DateFormat('MMM dd, yyyy HH:mm');
  late SharedPreferences prefs;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
  }

  Future<void> _loadBookmarkStatus() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isBookmarked = prefs.getBool(widget.url) ?? false;
    });
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      isBookmarked = !isBookmarked;
    });
    prefs.setBool(widget.url, isBookmarked);

    if (isBookmarked) {
      final newsData = jsonEncode({
        'author': widget.author,
        'newsImage': widget.newsImage,
        'newsDate': widget.newsDate,
        'newsTitle': widget.newsTitle,
        'description': widget.description,
        'content': widget.content,
        'source': widget.source,
        'url': widget.url,
      });
      final List<String> savedNews =
          prefs.getStringList('bookmarked_news') ?? [];
      savedNews.add(newsData);
      prefs.setStringList('bookmarked_news', savedNews);
    } else {
      final List<String> savedNews =
          prefs.getStringList('bookmarked_news') ?? [];
      savedNews.removeWhere((news) => news.contains(widget.url));
      prefs.setStringList('bookmarked_news', savedNews);
    }
  }

  Future<void> _launchURL() async {
    // ignore: deprecated_member_use
    if (await canLaunch(widget.url)) {
      // ignore: deprecated_member_use
      await launch(widget.url);
    } else {
      throw 'Could not launch ${widget.url}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    DateTime dateTime = DateTime.parse(widget.newsDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.black,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: height * .45,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(40),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.newsImage,
                fit: BoxFit.cover,
                placeholder: (context, ulr) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
          Container(
            height: height * .6,
            margin: EdgeInsets.only(top: height * .4),
            padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(40))),
            child: ListView(
              children: [
                Text(
                  widget.newsTitle,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: height * .02,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.source,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      format.format(dateTime),
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                SizedBox(
                  height: height * .03,
                ),
                Text(
                  widget.description,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _launchURL,
                  child: const Text("Read More"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
