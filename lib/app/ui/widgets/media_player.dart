/* import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MediaPlayer extends StatefulWidget {
  const MediaPlayer({super.key});

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  final List<String> _playlist = [
    'https://firebasestorage.googleapis.com/v0/b/disciplifly.appspot.com/o/Tokyo%20Drift%20-%20Six%20Days%20lyrics%20Edit.mp3?alt=media&token=87e1f81f-8f6b-4ff6-b393-377552586e0b',
    'https://firebasestorage.googleapis.com/v0/b/disciplifly.appspot.com/o/HISTED%2C%20TXVSTERPLAYA%20-%20MASHA%20ULTRAFUNK%20(PHONK).mp3?alt=media&token=3454ac55-737c-4af8-9de1-0bcb8c8df007',
    // Add more URLs to your playlist
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentIndex = 0;
  Duration _duration = const Duration();
  Duration _position = const Duration();
  double _sliderValue = 0.0;
  bool _isSliderChanging = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onAudioPositionChanged.listen((position) {
      if (!_isSliderChanging) {
        setState(() {
          _position = position;
          _sliderValue = _position.inSeconds.toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play(_playlist[_currentIndex], position: _position);
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _playNext() {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _audioPlayer.play(_playlist[_currentIndex]);
    setState(() {
      _isPlaying = true;
    });
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _playlist.length - 1;
    }
    _audioPlayer.play(_playlist[_currentIndex]);
    setState(() {
      _isPlaying = true;
    });
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
    });
  }

  void _onSliderChangeStart(double value) {
    setState(() {
      _isSliderChanging = true;
    });
  }

  void _onSliderChangeEnd(double value) {
    setState(() {
      _isSliderChanging = false;
      _audioPlayer.seek(Duration(seconds: value.toInt()));
    });
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 3,
            color: Theme.of(context).splashColor,
          )),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context).artistCredit),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 48.0,
                    onPressed: _playPrevious,
                  ),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 64.0,
                    onPressed: _playPause,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    iconSize: 48.0,
                    onPressed: _playNext,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _printDuration(_position),
                  ),
                  Expanded( 
                    child: Slider(
                      value: _sliderValue,
                      min: 0.0,
                      max: _duration.inSeconds.toDouble(),
                      onChanged: _onSliderChanged,
                      onChangeStart: _onSliderChangeStart,
                      onChangeEnd: _onSliderChangeEnd,
                    ),
                  ),
                  Text(
                    _printDuration(_duration),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 */
