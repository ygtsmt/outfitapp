import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/bloc/app_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:comby/generated/l10n.dart';

class DashBoardCardWidget extends StatefulWidget {
  final String text;
  final String previewUrl;
  final String templateId;
  final void Function()? onTap;
  final String? ticket;

  const DashBoardCardWidget({
    Key? key,
    required this.text,
    required this.previewUrl,
    required this.templateId,
    required this.onTap,
    this.ticket,
  }) : super(key: key);

  @override
  State<DashBoardCardWidget> createState() => _DashBoardCardWidgetState();
}

class _DashBoardCardWidgetState extends State<DashBoardCardWidget> {
  static bool _hasLoggedFirstPreview =
      false; // Static - tüm widget'lar için ortak
  static DateTime? _firstLoadStartTime;
  DateTime? _loadStartTime;
  bool _hasLogged = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.h),
      child: InkWell(
        onTap: widget.onTap,
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.previewUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) {
                            // İLK preview için başlangıç zamanını kaydet
                            if (!_hasLoggedFirstPreview) {
                              _firstLoadStartTime ??= DateTime.now();
                            }

                            return Center(
                              child: LoadingAnimationWidget.fourRotatingDots(
                                color: Theme.of(context).colorScheme.primary,
                                size: 12.h,
                              ),
                            );
                          },
                          errorWidget: (contexxt, url, error) {
                            // Sadece ilk preview hatası için log
                            if (!_hasLoggedFirstPreview && !_hasLogged) {
                              _hasLogged = true;
                              _hasLoggedFirstPreview = true;
                            }
                            return const Center(
                              child:
                                  Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                          imageBuilder: (context, imageProvider) {
                            // Sadece İLK preview için log at
                            if (!_hasLoggedFirstPreview &&
                                _firstLoadStartTime != null) {
                              _hasLoggedFirstPreview =
                                  true; // Artık başka log atmayacak
                            }

                            return Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                        // Gölge efekti
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 56.h,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // BADGE (ticket localization)
                        if (widget.ticket != null && widget.ticket!.isNotEmpty)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 2.w),
                              decoration: BoxDecoration(
                                color: _getTicketColor(widget.ticket!),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                getTicketLabel(context, widget.ticket!),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 4.h,
                          left: 4.w,
                          child: Text(
                            widget.text,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Backend'den gelen ticket anahtarını localization ile eşle.
String getTicketLabel(BuildContext context, String? ticket) {
  if (ticket == null || ticket.isEmpty) return '';
  final l10n = AppLocalizations.of(context);
  switch (ticket.toLowerCase()) {
    case 'hot':
      return l10n.ticket_hot;
    case 'new':
      return l10n.ticket_new;
    case 'trend':
    case 'trending':
      return l10n.ticket_trend;
    case 'popular':
      return l10n.ticket_popular;
    case 'premium':
      return l10n.ticket_premium;
    default:
      return ticket;
  }
}

Color _getTicketColor(String ticket) {
  switch (ticket.toLowerCase()) {
    case 'hot':
      return Colors.red.shade900;
    case 'trend':
      return Colors.amber.shade700;
    case 'new':
      return Colors.blue.shade700;
    case 'popular':
      return Colors.purple.shade700;
    case 'premium':
      return Colors.red.shade900;
    default:
      return Colors.grey.shade600;
  }
}
