part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object> get props => [];
}

class SubmitReportEvent extends ReportEvent {
  final ReportModel report;

  const SubmitReportEvent({required this.report});

  @override
  List<Object> get props => [report];
}
