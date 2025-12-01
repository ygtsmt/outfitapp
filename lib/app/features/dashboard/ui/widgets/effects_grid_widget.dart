import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/app/features/dashboard/ui/widgets/dashboard_card_widget.dart';
import 'package:ginly/core/core.dart';

import 'package:ginly/generated/l10n.dart';

class EffectsGridWidget extends StatelessWidget {
  final int crossAxisCount;
  final Set<String> selectedCategories;
  final List<String> originalCategories;

  const EffectsGridWidget({
    super.key,
    required this.crossAxisCount,
    required this.selectedCategories,
    required this.originalCategories,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state.gettingAppDocsStatus != EventStatus.idle) {
          return const Center(child: CircularProgressIndicator());
        }

        // Search query varsa filteredTemplates kullan, yoksa normal appDocs'tan template'leri topla
        List<dynamic> allTemplates = [];

        if (state.searchQuery?.isNotEmpty ?? false) {
          // Arama sonuçları varsa sadece onları göster
          allTemplates = state.filteredTemplates?.cast<dynamic>() ?? [];
        } else {
          // Normal durumda tüm template'leri topla ve filtrele
          final docsToUse = state.appDocs ?? [];
          for (final appDoc in docsToUse) {
            // Eğer hiçbir kategori seçili değilse tümünü göster, seçili varsa sadece onları göster
            if (selectedCategories.isEmpty ||
                selectedCategories.contains(appDoc.title)) {
              for (final templates in appDoc.templates.values) {
                allTemplates.addAll(templates);
              }
            }
          }
        }

        if (allTemplates.isEmpty) {
          return _buildEmptyState(context, state);
        }

        return GridView.builder(
          padding: EdgeInsets.all(4.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.h,
            childAspectRatio: 1,
          ),
          itemCount: allTemplates.length,
          itemBuilder: (context, index) {
            final template = allTemplates[index];
            return DashBoardCardWidget(
              templateId: template.id ?? 'unknown',
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
                // Template tıklandı

                context.router.push(
                  GenerateTemplateVideoScreenRoute(
                    videoTemplate: template,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.searchQuery?.isNotEmpty ?? false
                ? Icons.search_off
                : Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            state.searchQuery?.isNotEmpty ?? false
                ? 'Arama sonucu bulunamadı: "${state.searchQuery}"'
                : AppLocalizations.of(context).noEffectsFound,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          if (state.searchQuery?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AppBloc>().add(ClearSearchEvent());
              },
              child: Text(AppLocalizations.of(context).clearSearch),
            ),
          ],
        ],
      ),
    );
  }
}
