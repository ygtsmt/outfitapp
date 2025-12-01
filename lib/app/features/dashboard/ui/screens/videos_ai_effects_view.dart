import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/app/features/dashboard/ui/widgets/dashboard_card_widget.dart';
import 'package:ginly/core/constants/layout_constants.dart';
import 'package:ginly/core/core.dart';

import 'package:ginly/generated/l10n.dart';

class VideosAiEffectsView extends StatelessWidget {
  const VideosAiEffectsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return state.gettingAppDocsStatus != EventStatus.idle
            ? Center(
                child: Column(
                  children: [
                    LayoutConstants.ultraEmptyHeight,
                    LayoutConstants.ultraEmptyHeight,
                    LayoutConstants.highEmptyHeight,
                    const CircularProgressIndicator(),
                  ],
                ),
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: state.appDocs?.length ?? 0,
                itemBuilder: (context, appdocsIndex) {
                  final appDoc = state.appDocs?[appdocsIndex];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4.w,
                            height: 16.h,
                            color: context.baseColor,
                            margin: const EdgeInsets.only(right: 8),
                          ),
                          Expanded(
                            child: Text(
                              resolveByLocale(
                                state.languageLocale,
                                appDoc?.title ?? '',
                                tr: appDoc?.title_tr,
                                de: appDoc?.title_de,
                                fr: appDoc?.title_fr,
                                ar: appDoc?.title_ar,
                                ru: appDoc?.title_ru,
                                zh: appDoc?.title_zh,
                                es: appDoc?.title_es,
                                hi: appDoc?.title_hi,
                                pt: appDoc?.title_pt,
                                id: appDoc?.title_id,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Poppins',
                                      fontSize: 11.sp),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.router.push(AllEffectsScreenRoute());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).showMore,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: context.baseColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.sp,
                                        ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 11.sp,
                                    color: context.baseColor.withOpacity(0.7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      LayoutConstants.tinyEmptyHeight,
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appDoc?.templates.length ?? 0,
                          itemBuilder: (context, index) {
                            final templateKeys =
                                appDoc?.templates.keys.toList() ?? [];
                            if (templateKeys.isEmpty) return const SizedBox();

                            final key = templateKeys[index];
                            final templateList = appDoc?.templates[key] ?? [];

                            // Template'leri 3'erli satırlara böl
                            final rows = <Widget>[];
                            for (int i = 0; i < templateList.length; i += 3) {
                              final rowTemplates =
                                  templateList.skip(i).take(3).toList();

                              rows.add(
                                Row(
                                  children: [
                                    for (final template in rowTemplates)
                                      Expanded(
                                        child: DashBoardCardWidget(
                                          ticket: template.ticket ?? '',
                                          templateId: template.id ?? '',
                                          text: resolveByLocale(
                                            state.languageLocale,
                                            template.title ?? '',
                                            tr: template.titleTr,
                                            de: template.titleDe,
                                            fr: template.titleFr,
                                            ar: template.titleAr,
                                            ru: template.titleRu,
                                            zh: template.titleZh,
                                            es: template.titleEs,
                                            hi: template.titleHi,
                                            pt: template.titlePt,
                                            id: template.titleId,
                                          ),
                                          previewUrl: template.previewUrl ?? '',
                                          onTap: () {

                                            context.router.push(
                                                GenerateTemplateVideoScreenRoute(
                                                    videoTemplate: template));
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: rows,
                            );
                          },
                        ),
                      )
                    ],
                  );
                },
              );
      },
    );
  }
}
