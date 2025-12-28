import 'package:flutter/material.dart';
import 'package:ginfit/app/features/auth/features/profile/data/models/report_model.dart';
import 'package:ginfit/app/features/report/data/report_usecase.dart';
import 'package:ginfit/core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'report_event.dart';
part 'report_state.dart';

@singleton
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportUsecase reportUsecase;

  ReportBloc({
    required this.reportUsecase,
  }) : super(const ReportState()) {
    on<SubmitReportEvent>((event, emit) async {
      emit(state.copyWith(submitReportStatus: EventStatus.processing));

      try {
        final result = await reportUsecase.submitReport(event.report);

        if (result == EventStatus.success) {
          emit(state.copyWith(submitReportStatus: EventStatus.success));
        } else {
          emit(state.copyWith(submitReportStatus: EventStatus.failure));
        }
      } catch (e) {
        emit(state.copyWith(submitReportStatus: EventStatus.failure));
      }

      emit(state.copyWith(submitReportStatus: EventStatus.idle));
    });
  }
}
