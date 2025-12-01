// ignore_for_file: public_member_api_docs, sort_constructors_first
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:ginly/app/bloc/app_bloc.dart";
import "package:ginly/core/extensions.dart";
import "package:ginly/core/asset_paths.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class GinlyLogo extends StatelessWidget {
  const GinlyLogo({
    Key? key,
    this.themeMode = ThemeMode.dark,
    required this.haveText,
  }) : super(key: key);
  final ThemeMode themeMode;
  final bool haveText;

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        if (haveText)
          Text('GINLY',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Futura',
                  color: context.baseColor)),
        BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return Image.asset(
              PngPaths.logo,
            );
          },
        )
      ],
    );
  }
}
