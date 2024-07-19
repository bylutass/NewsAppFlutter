import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:news_app/models/category_news_models.dart';
import 'package:news_app/models/news_channel_headlines_model.dart';
import 'package:news_app/models/news_view_model.dart';
import 'package:news_app/views/bookmarked_news_page.dart';
import 'package:news_app/views/category_page.dart';
import 'package:news_app/views/news_detail_page.dart';
import 'package:news_app/views/search_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum NewsPlatformsList { bbcNews, reuters, cnn, theWallStreetJournal }

class _HomeScreenState extends State<HomeScreen> {
  NewsViewModel newsViewModel = NewsViewModel();
  NewsPlatformsList? selectedMenu;

  final format = DateFormat('MMMM dd, yyyy HH:mm');
  String name = 'bbc-news';
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 1;
    final height = MediaQuery.sizeOf(context).height * 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.bookmark, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BookmarkedNewsPage(),
              ),
            );
          },
        ),
        title: const Row(
          children: <Widget>[
            Text(
              'Project',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              "News",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CategoriesScreen()));
            },
            icon: Image.asset(
              'images/logo.png',
              height: 30,
              width: 30,
            ),
          ),
          PopupMenuButton<NewsPlatformsList>(
            initialValue: selectedMenu,
            icon: Image.asset(
              'images/news1.png',
              height: 30,
              width: 30,
            ),
            onSelected: (NewsPlatformsList item) {
              setState(() {
                selectedMenu = item;
                switch (item) {
                  case NewsPlatformsList.bbcNews:
                    name = 'bbc-news';
                    break;
                  case NewsPlatformsList.theWallStreetJournal:
                    name = 'the-wall-street-journal';
                    break;
                  case NewsPlatformsList.reuters:
                    name = 'reuters';
                    break;
                  case NewsPlatformsList.cnn:
                    name = 'cnn';
                    break;
                }
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<NewsPlatformsList>>[
              const PopupMenuItem(
                value: NewsPlatformsList.bbcNews,
                child: Text('BBC News'),
              ),
              const PopupMenuItem(
                value: NewsPlatformsList.theWallStreetJournal,
                child: Text('The Wall Street Journal'),
              ),
              const PopupMenuItem(
                value: NewsPlatformsList.reuters,
                child: Text('Reuters'),
              ),
              const PopupMenuItem(
                value: NewsPlatformsList.cnn,
                child: Text('CNN'),
              ),
            ],
          )
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 220,
            width: width,
            child: FutureBuilder<NewsChannelsHeadlinesModel>(
              future: newsViewModel.fetchNewChannelHeadlinesApi(name),
              builder: (BuildContext context,
                  AsyncSnapshot<NewsChannelsHeadlinesModel> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return const Center(
                    child: SpinKitCircle(
                      size: 50,
                      color: Colors.blue,
                    ),
                  );
                } else {
                  var articles = snapshot.data!.articles!
                      .where((article) =>
                          article.urlToImage != null &&
                          article.title != null &&
                          article.content != null)
                      .toList();

                  articles.sort((a, b) => DateTime.parse(a.publishedAt!)
                      .compareTo(DateTime.parse(b.publishedAt!)));
                  return ListView.builder(
                    itemCount: snapshot.data!.articles!.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      var article = snapshot.data!.articles![index];
                      if (article.urlToImage == null ||
                          article.title == null ||
                          article.content == null) {
                        return const SizedBox.shrink();
                      }
                      DateTime dateTime =
                          DateTime.parse(article.publishedAt.toString());
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NewsDetailsScreen(
                                        author: snapshot
                                            .data!.articles![index].author
                                            .toString(),
                                        newsImage: snapshot
                                            .data!.articles![index].urlToImage
                                            .toString(),
                                        newsDate: snapshot
                                            .data!.articles![index].publishedAt
                                            .toString(),
                                        newsTitle: snapshot
                                            .data!.articles![index].title
                                            .toString(),
                                        description: snapshot
                                            .data!.articles![index].description
                                            .toString(),
                                        content: snapshot
                                            .data!.articles![index].content
                                            .toString(),
                                        source: snapshot
                                            .data!.articles![index].source!.name
                                            .toString(),
                                        url: '',
                                      )));
                        },
                        child: SizedBox(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: height * 0.6,
                                width: width * .9,
                                padding: EdgeInsets.symmetric(
                                  horizontal: height * .003,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: snapshot
                                        .data!.articles![index].urlToImage
                                        .toString(),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      child: spinKit2,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                child: Card(
                                  elevation: 2,
                                  color: Colors.white.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    padding: const EdgeInsets.all(4),
                                    height: height * .08,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: width * 0.7,
                                          child: Text(
                                            snapshot
                                                .data!.articles![index].title
                                                .toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: width * 0.6,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                snapshot.data!.articles![index]
                                                    .source!.name
                                                    .toString(),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text(
                                                format.format(dateTime),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.end,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Divider(
                    color: Colors.black26,
                    thickness: 1,
                  ),
                ),
              ),
              Text(
                'All',
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Divider(
                    color: Colors.black26,
                    thickness: 1,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: FutureBuilder<CategoryNewsModel>(
              future: newsViewModel.fetchCategoriesNewsApi('General'),
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SpinKitCircle(
                      size: 50,
                      color: Colors.blue,
                    ),
                  );
                } else if (!snapshot.hasData ||
                    snapshot.data!.articles == null) {
                  return const Center(
                    child: Text('No data available'),
                  );
                } else {
                  var articles = snapshot.data!.articles!
                      .where((article) =>
                          article.urlToImage != null &&
                          article.title != null &&
                          article.content != null &&
                          article.source != null)
                      .toList();

                  articles.sort((a, b) => DateTime.parse(b.publishedAt!)
                      .compareTo(DateTime.parse(a.publishedAt!)));
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.articles!.length,
                    itemBuilder: (context, index) {
                      var article = articles[index];
                      if (article.urlToImage == null ||
                          article.title == null ||
                          article.content == null) {
                        return const SizedBox.shrink();
                      }
                      DateTime dateTime =
                          DateTime.parse(article.publishedAt.toString());

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailsScreen(
                                author: article.author ?? '',
                                newsImage: article.urlToImage ?? '',
                                newsDate: article.publishedAt ?? '',
                                newsTitle: article.title ?? '',
                                description: article.description ?? '',
                                content: article.content ?? '',
                                source: article.source!.name ?? '',
                                url: '',
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: snapshot
                                      .data!.articles![index].urlToImage
                                      .toString(),
                                  fit: BoxFit.cover,
                                  height: height * 0.12,
                                  width: width * 0.3,
                                  placeholder: (context, url) => Container(
                                    child: spinKit2,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data!.articles![index].title
                                          .toString(),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          snapshot.data!.articles![index]
                                              .source!.name
                                              .toString(),
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          format.format(dateTime),
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      article.content!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

const spinKit2 = SpinKitFadingCircle(
  color: Colors.amber,
  size: 50,
);
