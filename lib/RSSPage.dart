import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';


class RSSPage extends StatefulWidget{
  final String titleScreen = 'RSS Feed Page';
  @override
  RSSPageState createState() => RSSPageState();
}

class RSSPageState extends State<RSSPage>{
  static const String FEED_URL = 'https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss';
  RssFeed _feed;
  String _title;

  static const String loadingFeedMsg = "Loading Feed...";
  static const String feedLoadErrorMsg = "Error Loading Feed.";
  static const String feedOpenErrorMsg = 'Error Opening Feed.';
  static const placeholderImg = 'images/no_image.png';

  GlobalKey<RefreshIndicatorState> _refreshKey;

  void updateTitle(title){
    setState(() {
      _title = title;
    });
  }

  void updateFeed(feed){
    setState(() {
      _feed = feed;
    });
  }

  Future<void> openFeed(String url) async{
    if(await canLaunch(url)){
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
      );
      return;
    }
    updateTitle(feedOpenErrorMsg);
  }

  load() async{
    updateTitle(loadingFeedMsg);
    loadFeed().then((result){
      if(null == result || result.toString().isEmpty){
        updateTitle(feedLoadErrorMsg);
        return;
      }
      updateFeed(result);
      updateTitle(_feed.title);
    });
  }

  Future<RssFeed> loadFeed() async {
    try {
      final client = http.Client();
      final response = await client.get(FEED_URL);
      return RssFeed.parse(response.body);
    } catch(e){

    }

    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    updateTitle(widget.titleScreen);
    load();
  }

  Text title(title){
    return Text(
      title,
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Text subtitle(subTitle){
    return Text(
      subTitle,
      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w100),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Padding thumbnail(imageUrl){
    return Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: CachedNetworkImage(
        placeholder: (context, url) => Image.asset(placeholderImg),
        imageUrl: imageUrl,
        height: 50,
        width: 70,
        alignment: Alignment.center,
        fit: BoxFit.fill,
      ),
    );
  }

  Icon rightIcon(){
    return Icon(
      Icons.keyboard_arrow_right,
      color: Colors.grey,
      size: 30.0,
    );
  }

  ListView list(){
    return ListView.builder(
//      itemCount: 5,
      itemCount: _feed.items.length,
      itemBuilder: (BuildContext context, int index){
        final item = _feed.items[index];
        return ListTile(
          title: title(item.title),
          subtitle: subtitle(item.pubDate),
          leading: thumbnail(item.enclosure.url),
          trailing: rightIcon(),
          contentPadding: EdgeInsets.all(5.0),
          onTap: () => openFeed(item.link),
        );
      },
    );
  }

  bool isFeedEmpty(){
    return null == _feed || null == _feed.items;
  }

  Widget body(){
    return isFeedEmpty()
        ? Center(child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
          key: _refreshKey,
          child: list(),
          onRefresh: () => load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: body(),
    );
  }
}