import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tencent_conference_uikit/common/index.dart';
import 'package:rtc_room_engine/api/common/tui_video_view.dart';

import '../../index.dart';
import 'widgets/widgets.dart';

class VideoItemWidget extends StatefulWidget {
  final UserModel userModel;
  final double? width;
  final double? height;
  final bool isScreenStream;
  final double radius;

  const VideoItemWidget({
    Key? key,
    required this.userModel,
    this.width,
    this.height,
    this.isScreenStream = false,
    this.radius = 16,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItemWidget> {
  int _nativeViewPtr = 0;

  final controller = Get.find<VideoLayoutController>();

  @override
  void didUpdateWidget(covariant VideoItemWidget oldWidget) {
    if (widget.isScreenStream != oldWidget.isScreenStream ||
        widget.userModel.userId.value != oldWidget.userModel.userId.value) {
      controller.updateVideoItem(oldWidget.userModel.userId.value,
          _nativeViewPtr, widget.userModel.userId.value, widget.isScreenStream);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: widget.width,
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              VideoView(
                onViewCreated: (id) {
                  _nativeViewPtr = id;
                  controller.setVideoView(
                      widget.userModel.userId.value, _nativeViewPtr,
                      isScreenStream: widget.isScreenStream);
                },
                borderRadius: widget.radius.toInt(),
              ),
              Obx(
                () {
                  controller.updateVideoPlayState(
                      widget.userModel.userId.value,
                      widget.isScreenStream
                          ? widget.userModel.hasScreenStream.value
                          : widget.userModel.hasVideoStream.value,
                      isScreenStream: widget.isScreenStream);
                  return Visibility(
                    visible: !widget.userModel.hasVideoStream.value &&
                        !widget.isScreenStream,
                    child: Image.asset(
                      AssetsImages.roomVideoBgNoContent,
                      fit: BoxFit.fill,
                      package: 'tencent_conference_uikit',
                    ),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Obx(
                    () => Visibility(
                      visible: !widget.isScreenStream &&
                          !widget.userModel.hasVideoStream.value,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipOval(
                          child: Image.network(
                            widget.userModel.userAvatarURL.value,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                AssetsImages.roomDefaultAvatar,
                                package: 'tencent_conference_uikit',
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible: widget.userModel.isTalking.value &&
                      RoomStore.to.audioSetting.volumePrompt,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: RoomColors.fluorescentGreen, width: 3),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                left: 7,
                child: VideoUserInfoWidget(
                  userModel: widget.userModel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
