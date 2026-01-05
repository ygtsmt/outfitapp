import "package:comby/app/bloc/app_bloc.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class CombyScreenHeader extends StatelessWidget {
  const CombyScreenHeader({
    this.actions,
    super.key,
  });
  final Widget? actions;

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    /* state.auth.currentUser?.displayName != null
                        ? 'Welcome, ${state.auth.currentUser?.displayName}'
                        : */
                    'Welcome',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 20),
                  ),
                ),
              ),
              if (actions != null)
                Expanded(
                  flex: 3,
                  child:
                      Align(alignment: Alignment.bottomRight, child: actions),
                ),
            ],
          ),
        );
      },
    );
  }
}
