import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/app/features/dashboard/ui/widgets/dashboard_custom_create_card_widget.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';

class CreateTabScreen extends StatefulWidget {
  const CreateTabScreen({super.key});

  @override
  State<CreateTabScreen> createState() => _CreateTabScreenState();
}

class _CreateTabScreenState extends State<CreateTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        spacing: 8.h,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 4.w,
                    height: 16.h,
                    color: context.baseColor,
                    margin:
                        const EdgeInsets.only(right: 8), // Yazıdan biraz boşluk
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).customCreate,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.baseColor),
                    ),
                  ),
                ],
              ),
              Divider(
                color: context.borderColor,
                thickness: 0.5,
              ),
            ],
          ),
          // AI Video Effects - En üstte, büyük (trend template preview göster)
          BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              // isTrend = true olan ilk template'i bul
              String? trendPreviewUrl;
              if (state.trendingTemplates != null &&
                  state.trendingTemplates!.isNotEmpty) {
                trendPreviewUrl = state.trendingTemplates!.first.previewUrl;
              }

              return Expanded(
                flex: 2,
                child: DashBoardCustomCreateCardWidget(
                  text: AppLocalizations.of(context).aiVideoEffects,
                  onTap: () {
                    context.router.push(AllEffectsScreenRoute());
                  },
                  assetPath: PngPaths.viralOnTiktok,
                  networkImageUrl: trendPreviewUrl, // Trend preview göster
                ),
              );
            },
          ),
          // Image ve Video - Yan yana ortada
          Expanded(
            child: DashBoardCustomCreateCardWidget(
              text: AppLocalizations.of(context).image,
              onTap: () {
                context.router.push(const TextToImageScreenRoute());
              },
              assetPath: PngPaths.textToImage,
            ),
          ),
          Expanded(
            child: DashBoardCustomCreateCardWidget(
              text: AppLocalizations.of(context).video,
              onTap: () {
                context.router.push(const VideoGenerateScreenRoute());
              },
              assetPath: PngPaths.textToVideo,
            ),
          ),
          // Realtime Images - Altta
          Expanded(
            flex: 2,
            child: DashBoardCustomCreateCardWidget(
              text: AppLocalizations.of(context).realtimeImages,
              onTap: () {
                context.router.push(const GenerateRealtimeScreenRoute());
              },
              assetPath: PngPaths.realtime,
            ),
          ),
        ],
      ),
    );
  }
}
