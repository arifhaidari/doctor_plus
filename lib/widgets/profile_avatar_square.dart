import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';

class ProfileAvatarSquare extends StatelessWidget {
  final String? avatarLink;
  final String gender;
  final double radius;
  const ProfileAvatarSquare({Key? key, this.avatarLink, required this.gender, this.radius = 80})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius,
      width: radius,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Palette.imageBackground,
          border: Border.all(
            width: 1.5,
            color: Palette.blueAppBar,
          )),
      child: avatarLink == null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                gender == 'Male' ? GlobalVariable.MALE_ICON : GlobalVariable.FEMALE_ICON,
                fit: BoxFit.cover,
              ),
            )
          : CachedNetworkImage(
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => circularLoading(),
              errorWidget: (context, url, error) => ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  gender == 'Male' ? GlobalVariable.MALE_ICON : GlobalVariable.FEMALE_ICON,
                  fit: BoxFit.cover,
                ),
              ),
              fit: BoxFit.cover,
              imageUrl: avatarLink ?? '',
            ),
    );
  }
}
