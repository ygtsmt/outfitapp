import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/bloc/app_bloc.dart';
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comby/core/constants/layout_constants.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatefulWidget {
  final AppState state;
  const CustomDrawer({
    super.key,
    required this.state,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  /// Resolve document URL based on locale
  String resolveDocumentByLocale(
    String currentLocale,
    String enUrl,
    String trUrl,
    String deUrl,
    String frUrl,
  ) {
    switch (currentLocale) {
      case 'tr':
        return trUrl;
      case 'de':
        return deUrl;
      case 'fr':
        return frUrl;
      case 'en':
      default:
        return enUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width / 1.5,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 8.h,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/png/launcher_icon_android.png',
                    height: 150.h,
                  ),
                  SizedBox(height: 16.h),
                  Text(AppLocalizations.of(context).appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Futura',
                              color: context.baseColor)),
                ],
              ),
              const Divider(),

              LayoutConstants.tinyEmptyHeight,

              // Rate App - Only show to users who haven't reviewed yet

              ListTile(
                title: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        spacing: 4,
                        children: [
                          Text(
                            'Version ${snapshot.data!.version}-${snapshot.data!.buildNumber}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(
                                  'https://www.linkedin.com/in/ygtsmt/');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Made by ',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: context.baseColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Ginowl',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: context.baseColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: context.baseColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
