import 'package:assets_audio_player/assets_audio_player.dart';

class AudioManager {
  final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

  // BGM 재생 함수
  void startBGM() {
    _assetsAudioPlayer.open(
      Audio("assets/audios/title.mp3"),
      loopMode: LoopMode.single, // 반복
      autoStart: true,
      showNotification: false,
    );
    _assetsAudioPlayer.play();
  }

  // 클리어 효과음 재생 함수
  void clearBGM() {
    _assetsAudioPlayer.open(
      Audio("assets/audios/Clear.wav"),
      loopMode: LoopMode.none, // 반복 없음
      autoStart: true,
      showNotification: false,
    );
    _assetsAudioPlayer.play();
  }

  // 일시정지 함수
  void pause() {
    _assetsAudioPlayer.pause();
  }

  // 자원 해제 함수
  void dispose() {
    _assetsAudioPlayer.dispose();
  }
}
