// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/core/constants/layout_constants.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/core/data_sources/local_data_source/secure_data_storage.dart';
import 'package:ginfit/generated/l10n.dart';

class LanguageDropdown extends StatefulWidget {
  final String selectedLocale;
  const LanguageDropdown({super.key, required this.selectedLocale});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  late LanguageItem selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = languages
        .firstWhere((lang) => lang.code == widget.selectedLocale); // varsayılan
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showLanguageBottomSheet(context);
      },
      child: Row(
        children: [
          LayoutConstants.centralEmptyWidth,
          Row(
            children: [
              Image.asset(
                selectedLanguage.flagAsset,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 16),
              Text(
                AppLocalizations.of(context).changeLanguage,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                AppLocalizations.of(context).selectLanguage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Language list with scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: languages.map((LanguageItem lang) {
                      final isSelected = lang.code == selectedLanguage.code;
                      return ListTile(
                        leading: Image.asset(
                          lang.flagAsset,
                          width: 32,
                          height: 32,
                        ),
                        title: Text(
                          lang.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                        onTap: () async {
                          setState(() {
                            selectedLanguage = lang;
                          });
                          // Dil ayarını kalıcı olarak sakla
                          await getIt<SecureDataStorage>()
                              .setAppLanguage(Locale(lang.code));
                          getIt<AppBloc>()
                              .add(SetLanguageEvent(Locale(lang.code)));
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class LanguageItem {
  final String code;
  final String name;
  final String flagAsset;

  LanguageItem(
      {required this.code, required this.name, required this.flagAsset});
}

final List<LanguageItem> languages = [
  LanguageItem(code: 'tr', name: 'Türkçe', flagAsset: PngPaths.turkeyFlag),
  LanguageItem(code: 'en', name: 'English', flagAsset: PngPaths.usaFlag),
  LanguageItem(code: 'es', name: 'Español', flagAsset: PngPaths.spainFlag),
  LanguageItem(code: 'fr', name: 'Français', flagAsset: PngPaths.franceFlag),
  LanguageItem(code: 'de', name: 'Deutsch', flagAsset: PngPaths.germanyFlag),
  LanguageItem(code: 'ru', name: 'Русский', flagAsset: PngPaths.russiaFlag),
  LanguageItem(code: 'ar', name: 'العربية', flagAsset: PngPaths.arabicFlag),
  LanguageItem(code: 'zh', name: '中文', flagAsset: PngPaths.chineseFlag),
  LanguageItem(code: 'hi', name: 'हिन्दी', flagAsset: PngPaths.indiaFlag),
  LanguageItem(code: 'pt', name: 'Português', flagAsset: PngPaths.portugalFlag),
  LanguageItem(
      code: 'id', name: 'Bahasa Indonesia', flagAsset: PngPaths.indonesiaFlag),
];
 /* tabsRouter.activeIndex != 3
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (final context) {
                                      return AboutDialog(
                                        applicationName: "GinFit AI",
                                        applicationVersion: "v1.0.0",
                                        applicationIcon: Image.asset(
                                          PngPaths.logo,
                                          height: 60.h,
                                        ),
                                        children: [
                                          Text(AppLocalizations.of(context)
                                                  .developedBy +
                                              ' Yiğit Samet Ölmez'),
                                          CustomGradientButton(
                                            title: AppLocalizations.of(context)
                                                .contactDeveloper,
                                            onTap: () {
                                              launch(
                                                  "https://www.linkedin.com/in/ygtsmt/");
                                            },
                                            isFilled: true,
                                            leading: null,
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  Icons.info,
                                  color: context.baseColor,
                                ),
                              )
                            : */