import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Scaffold(
        body: AudioRecorder(),
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

    );
  }
}

class AudioRecorder extends StatefulWidget {
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  bool _isRecording = false;
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  void _initializeAudio() {
    _audioRecorder = FlutterSoundRecorder();
    _audioPlayer = FlutterSoundPlayer();
    _audioPlayer!.openAudioSession();
  }

  @override
  void dispose() {
    _audioRecorder!.closeAudioSession();
    _audioPlayer!.closeAudioSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isRecording
                ? Text('Recording...')
                : ElevatedButton(
              onPressed: _startRecording,
              child: Text('Start Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: Text('Stop Recording'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playRecordedAudio,
              child: Text('Play Recorded Audio'),
            ),
          ],
        ),
      ),
    );
  }

  void _startRecording() async {
    if (await _requestPermission(Permission.microphone)) {
      String filePath = await _getFilePath();
      await _audioRecorder!.openAudioSession();
      await _audioRecorder!.startRecorder(
        toFile: filePath,
        codec: Codec.aacMP4,
      );
      setState(() => _isRecording = true);
    } else {
      print('Permission denied.');
    }
  }

  void _stopRecording() async {
    await _audioRecorder!.stopRecorder();
    setState(() => _isRecording = false);
  }

  Future<String> _getFilePath() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = appDir.path + '/recorded_audio.aac';
    return filePath;
  }

  Future<bool> _requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    return status.isGranted;
  }

  void _playRecordedAudio() async {
    String filePath = await _getFilePath();
    await _audioPlayer!.startPlayer(
      fromURI: filePath,
      codec: Codec.aacMP4,
    );
  }
}

