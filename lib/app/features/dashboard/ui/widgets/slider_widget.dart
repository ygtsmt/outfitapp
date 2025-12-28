// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/app/data/models/features_doc_model.dart';
import 'package:ginfit/app/ui/widgets/custom_gradient_button.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SliderWidget extends StatelessWidget {
  final VideoTemplate videoTemplate;
  final bool isForPayments;
  const SliderWidget(
      {super.key, required this.videoTemplate, required this.isForPayments});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.router.push(
            GenerateTemplateVideoScreenRoute(videoTemplate: videoTemplate));
        // buraya tıklandığında yapılacak işlemi yaz
      },
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          ClipRRect(
            borderRadius:
                isForPayments ? BorderRadius.zero : BorderRadius.circular(6.r),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: videoTemplate.previewUrl ?? '',
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: Theme.of(context).colorScheme.primary,
                      size: 12.h,
                    ),
                  ),
                  errorWidget: (contexxt, url, error) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
                // Gölge efekti
                if (isForPayments == false)
                  Positioned(
                    bottom: 16.h,
                    left: 16.w,
                    child: BlocBuilder<AppBloc, AppState>(
                      builder: (context, state) {
                        return Text(
                          resolveByLocale(
                            state.languageLocale,
                            videoTemplate.title ?? '',
                            tr: videoTemplate.titleTr,
                            de: videoTemplate.titleDe,
                            fr: videoTemplate.titleFr,
                            ar: videoTemplate.titleAr,
                            ru: videoTemplate.titleRu,
                            zh: videoTemplate.titleZh,
                            es: videoTemplate.titleEs,
                            hi: videoTemplate.titleHi,
                            pt: videoTemplate.titlePt,
                            id: videoTemplate.titleId,
                          ),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                if (isForPayments == false)
                  Positioned(
                      bottom: 0.h,
                      right: 16.w,
                      child: CustomGradientButton(
                        title: AppLocalizations.of(context).tryNow,
                        isFilled: true,
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
