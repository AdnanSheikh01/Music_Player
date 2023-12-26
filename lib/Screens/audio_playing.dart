import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:music_player/providers/providers.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class AudioPlayingScreen extends StatefulWidget {
  const AudioPlayingScreen(
      {super.key, required this.songModelList, required this.player});
  final List<SongModel> songModelList;
  final AudioPlayer player;
  @override
  State<AudioPlayingScreen> createState() => _AudioPlayingScreenState();
}

class _AudioPlayingScreenState extends State<AudioPlayingScreen> {
  bool _isclicked = false;
  Duration _duration = const Duration();
  Duration _position = const Duration();
  List<AudioSource> songList = [];

  int currentindex = 0;
  void popBack() {
    Navigator.pop(context);
  }

  void seekToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.player.seek(duration);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playSong();
  }

  void playSong() {
    try {
      for (var element in widget.songModelList) {
        songList.add(
          AudioSource.uri(
            Uri.parse(element.uri!),
            tag: MediaItem(
              id: element.id.toString(),
              album: element.album ?? "No Album",
              title: element.displayNameWOExt,
              artUri: Uri.parse(element.id.toString()),
            ),
          ),
        );
      }
      widget.player.setAudioSource(
        ConcatenatingAudioSource(children: songList),
      );
      widget.player.play();
      _isclicked = true;

      widget.player.durationStream.listen((duration) {
        if (duration != null) {
          setState(() {
            _duration = duration;
          });
        }
      });
      widget.player.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });
      listenToEvent();
      listenToSongIndex();
    } on Exception catch (_) {
      popBack();
    }
  }

  void listenToEvent() {
    widget.player.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          _isclicked = true;
        });
      } else {
        setState(() {
          _isclicked = false;
        });
      }
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isclicked = false;
        });
      }
    });
  }

  void listenToSongIndex() {
    widget.player.currentIndexStream.listen(
      (event) {
        setState(
          () {
            if (event != null) {
              currentindex = event;
            }
            context
                .read<SongModelProvider>()
                .setId(widget.songModelList[currentindex].id);
          },
        );
      },
    );
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
            Colors.deepPurple.shade200,
          ])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'Now Playing',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
            child: Center(
          child: Column(children: [
            const CircleAvatar(
              radius: 120,
              child: Icon(
                Icons.music_note,
                size: 100,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              widget.songModelList[currentindex].displayNameWOExt,
              style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.fade,
                  color: Colors.white),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            Text(
              widget.songModelList[currentindex].artist.toString() ==
                      '<unknown>'
                  ? 'Unknown Artist'
                  : widget.songModelList[currentindex].artist.toString(),
              style: const TextStyle(
                  fontSize: 17,
                  overflow: TextOverflow.fade,
                  color: Colors.white),
              maxLines: 1,
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Text(
                  _position.toString().split('.')[0],
                  style: const TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: Slider(
                      min: 0.0,
                      value: _position.inSeconds.toDouble(),
                      max: _duration.inSeconds.toDouble(),
                      onChanged: (value) async {
                        setState(() {
                          seekToSeconds(value.toInt());
                          value = value;
                        });
                      }),
                ),
                Text(_duration.toString().split('.')[0],
                    style: const TextStyle(color: Colors.white)),
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      if (widget.player.hasPrevious) {
                        widget.player.seekToPrevious();
                      }
                    },
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: 50,
                    )),
                IconButton(
                    onPressed: () {
                      setState(() {
                        if (_isclicked) {
                          widget.player.pause();
                        } else {
                          if (_position >= _duration) {
                            seekToSeconds(0);
                          } else {
                            widget.player.play();
                          }
                        }
                        _isclicked = !_isclicked;
                      });
                    },
                    icon: Icon(
                      _isclicked ? Icons.pause : Icons.play_arrow,
                      size: 80,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () {
                      if (widget.player.hasNext) {
                        widget.player.seekToNext();
                      }
                    },
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 50,
                    ))
              ],
            )
          ]),
        )),
      ),
    );
  }
}

class ArtWorkWidget extends StatelessWidget {
  const ArtWorkWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongModelProvider>().id,
      type: ArtworkType.AUDIO,
      artworkHeight: 200,
      artworkWidth: 200,
      artworkFit: BoxFit.cover,
      nullArtworkWidget: const Icon(
        Icons.music_note,
        size: 200,
      ),
    );
  }
}
