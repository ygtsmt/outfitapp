import "package:auto_route/auto_route.dart";
import "package:ginfit/app/bloc/app_bloc.dart";
import "package:ginfit/core/core.dart";
import "package:ginfit/core/data_sources/local_data_source/secure_data_storage.dart";
import "package:ginfit/generated/l10n.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class GinlySideBar extends StatelessWidget {
  const GinlySideBar({super.key});

  @override
  Widget build(final BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(),
      elevation: 1,
      child: BlocBuilder<AppBloc, AppState>(
        builder: (final context, final state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    DrawerHeader(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          Text(
                            AppLocalizations.of(context).nameSurname,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    DrawerListTile(
                      title: AppLocalizations.of(context).dashboard,
                      icon: Icons.dashboard_outlined,
                      press: () {},
                    ),
                    DrawerListTile(
                      title: AppLocalizations.of(context).pAndE,
                      icon: Icons.track_changes_outlined,
                      press: () {},
                    ),
                    DrawerListTile(
                      title: AppLocalizations.of(context).vehicle,
                      icon: Icons.directions_car_filled_outlined,
                      press: () {},
                    ),
                    DrawerListTile(
                      title: AppLocalizations.of(context).auction,
                      icon: Icons.gavel_outlined,
                      press: () {},
                    ),
                    DrawerListTile(
                      title: AppLocalizations.of(context).profile,
                      icon: Icons.person_outline,
                      press: () {},
                    ),
                  ],
                ),
              ),
              const Divider(),
              BlocBuilder<AppBloc, AppState>(
                builder: (final context, final state) {
                  return SwitchListTile(
                    value: state.themeMode == ThemeMode.dark,
                    onChanged: (final bool value) {
                      getIt<AppBloc>().add(SetThemeEvent(
                          value ? ThemeMode.dark : ThemeMode.light));
                    },
                    title: Text(AppLocalizations.of(context).dark_mode),
                  );
                },
              ),
              const Divider(),
              DrawerListTile(
                title: AppLocalizations.of(context).logout,
                icon: Icons.logout_outlined,
                press: () {
                  final secureDataStorage = getIt<SecureDataStorage>();

                  secureDataStorage.deleteAll();
                  context.router.replace(const LoginScreenRoute());
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    required this.title,
    required this.icon,
    required this.press,
    super.key,
  });

  final String title;
  final IconData icon;
  final VoidCallback press;

  @override
  Widget build(final BuildContext context) {
    return ListTile(
      onTap: press,
      leading: Icon(icon),
      title: Text(
        title,
      ),
    );
  }
}
