import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';

class PhotoTypeSelectionWidget extends StatelessWidget {
  final bool isDifferentPhoto;
  final ValueChanged<bool> onPhotoTypeChanged;

  const PhotoTypeSelectionWidget({
    super.key,
    required this.isDifferentPhoto,
    required this.onPhotoTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8.w,
            children: [
              Expanded(
                child: _buildPhotoTypeButton(
                  context,
                  title: AppLocalizations.of(context).separate_photos,
                  isSelected: isDifferentPhoto,
                  onTap: () => onPhotoTypeChanged(true),
                  separatePhoto: true,
                ),
              ),
              Expanded(
                child: _buildPhotoTypeButton(
                  context,
                  title: AppLocalizations.of(context).group_photo,
                  isSelected: !isDifferentPhoto,
                  onTap: () => onPhotoTypeChanged(false),
                  separatePhoto: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTypeButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool separatePhoto,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: isSelected ? 2 : 1,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          spacing: 8.h,
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.baseColor,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (separatePhoto)
                  SvgPicture.asset(
                    PngPaths.separatePhotoSelectedSvg,
                    height: 36.h,
                  ),
                if (separatePhoto)
                  Icon(
                    Icons.add,
                    color: context.baseColor,
                    size: 24.h,
                  ),
                if (separatePhoto)
                  SvgPicture.asset(
                    PngPaths.separatePhotoSelectedSvg,
                    height: 36.h,
                  ),
                if (!separatePhoto)
                  SvgPicture.asset(
                    PngPaths.singlePhotoSelectedSvg,
                    height: 36.h,
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
