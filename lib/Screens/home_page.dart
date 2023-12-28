import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/Screens/audio_playing.dart';
import 'package:music_player/providers/providers.dart';
import 'package:music_player/tiles/music_tile.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> allsongs = [];
  bool _hasPermission = false;
  @override
  void initState() {
    super.initState();
    LogConfig logConfig = LogConfig(logType: LogType.DEBUG);
    _audioQuery.setLogConfig(logConfig);
    checkAndRequestPermissions();
  }

  checkAndRequestPermissions({bool retry = false}) async {
    _hasPermission = await _audioQuery.checkAndRequest(
      retryRequest: retry,
    );
    _hasPermission ? setState(() {}) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Colors.deepPurple.shade900,
            Colors.deepPurple.shade400,
            Colors.deepPurple.shade300
          ])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: const Text(
              'Music Player',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ))
            ]),
        drawer: Drawer(
          backgroundColor: Colors.deepPurple.shade600,
          child: ListView(
            children: <Widget>[
              const DrawerHeader(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        // color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'You',
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {},
                child: const ListTile(
                  leading: Icon(
                    Icons.library_music,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Library',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: const ListTile(
                  leading: Icon(
                    Icons.queue_music_sharp,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Playlist',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: const ListTile(
                  leading: Icon(
                    Icons.miscellaneous_services_sharp,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Settings',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: const ListTile(
                  leading: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                  ),
                  title: Text(
                    'About',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
        body: Center(
          child: !_hasPermission
              ? noAccessToLibraryWidget()
              : FutureBuilder<List<SongModel>>(
                  future: _audioQuery.querySongs(
                      orderType: OrderType.ASC_OR_SMALLER,
                      uriType: UriType.EXTERNAL,
                      sortType: null,
                      ignoreCase: true),
                  builder: (context, item) {
                    if (item.data == null) {
                      return const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Loading...',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      );
                    }
                    if (item.data!.isEmpty) {
                      return const Center(
                        child: Text('No Songs Found!!',
                            style: TextStyle(color: Colors.white)),
                      );
                    }
                    return Stack(children: [
                      ListView.builder(
                        itemCount: item.data!.length,
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                        itemBuilder: (context, index) {
                          allsongs.addAll(item.data!);
                          return GestureDetector(
                            onTap: () {
                              context
                                  .read<SongModelProvider>()
                                  .setId(item.data![index].id);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AudioPlayingScreen(
                                          songModelList: [item.data![index]],
                                          player: _audioPlayer)));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              child: MusicTile(
                                songModel: item.data![index],
                              ),
                            ),
                          );
                        },
                      )
                    ]);
                  },
                ),
        ),
      ),
    );
  }

  Widget noAccessToLibraryWidget() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.redAccent.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Application doesn't have access to the library"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => checkAndRequestPermissions(retry: true),
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  }
}
