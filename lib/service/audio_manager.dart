import 'package:assets_audio_player/assets_audio_player.dart';

class AudioManager {
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

  void startBGM() {
    _assetsAudioPlayer.open(
      Audio("assets/audios/title.mp3"),
      loopMode: LoopMode.single,
      // autoStart: true,
      showNotification: false,
    );
    _assetsAudioPlayer.play();
  }

  void clearBGM() {
    _assetsAudioPlayer.open(
      Audio("assets/audios/Clear.wav"),
      loopMode: LoopMode.single,
      // autoStart: true,
      showNotification: false,
    );
    _assetsAudioPlayer.play();
  }

  void pause() {
    _assetsAudioPlayer.pause();
  }

  void dispose() {
    _assetsAudioPlayer.dispose();
  }
}
