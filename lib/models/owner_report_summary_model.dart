class OwnerReportSummaryModel {
  final String accountStatus;
  final bool isAccountSuspended;
  final int activeStrikes;
  final int totalStrikes;
  final OwnerReportCount reports;
  final OwnerPenaltiesBreakdown penaltiesBreakdown;
  final List<OwnerActivePenalty> activePenalties;
  final List<OwnerRecentReport> recentReports;

  OwnerReportSummaryModel({
    required this.accountStatus,
    required this.isAccountSuspended,
    required this.activeStrikes,
    required this.totalStrikes,
    required this.reports,
    required this.penaltiesBreakdown,
    required this.activePenalties,
    required this.recentReports,
  });

  factory OwnerReportSummaryModel.fromJson(dynamic rawJson) {
    if (rawJson == null) return OwnerReportSummaryModel.initial();

    final Map<String, dynamic> json = rawJson is Map
        ? Map<String, dynamic>.from(rawJson)
        : <String, dynamic>{};

    final Map<String, dynamic> data = (json['data'] != null && json['data'] is Map)
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final rawStatus = data['account_status']?.toString() ?? 'ACTIVE';
    final rawIsSuspended = data['is_account_suspended'];
    final isSuspended = rawIsSuspended == true ||
        rawIsSuspended == 1 ||
        rawIsSuspended?.toString() == '1' ||
        rawIsSuspended?.toString().toLowerCase() == 'true' ||
        rawStatus.toUpperCase() == 'SUSPENDED';

    return OwnerReportSummaryModel(
      accountStatus: rawStatus,
      isAccountSuspended: isSuspended,
      activeStrikes: int.tryParse(data['active_strikes']?.toString() ?? '') ?? 0,
      totalStrikes: int.tryParse(data['total_strikes']?.toString() ?? '') ?? 0,
      reports: OwnerReportCount.fromJson(
        data['reports'] is Map ? Map<String, dynamic>.from(data['reports'] as Map) : {},
      ),
      penaltiesBreakdown: OwnerPenaltiesBreakdown.fromJson(
        data['penalties_breakdown'] is Map
            ? Map<String, dynamic>.from(data['penalties_breakdown'] as Map)
            : {},
      ),
      activePenalties: (data['active_penalties'] as List<dynamic>?)
              ?.where((e) => e != null && e is Map)
              .map((e) => OwnerActivePenalty.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      recentReports: (data['recent_reports'] as List<dynamic>?)
              ?.where((e) => e != null && e is Map)
              .map((e) => OwnerRecentReport.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  factory OwnerReportSummaryModel.initial() {
    return OwnerReportSummaryModel(
      accountStatus: 'ACTIVE',
      isAccountSuspended: false,
      activeStrikes: 0,
      totalStrikes: 0,
      reports: OwnerReportCount(total: 0, pending: 0, resolved: 0, rejected: 0),
      penaltiesBreakdown: OwnerPenaltiesBreakdown(
        warnings: 0,
        carSuspensions: 0,
        accountSuspensions: 0,
      ),
      activePenalties: [],
      recentReports: [],
    );
  }
}

class OwnerReportCount {
  final int total;
  final int pending;
  final int resolved;
  final int rejected;

  OwnerReportCount({
    required this.total,
    required this.pending,
    required this.resolved,
    required this.rejected,
  });

  factory OwnerReportCount.fromJson(Map<String, dynamic> json) {
    return OwnerReportCount(
      total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
      pending: int.tryParse(json['pending']?.toString() ?? '') ?? 0,
      resolved: int.tryParse(json['resolved']?.toString() ?? '') ?? 0,
      rejected: int.tryParse(json['rejected']?.toString() ?? '') ?? 0,
    );
  }
}

class OwnerPenaltiesBreakdown {
  final int warnings;
  final int carSuspensions;
  final int accountSuspensions;

  OwnerPenaltiesBreakdown({
    required this.warnings,
    required this.carSuspensions,
    required this.accountSuspensions,
  });

  factory OwnerPenaltiesBreakdown.fromJson(Map<String, dynamic> json) {
    return OwnerPenaltiesBreakdown(
      warnings: int.tryParse(json['warnings']?.toString() ?? '') ?? 0,
      carSuspensions:
          int.tryParse(json['car_suspensions']?.toString() ?? '') ?? 0,
      accountSuspensions:
          int.tryParse(json['account_suspensions']?.toString() ?? '') ?? 0,
    );
  }
}

class OwnerActivePenalty {
  final int id;
  final String penaltyType;
  final String reason;
  final String? startAt;
  final String? endAt;
  final int? tripId;
  final String? tripCode;
  final int? reportId;

  OwnerActivePenalty({
    required this.id,
    required this.penaltyType,
    required this.reason,
    this.startAt,
    this.endAt,
    this.tripId,
    this.tripCode,
    this.reportId,
  });

  String get displayTripCode {
    if (tripCode != null && tripCode!.isNotEmpty) {
      return tripCode!;
    }
    if (tripId != null) {
      return '#$tripId';
    }
    return '';
  }

  int get penaltyTypeCode {
    final parsed = int.tryParse(penaltyType);
    if (parsed != null) return parsed;
    final lower = penaltyType.toLowerCase();
    if (lower.contains('warning1') || lower.contains('warning 1') || lower == 'warning') return 0;
    if (lower.contains('warning2') || lower.contains('warning 2')) return 1;
    if (lower.contains('accountsuspension') || lower.contains('account_suspension') || lower.contains('suspension') || lower.contains('khóa')) return 2;
    return 0;
  }

  String get penaltyTypeDisplay {
    switch (penaltyTypeCode) {
      case 0:
        return 'Cảnh cáo lần 1';
      case 1:
        return 'Cảnh báo lần 2';
      case 2:
        return 'Khóa tài khoản';
      default:
        return 'Cảnh cáo';
    }
  }

  factory OwnerActivePenalty.fromJson(Map<String, dynamic> json) {
    final rawTripCode = json['trip_code']?.toString() ??
        (json['trip'] is Map ? json['trip']['trip_code']?.toString() : null);
    final rawTripId = int.tryParse(json['trip_id']?.toString() ?? '') ??
        (json['trip'] is Map
            ? int.tryParse(json['trip']['id']?.toString() ?? '')
            : null);

    return OwnerActivePenalty(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      penaltyType: json['penalty_type']?.toString() ?? 'Warning',
      reason: json['reason']?.toString() ?? '',
      startAt: json['start_at']?.toString(),
      endAt: json['end_at']?.toString(),
      tripId: rawTripId,
      tripCode: rawTripCode,
      reportId: int.tryParse(json['report_id']?.toString() ?? ''),
    );
  }
}

class OwnerRecentReport {
  final int id;
  final String title;
  final String status;
  final String? createdAt;

  OwnerRecentReport({
    required this.id,
    required this.title,
    required this.status,
    this.createdAt,
  });

  int get statusCode {
    final parsed = int.tryParse(status);
    if (parsed != null) return parsed;
    final lower = status.toLowerCase();
    if (lower == 'pending' || lower.contains('chờ')) return 0;
    if (lower == 'resolved' || lower.contains('giải quyết') || lower.contains('đã xử lý')) return 1;
    if (lower == 'rejected' || lower.contains('từ chối')) return 2;
    return 0;
  }

  String get statusDisplay {
    switch (statusCode) {
      case 0:
        return 'Chờ xử lý';
      case 1:
        return 'Đã giải quyết';
      case 2:
        return 'Từ chối';
      default:
        return 'Chờ xử lý';
    }
  }

  factory OwnerRecentReport.fromJson(Map<String, dynamic> json) {
    return OwnerRecentReport(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '0',
      createdAt: json['created_at']?.toString(),
    );
  }
}
