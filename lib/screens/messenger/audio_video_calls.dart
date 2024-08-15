import 'dart:async';
import 'dart:convert';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart' as audio_players;
import '../../common/services/utils.dart';
import '../../common/services/data_transport.dart' as data_transport;
import '../../common/widgets/common.dart';
// void main() => runApp(const MaterialApp(home: AudioVideoCall()));

class AudioVideoCall extends StatefulWidget {
  const AudioVideoCall({
    Key? key,
    required this.connectionInfo,
    this.isIncomingCall = true,
    this.initiateCall = false,
  }) : super(key: key);
  final Map? connectionInfo;
  final bool isIncomingCall;
  final bool initiateCall;
  @override
  Initialize createState() => Initialize();
}

class Initialize extends State<AudioVideoCall> {
  String channelName = "";
  final String appId = configItem('services.agora.appId');
  late String token;
  int uid = 0; // uid of the local user
  int? _remoteUid; // uid of the remote user
  bool _isJoined = false; // Indicates if the local user has joined the channel
  bool _isLocalInitialized = false;
  bool _isAudioCallOnly = false;
  RtcEngine agoraEngine = createAgoraRtcEngine(); // Agora engine instance
  Map? callInitializeData;
  String? receiverUserUid;
  String? callerUserUid;
  String titleMessage = '';
  bool isCallClosed = false;

  final audioPlayer = audio_players.AudioPlayer();
  showMessage(String message) {
    // showToastMessage(context, message);
  }

  @override
  void initState() {
    audioPlayer.setReleaseMode(audio_players.ReleaseMode.loop);
    setState(() {
      callInitializeData = widget.connectionInfo ?? {};
      callInitializeData?['agoraAppID'] = appId;
      channelName = widget.connectionInfo?['channel'];
      token = widget.connectionInfo?['token'];
      _isJoined = false;
      _isLocalInitialized = false;
      _remoteUid = null;
      _remoteUid = widget.connectionInfo?['callerUserId'];
      receiverUserUid = widget.connectionInfo?['receiverUserUid'];
      callerUserUid = widget.connectionInfo?['callerUserUid'];
      _isAudioCallOnly =
          int.parse(widget.connectionInfo?['callType'].toString() ?? '1') == 1;

      titleMessage = widget.isIncomingCall
          ? '${widget.connectionInfo?['message']}'
          : 'Call to ${widget.connectionInfo?['userFullName']}';
    });
    // Set up an instance of Agora engine
    setupVideoSDKEngine();
    super.initState();
  }

// Clean up the resources when you leave
  @override
  void dispose() {
    if (mounted) {
      audioPlayer.stop();
      agoraEngine.leaveChannel();
      agoraEngine.release();

      /// remove all receivers from the environment
      FBroadcast.instance().unregister(this);
    }
    super.dispose();
  }

  // Initialize the call
  startCall() async {
    await join();
    await data_transport.post('messenger/join-call',
        inputData: {'callInitializeData': callInitializeData},
        onSuccess: ((responseData) {}));
  }

// Accept and Join Incoming Call
  acceptAndJoin() async {
    await join();
    await audioPlayer.stop();
    await data_transport.post('messenger/$receiverUserUid/receiver-call-accept',
        onSuccess: ((responseData) {}));
  }

  Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    if (_isAudioCallOnly) {
      await [Permission.microphone].request();
    } else {
      await [Permission.microphone, Permission.camera].request();
    }

    await agoraEngine.initialize(
      RtcEngineContext(
        appId: appId,
        logConfig: const LogConfig(
          level: LogLevel.logLevelNone,
        ),
      ),
    );

    if (_isAudioCallOnly) {
      await agoraEngine.enableAudio();
    } else {
      await agoraEngine.enableVideo();
    }

