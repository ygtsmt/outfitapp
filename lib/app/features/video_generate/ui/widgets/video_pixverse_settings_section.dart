import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginly/app/features/video_generate/ui/widgets/video_pixverse_resolution_section.dart';
import 'package:ginly/app/features/video_generate/ui/widgets/video_pixverse_length_section.dart';
import 'package:ginly/app/features/video_generate/ui/widgets/video_aspect_ratio_section.dart';
import 'package:ginly/generated/l10n.dart';
import 'package:ginly/core/utils.dart';

class VideoPixverseSettingsSection extends StatelessWidget {
  final VideoGenerateState state;
  final Function(String) onResolutionSelected;
  final Function(String) onLengthSelected;
  final Function(String) onAspectRatioSelected;
  final Function(String) onStyleSelected;
  final Function(String) onModeSelected;
  final Function(String) onNegativePromptChanged;

  const VideoPixverseSettingsSection({
    super.key,
    required this.state,
    required this.onResolutionSelected,
    required this.onLengthSelected,
    required this.onAspectRatioSelected,
    required this.onStyleSelected,
    required this.onModeSelected,
    required this.onNegativePromptChanged,
  });

  // Fast mode uyumsuzluğu kontrolü
  bool _isFastModeDisabled() {
    // 1080p veya 8s seçiliyse fast mode'u disable yap
    return state.requestModel?.resolution == '1080p' ||
        state.requestModel?.length == 8;
  }

