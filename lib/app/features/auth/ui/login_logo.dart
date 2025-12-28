import "package:ginfit/app/bloc/app_bloc.dart";
import "package:ginfit/app/ui/widgets/ginly_logo.dart";
import "package:flutter/material.dart";
import "package:flutter_adaptive_ui/flutter_adaptive_ui.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class LoginLogo extends StatelessWidget {
  final bool haveText;
  const LoginLogo({
    super.key,
    required this.haveText,
  });

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (final context, final state) {
        return AdaptiveBuilder(
          layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
            handset: (final BuildContext context, final Screen screen) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child:
                    GinlyLogo(themeMode: state.themeMode, haveText: haveText),
              );
            },
            tablet: (final BuildContext context, final Screen screen) {
              return SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child:
                    GinlyLogo(themeMode: state.themeMode, haveText: haveText),
              );
            },
          ),
          defaultBuilder: (final BuildContext context, final Screen screen) {
            return SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: GinlyLogo(themeMode: state.themeMode, haveText: haveText),
            );
          },
        );
      },
    );
  }
}