    // Register the event handler
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onLeaveChannel: (RtcConnection connection, RtcStats rtcStats) {
          // audioPlayer.stop();
          showMessage(
              "Local user uid:${connection.localUid} leaved the channel");
          leave();
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          // audioPlayer.stop();
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
          setState(() {
            _isJoined = true;
            _remoteUid = null;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          audioPlayer.stop();
          showMessage("Remote user uid:$remoteUid joined the channel");
          setState(() {
            _remoteUid = remoteUid;
            if (widget.isIncomingCall) {
              titleMessage =
                  "Call connected to ${widget.connectionInfo?['callerName']}";
            } else {
              titleMessage =
                  "Call connected to ${widget.connectionInfo?['userFullName']}";
            }
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");
          leave();
          setState(() {
            _isJoined = false;
            _remoteUid = null;
          });
        },
      ),
    );
    if (!_isAudioCallOnly) {
      // default start local preview
      await agoraEngine.startPreview();
    }

    setState(() {
      _isLocalInitialized = true;
    });

    FBroadcast.instance().register('local.broadcast.user_channel',
        (eventResponseData, callback) {
      Map receivedData = jsonDecode(eventResponseData.data);
      if (eventResponseData.eventName == 'event.call.accept.notification') {
        if ((receivedData['type'] == 'receiver-accept-call') &&
            (!_isJoined) &&
            mounted) {
          leave();
        }
      }
      // receiver-accept-call
      if ((eventResponseData.eventName == 'event.call.reject.notification')) {
        leave();
      }
    });

    if (widget.initiateCall && !widget.isIncomingCall) {
      startCall();
      audioPlayer.play(
        audio_players.AssetSource('audio/caller-ringtone.mp3'),
      );
    } else {
      audioPlayer.play(
        audio_players.AssetSource('audio/receiver-ringtone.mp3'),
      );
    }
  }

  join() async {
    // await agoraEngine.startPreview();
    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await agoraEngine.joinChannel(
      token: token,
      channelId: channelName,
      options: options,
      uid: uid,
    );
  }

  void leave() async {
    if (!_isJoined) {
      // return;
    }
    if (mounted) {
      setState(() {
        _isJoined = false;
        _remoteUid = null;
      });
    }

    try {
      // agoraEngine.getConnectionState().then((value) {
      if (!_isAudioCallOnly) {
        agoraEngine.stopPreview();
      }
      // if (value != ConnectionStateType.connectionStateDisconnected) {
      agoraEngine.leaveChannel();
      // }
      // });
      audioPlayer.stop();
      if (widget.isIncomingCall) {
        await Future.delayed(const Duration(seconds: 1));
        SmartDialog.dismiss();
      } else {
        if (mounted && !isCallClosed) {
          setState(() {
            isCallClosed = true;
          });
          Navigator.pop(context);
        }
      }
    } catch (e) {
      pr(e);
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(titleMessage),
      ),
      body: Stack(
        children: [
          const SizedBox(height: 10),
          //Container for the Remote video
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: Center(
              child: (!_isJoined || _isAudioCallOnly
                  ? AppCachedNetworkImage(
                      height: double.infinity,
                      width: double.infinity,
                      imageUrl: widget.isIncomingCall
                          ? (widget.connectionInfo?['callerProfilePicture'])
                          : widget.connectionInfo?['receiverProfileImg'],
                    )
                  : _remoteVideo()),
            ),
          ),
          const SizedBox(height: 10),
          // Container for the local video
          Positioned(
            bottom: 120,
            right: 20,
            child: SizedBox(
              height: 150,
              width: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(300.0),
                child: _localPreview(),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(150, 0, 0, 0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (widget.isIncomingCall)
                    IconButton(
                      iconSize: 48,
                      color: Colors.blue,
                      onPressed: _isJoined
                          ? null
                          : () async {
                              acceptAndJoin();
                              await audioPlayer.stop();
                            },
                      icon: const Icon(Icons.call_rounded),
                    ),
                  if (!widget.isIncomingCall)
                    IconButton(
                      iconSize: 48,
                      color: Colors.green,
                      onPressed: _isJoined ? null : () => startCall(),
                      icon: const Icon(Icons.call_rounded),
                    ),
                  if ((!widget.isIncomingCall && _isJoined) ||
                      (widget.isIncomingCall && _remoteUid != null))
                    const SizedBox(width: 20),
                  // Spacer(),
                  if ((!widget.isIncomingCall && _isJoined) ||
                      (widget.isIncomingCall && (_remoteUid != null)))
                    IconButton(
                      iconSize: 48,
                      color: Colors.red,
                      onPressed: () async {
                        if (!widget.initiateCall) {
                          leave();
                          audioPlayer.stop();
                        }
                        if (_remoteUid != null) {
                        } else {
                          await data_transport.get(
                              'messenger/$receiverUserUid/caller-reject-call');
                          await data_transport.get(
                              'messenger/$callerUserUid/receiver-reject-call');
                        }
                        if (widget.initiateCall) {
                          leave();
                          audioPlayer.stop();
                        }
                      },
                      icon: const Icon(Icons.call_end_rounded),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Display local video preview
  Widget _localPreview() {
    if (_isAudioCallOnly) {
      return Container();
    } else if (_isLocalInitialized) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(
            uid: uid,
          ),
        ),
      );
    } else {
      return const Text(
        'Join', // Join a channel
        textAlign: TextAlign.center,
      );
    }
  }

// Display remote user's video
  Widget _remoteVideo() {
    if (_isAudioCallOnly) {
      return Container();
    } else if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: agoraEngine,
          canvas: VideoCanvas(
            uid: _remoteUid,
          ),
          connection: RtcConnection(
            channelId: channelName,
          ),
        ),
      );
    } else {
      return (widget.connectionInfo?['receiverProfileImg'] != null)
          ? AppCachedNetworkImage(
              height: double.infinity,
              width: double.infinity,
              imageUrl: widget.connectionInfo?['receiverProfileImg'],
            )
          : const Text('error ...');
    }
  }
}
