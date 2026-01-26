// ignore_for_file: public_member_api_docs, sort_constructors_first
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:comby/app/bloc/app_bloc.dart";
import "package:comby/core/extensions.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_fonts/google_fonts.dart";

class CombyLogo extends StatelessWidget {
  const CombyLogo({
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
          Text('Combsy',
              textAlign: TextAlign.center,
              style: GoogleFonts.balooBhai2(
                  fontSize: 56.sp,
                  fontWeight: FontWeight.bold,
                  color: context.baseColor)),
        BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return Image.asset(
              'assets/png/launcher_icon_ios.png',
            );
          },
        )
      ],
    );
  }
}