  // Fast mode uyumsuzluk mesajını göster
  void _showFastModeIncompatibilityMessage(BuildContext context) {
    Utils.showToastMessage(
      context: context,
      content: AppLocalizations.of(context).fast_mode_incompatible,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = state.requestModel?.image != null;
    final isImageToVideo = hasImage;

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final customModels = appState.customAIModels;
        final currentModel = isImageToVideo
            ? customModels.imageToVideo.toLowerCase()
            : customModels.textToVideo.toLowerCase();
        final isHailuo = currentModel == 'hailuo';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Mode badge and AI Model badge
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHailuo
                            ? 'Hailuo Settings'
                            : AppLocalizations.of(context).pixverse_settings,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: isImageToVideo
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              isImageToVideo
                                  ? AppLocalizations.of(context).image_to_video
                                  : AppLocalizations.of(context).text_to_video,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: isImageToVideo
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer
                                        : Theme.of(context)
                                            .colorScheme
                                            .onTertiaryContainer,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: isHailuo
                                  ? Colors.purple.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              isHailuo ? '🚀 Hailuo AI' : '⚡ Pixverse AI',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color:
                                        isHailuo ? Colors.purple : Colors.blue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // PIXVERSE AYARLARI
            if (!isHailuo) ...[
              // Mode Selection
              _buildModeSelection(context),
              SizedBox(height: 20.h),

              // Resolution Section
              VideoPixverseResolutionSection(
                state: state,
                onResolutionSelected: onResolutionSelected,
              ),
              SizedBox(height: 20.h),

              // Length Section
              VideoPixverseLengthSection(
                state: state,
                onLengthSelected: onLengthSelected,
              ),
              SizedBox(height: 20.h),

              // Aspect Ratio Section - Sadece text to video için göster
              if (!isImageToVideo) ...[
                VideoAspectRatioSection(
                  state: state,
                  onAspectRatioSelected: onAspectRatioSelected,
                ),
                SizedBox(height: 20.h),
              ],

              // Negative Prompt Section - Sadece image to video için göster
              if (isImageToVideo) ...[
                _buildNegativePromptSection(context),
                SizedBox(height: 20.h),
              ],

              // Style Selection
              _buildStyleSelection(context),
            ],

            // HAILUO AYARLARI
            if (isHailuo) ...[
              // Resolution Section - Sadece IMAGE-TO-VIDEO için
              if (isImageToVideo) ...[
                _buildHailuoResolutionSection(context),
                SizedBox(height: 20.h),
              ],

              // Duration Section (Hailuo: 6s, 10s)
              _buildHailuoDurationSection(context),
            ],
          ],
        );
      },
    );
  }

  Widget _buildModeSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).mode,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildModeCard(
                context,
                mode: 'normal',
                title: AppLocalizations.of(context).normal_mode,
                description:
                    AppLocalizations.of(context).normal_mode_description,
                isSelected: state.requestModel?.mode == 'normal',
                onTap: () => onModeSelected('normal'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildModeCard(
                context,
                mode: 'fast',
                title: AppLocalizations.of(context).fast_mode,
                description: AppLocalizations.of(context).fast_mode_description,
                isSelected: state.requestModel?.mode == 'fast',
                onTap: _isFastModeDisabled()
                    ? () => _showFastModeIncompatibilityMessage(context)
                    : () => onModeSelected('fast'),
                isDisabled: _isFastModeDisabled(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String mode,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDisabled
              ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
              : isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isDisabled
                ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
                : isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  mode == 'normal' ? Icons.speed : Icons.flash_on,
                  size: 16.w,
                  color: isDisabled
                      ? Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.4)
                      : isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.4)
                              : isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDisabled
                        ? Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.4)
                        : isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                    fontSize: 10.sp,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).style,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildStyleCard(
              context,
              style: 'auto',
              title: AppLocalizations.of(context).auto_style,
              description: AppLocalizations.of(context).auto_style_description,
              isSelected: state.requestModel?.style == 'auto',
              onTap: () => onStyleSelected('auto'),
            ),
            _buildStyleCard(
              context,
              style: 'anime',
              title: AppLocalizations.of(context).anime_style,
              description: AppLocalizations.of(context).anime_style_description,
              isSelected: state.requestModel?.style == 'anime',
              onTap: () => onStyleSelected('anime'),
            ),
            _buildStyleCard(
              context,
              style: '3d_animation',
              title: AppLocalizations.of(context).threeDAnimationStyle,
              description:
                  AppLocalizations.of(context).threeDAnimationStyleDescription,
              isSelected: state.requestModel?.style == '3d_animation',
              onTap: () => onStyleSelected('3d_animation'),
            ),
            _buildStyleCard(
              context,
              style: 'clay',
              title: AppLocalizations.of(context).clay_style,
              description: AppLocalizations.of(context).clay_style_description,
              isSelected: state.requestModel?.style == 'clay',
              onTap: () => onStyleSelected('clay'),
            ),
            _buildStyleCard(
              context,
              style: 'comic',
              title: AppLocalizations.of(context).comic_style,
              description: AppLocalizations.of(context).comic_style_description,
              isSelected: state.requestModel?.style == 'comic',
              onTap: () => onStyleSelected('comic'),
            ),
            _buildStyleCard(
              context,
              style: 'cyberpunk',
              title: AppLocalizations.of(context).cyberpunk_style,
              description:
                  AppLocalizations.of(context).cyberpunk_style_description,
              isSelected: state.requestModel?.style == 'cyberpunk',
              onTap: () => onStyleSelected('cyberpunk'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStyleCard(
    BuildContext context, {
    required String style,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  style == 'auto' ? Icons.auto_awesome : Icons.flash_on,
                  size: 16.w,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNegativePromptSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).negativePrompt,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 12.h),
        TextField(
          onChanged: onNegativePromptChanged,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).negativePromptHint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
        ),
      ],
    );
  }

  // Hailuo Resolution Section
  Widget _buildHailuoResolutionSection(BuildContext context) {
    final currentResolution = state.requestModel?.resolution ?? '768p';
    final hailuoResolutions = ['512p', '768p'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resolution',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: hailuoResolutions.map((resolution) {
            final isSelected = currentResolution == resolution;
            return GestureDetector(
              onTap: () => onResolutionSelected(resolution),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  resolution.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Hailuo Duration Section
  Widget _buildHailuoDurationSection(BuildContext context) {
    final currentLength = state.requestModel?.length ?? 6;
    final hailuoDurations = [6, 10];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: hailuoDurations.map((duration) {
            final isSelected = currentLength == duration;
            return GestureDetector(
              onTap: () => onLengthSelected(duration.toString()),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16.w,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${duration}s',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
/* Pixverse V4.5, normal, 5s, 360p, text to video
Pixverse V4.5, normal, 5s, 540p, text to video
Pixverse V4.5, normal, 5s, 720p, text to video
Pixverse V4.5, normal, 5s, 1080p, text to vide
Pixverse V4.5, fast, 5s, 360p, text to video	
Pixverse V4.5, fast, 5s, 540p, text to video	
Pixverse V4.5, fast, 5s, 720p, text to video	
Pixverse V4.5, normal, 8s, 360p, text to video
Pixverse V4.5, normal, 8s, 540p, text to video
Pixverse V4.5, normal, 8s, 720p, text to video
Pixverse V4.5, normal, 5s, 360p, image to vide
Pixverse V4.5, normal, 5s, 540p, image to vide
Pixverse V4.5, normal, 5s, 720p, image to vide
Pixverse V4.5, normal, 5s, 1080p, image tovide
Pixverse V4.5, fast, 5s, 360p, image to video	
Pixverse V4.5, fast, 5s, 540p, image to video	
Pixverse V4.5, fast, 5s, 720p, image to video	
Pixverse V4.5, normal, 8s, 360p, image to vide
Pixverse V4.5, normal, 8s, 540p, image to vide
Pixverse V4.5, normal, 8s, 720p, image to vide */
