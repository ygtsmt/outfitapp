part of 'report_bloc.dart';

class ReportState extends Equatable {
  final EventStatus submitReportStatus;

  const ReportState({
    this.submitReportStatus = EventStatus.idle,
  });

  ReportState copyWith({
    EventStatus? submitReportStatus,
  }) {
    return ReportState(
      submitReportStatus: submitReportStatus ?? this.submitReportStatus,
    );
  }

  @override
  List<Object?> get props => [submitReportStatus];
}
