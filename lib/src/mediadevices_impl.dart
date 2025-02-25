import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as jsutil;
import 'package:webrtc_interface/webrtc_interface.dart';

import 'media_stream_impl.dart';

class MediaDevicesWeb extends MediaDevices {
  @override
  Future<MediaStream> getUserMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      if (mediaConstraints['video'] is Map) {
        if (mediaConstraints['video']['facingMode'] != null) {
          mediaConstraints['video'].remove('facingMode');
        }
      }

      mediaConstraints.putIfAbsent('video', () => false);
      mediaConstraints.putIfAbsent('audio', () => false);

      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) throw Exception('MediaDevices is null');

      if (jsutil.hasProperty(mediaDevices, 'getUserMedia')) {
        var args = jsutil.jsify(mediaConstraints);
        final jsStream = await jsutil.promiseToFuture<html.MediaStream>(
            jsutil.callMethod(mediaDevices, 'getUserMedia', [args]));

        return MediaStreamWeb(jsStream, 'local');
      } else {
        final jsStream = await html.window.navigator.getUserMedia(
          audio: mediaConstraints['audio'],
          video: mediaConstraints['video'],
        );
        return MediaStreamWeb(jsStream, 'local');
      }
    } catch (e) {
      throw 'Unable to getUserMedia: ${e.toString()}';
    }
  }

  @override
  Future<MediaStream> getDisplayMedia(
      Map<String, dynamic> mediaConstraints) async {
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) throw Exception('MediaDevices is null');

      if (jsutil.hasProperty(mediaDevices, 'getDisplayMedia')) {
        final arg = jsutil.jsify(mediaConstraints);
        final jsStream = await jsutil.promiseToFuture<html.MediaStream>(
            jsutil.callMethod(mediaDevices, 'getDisplayMedia', [arg]));
        return MediaStreamWeb(jsStream, 'local');
      } else {
        final jsStream = await html.window.navigator.getUserMedia(
            video: {'mediaSource': 'screen'},
            audio: mediaConstraints['audio'] ?? false);
        return MediaStreamWeb(jsStream, 'local');
      }
    } catch (e) {
      throw 'Unable to getDisplayMedia: ${e.toString()}';
    }
  }

  @override
  Future<MediaDeviceInfo> getCurrentInputDevice() {
    return Future.value(MediaDeviceInfo(label: "Test", deviceId: "null"));
  }

  @override
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    final devices = await getSources();

    return devices.map((e) {
      var input = e as html.MediaDeviceInfo;
      return MediaDeviceInfo(
        deviceId:
            input.deviceId ?? 'Generated Device Id :(${devices.indexOf(e)})',
        groupId: input.groupId,
        kind: input.kind,
        label: input.label ?? 'Generated label :(${devices.indexOf(e)})',
      );
    }).toList();
  }

  @override
  Future<List<dynamic>> getSources() async {
    return html.window.navigator.mediaDevices?.enumerateDevices() ??
        Future.value([]);
  }

  @override
  MediaTrackSupportedConstraints getSupportedConstraints() {
    final mediaDevices = html.window.navigator.mediaDevices;
    if (mediaDevices == null) throw Exception('Mediadevices is null');

    var _mapConstraints = mediaDevices.getSupportedConstraints();

    return MediaTrackSupportedConstraints(
        aspectRatio: _mapConstraints['aspectRatio'],
        autoGainControl: _mapConstraints['autoGainControl'],
        brightness: _mapConstraints['brightness'],
        channelCount: _mapConstraints['channelCount'],
        colorTemperature: _mapConstraints['colorTemperature'],
        contrast: _mapConstraints['contrast'],
        deviceId: _mapConstraints['_mapConstraints'],
        echoCancellation: _mapConstraints['echoCancellation'],
        exposureCompensation: _mapConstraints['exposureCompensation'],
        exposureMode: _mapConstraints['exposureMode'],
        exposureTime: _mapConstraints['exposureTime'],
        facingMode: _mapConstraints['facingMode'],
        focusDistance: _mapConstraints['focusDistance'],
        focusMode: _mapConstraints['focusMode'],
        frameRate: _mapConstraints['frameRate'],
        groupId: _mapConstraints['groupId'],
        height: _mapConstraints['height'],
        iso: _mapConstraints['iso'],
        latency: _mapConstraints['latency'],
        noiseSuppression: _mapConstraints['noiseSuppression'],
        pan: _mapConstraints['pan'],
        pointsOfInterest: _mapConstraints['pointsOfInterest'],
        resizeMode: _mapConstraints['resizeMode'],
        saturation: _mapConstraints['saturation'],
        sampleRate: _mapConstraints['sampleRate'],
        sampleSize: _mapConstraints['sampleSize'],
        sharpness: _mapConstraints['sharpness'],
        tilt: _mapConstraints['tilt'],
        torch: _mapConstraints['torch'],
        whiteBalanceMode: _mapConstraints['whiteBalanceMode'],
        width: _mapConstraints['width'],
        zoom: _mapConstraints['zoom']);
  }

  @override
  Future<MediaDeviceInfo> selectAudioOutput(
      [AudioOutputOptions? options]) async {
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) throw Exception('MediaDevices is null');

      if (jsutil.hasProperty(mediaDevices, 'selectAudioOutput')) {
        if (options != null) {
          final arg = jsutil.jsify(options);
          final deviceInfo = await jsutil.promiseToFuture<html.MediaDeviceInfo>(
              jsutil.callMethod(mediaDevices, 'selectAudioOutput', [arg]));
          return MediaDeviceInfo(
            kind: deviceInfo.kind,
            label: deviceInfo.label ?? '',
            deviceId: deviceInfo.deviceId ?? '',
            groupId: deviceInfo.groupId,
          );
        } else {
          final deviceInfo = await jsutil.promiseToFuture<html.MediaDeviceInfo>(
              jsutil.callMethod(mediaDevices, 'selectAudioOutput', []));
          return MediaDeviceInfo(
            kind: deviceInfo.kind,
            label: deviceInfo.label ?? '',
            deviceId: deviceInfo.deviceId ?? '',
            groupId: deviceInfo.groupId,
          );
        }
      } else {
        throw UnimplementedError('selectAudioOutput is missing');
      }
    } catch (e) {
      throw 'Unable to selectAudioOutput: ${e.toString()}, Please try to use MediaElement.setSinkId instead.';
    }
  }

  @override
  set ondevicechange(Function(dynamic event)? listener) {
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) throw Exception('MediaDevices is null');

      jsutil.setProperty(mediaDevices, 'ondevicechange',
          js.allowInterop((evt) => listener?.call(evt)));
    } catch (e) {
      throw 'Unable to set ondevicechange: ${e.toString()}';
    }
  }

  @override
  Function(dynamic event)? get ondevicechange {
    try {
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) throw Exception('MediaDevices is null');

      jsutil.getProperty(mediaDevices, 'ondevicechange');
    } catch (e) {
      throw 'Unable to get ondevicechange: ${e.toString()}';
    }
    return null;
  }
}
