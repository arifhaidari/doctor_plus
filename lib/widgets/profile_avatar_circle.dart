import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../utils/utils.dart';

class ProfileAvatarCircle extends StatelessWidget {
  final String? imageUrl;
  final Color circleColor;
  final double borderWidth;
  final double onlinePosition;
  final bool isActive;
  final bool male;
  final double radius;

  const ProfileAvatarCircle({
    Key? key,
    required this.imageUrl,
    required this.radius,
    this.circleColor = Palette.blueAppBar,
    this.borderWidth = 2,
    this.onlinePosition = 5,
    this.isActive = false,
    this.male = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: radius,
          width: radius,
          decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(5),
              shape: BoxShape.circle,
              color: Palette.imageBackground,
              border: Border.all(
                width: borderWidth,
                color: circleColor,
              )),
          child: imageUrl == null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    male ? GlobalVariable.MALE_ICON : GlobalVariable.FEMALE_ICON,
                    fit: BoxFit.cover,
                  ),
                )
              : CachedNetworkImage(
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => circularLoading(),
                  errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      male ? GlobalVariable.MALE_ICON : GlobalVariable.FEMALE_ICON,
                      fit: BoxFit.cover,
                    ),
                  ),
                  fit: BoxFit.cover,
                  imageUrl: imageUrl ?? '',
                ),
        ),
        isActive
            ? Positioned(
                bottom: onlinePosition,
                right: onlinePosition,
                child: Container(
                  height: 15.0,
                  width: 15.0,
                  decoration: BoxDecoration(
                    color: Palette.online,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
