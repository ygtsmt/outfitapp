import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/realtime/bloc/realtime_bloc.dart';
import 'package:ginly/app/features/library/bloc/library_bloc.dart';
import 'package:ginly/app/features/library/ui/screens/library_screen.dart';
import 'package:ginly/core/constants/layout_constants.dart';
import 'package:ginly/core/core.dart';

class RealtimeHistoryListviewWidget extends StatefulWidget {
  const RealtimeHistoryListviewWidget({super.key});

  @override
  State<RealtimeHistoryListviewWidget> createState() =>
      _RealtimeHistoryListviewWidgetState();
}

class _RealtimeHistoryListviewWidgetState
    extends State<RealtimeHistoryListviewWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealtimeBloc, RealtimeState>(
      builder: (context, state) {
        final base64List = state.realtimePhotoBase64LIST ?? [];
        // Reverse the list to show most recent items first
        final reversedList = List.from(base64List.reversed);

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: reversedList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                getIt<RealtimeBloc>().add(
                  SelectedRealtimeBase64Event(
                    selectedBase64: reversedList[index],
                  ),
                );
              },
              child: Card(
                elevation: 10,
                margin: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Image.memory(
                    base64Decode(reversedList[index]),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return LayoutConstants.lowEmptyWidth;
          },
        );
      },
    );
  }
}
