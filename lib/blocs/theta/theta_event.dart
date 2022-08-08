part of 'theta_bloc.dart';

abstract class ThetaEvent extends Equatable {
  const ThetaEvent();

  @override
  List<Object> get props => [];
}

class PictureEvent extends ThetaEvent {}

class CameraStatusEvent extends ThetaEvent {}

class GetFileEvent extends ThetaEvent {}

class SaveFileEvent extends ThetaEvent {}

class ImagePickerEvent extends ThetaEvent {
  final XFile image;

  const ImagePickerEvent(this.image);
}
