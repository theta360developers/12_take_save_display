import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

part 'theta_event.dart';
part 'theta_state.dart';

class ThetaBloc extends Bloc<ThetaEvent, ThetaState> {
  ThetaBloc() : super(ThetaState.initial()) {
    on<PictureEvent>((event, emit) async {
      var url = Uri.parse('http://192.168.1.1/osc/commands/execute');
      var header = {'Content-Type': 'application/json;charset=utf-8'};
      var bodyMap = {'name': 'camera.takePicture'};
      var bodyJson = jsonEncode(bodyMap);
      var response = await http.post(url, headers: header, body: bodyJson);
      var convertResponse = jsonDecode(response.body);
      var id = convertResponse['id'];

      if (convertResponse != null && id != null) {
        emit(ThetaState(message: response.body, id: id));
        while (state.cameraState != "done") {
          add(CameraStatusEvent());
          await Future.delayed(Duration(milliseconds: 200));
          print(state.cameraState);
        }
      }
      add(GetFileEvent());
    });
    on<CameraStatusEvent>((event, emit) async {
      if (state.id.isNotEmpty) {
        var url = Uri.parse('http://192.168.1.1/osc/commands/status');
        var header = {'Content-Type': 'application/json;charset=utf-8'};
        var bodyMap = {'id': state.id};
        var bodyJson = jsonEncode(bodyMap);
        var response = await http.post(url, headers: header, body: bodyJson);
        var convertResponse = jsonDecode(response.body);
        var cameraState = convertResponse['state'];

        emit(state.copyWith(cameraState: cameraState));
      }
    });
    on<GetFileEvent>((event, emit) async {
      var url = Uri.parse('http://192.168.1.1/osc/commands/execute');
      var header = {'Content-Type': 'application/json;charset=utf-8'};
      var bodyMap = {
        'name': 'camera.listFiles',
        'parameters': {
          'fileType': 'image',
          'startPosition': 0,
          'entryCount': 1,
          'maxThumbSize': 0
        }
      };
      var bodyJson = jsonEncode(bodyMap);
      var response = await http.post(url, headers: header, body: bodyJson);
      var convertResponse = jsonDecode(response.body);
      var fileUrl = convertResponse['results']['entries'][0]['fileUrl'];
      emit(state.copyWith(fileUrl: fileUrl));
      add(SaveFileEvent());
    });
    on<SaveFileEvent>((event, emit) async {
      await GallerySaver.saveImage(state.fileUrl).then((value) {
        emit(state.copyWith(finishedSaving: true));
      });
    });
    on<ImagePickerEvent>((event, emit) async {
      emit(state.copyWith(images: event.image));
    });
  }
}
