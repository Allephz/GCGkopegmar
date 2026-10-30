// lib/models/responses.dart
// API Response Models — field names matched to Kotlin/Clodios ERP backend

class LoginResponse {
  final String? sessionId;
  final String? token;
  final String? profileId;
  final String? errorMessage;

  LoginResponse({
    this.sessionId,
    this.token,
    this.profileId,
    this.errorMessage,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Server may return int or other types — always convert safely with toString()
    String? _toStr(dynamic v) => v == null ? null : v.toString();
    return LoginResponse(
      sessionId: _toStr(json['s']),
      token: _toStr(json['srt']),
      profileId: _toStr(json['pid']),
      errorMessage: _toStr(json['e']),
    );
  }

  bool get isSuccess => sessionId != null && token != null;
}

class PersonalDataResponse {
  final int code;
  final String message;
  final PersonalData? data;

  PersonalDataResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory PersonalDataResponse.fromJson(Map<String, dynamic> json) {
    // Backend may return data as a list or single object
    final rawData = json['data'];
    PersonalData? parsedData;
    if (rawData is List && rawData.isNotEmpty) {
      parsedData = PersonalData.fromJson(rawData.first);
    } else if (rawData is Map<String, dynamic>) {
      parsedData = PersonalData.fromJson(rawData);
    }

    return PersonalDataResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: parsedData,
    );
  }
}

class PersonalData {
  final String? memberId;
  final String? name;
  final String? gender;
  final String? birthPlace;
  final String? birthDate;
  final String? address;
  final String? phone;
  final String? email;
  final String? bank;
  final String? bankAccount;
  final String? bankAccountName;
  final String? company;
  final String? employeeNumber;
  final String? memberGroup;
  final String? photoFile;

  PersonalData({
    this.memberId,
    this.name,
    this.gender,
    this.birthPlace,
    this.birthDate,
    this.address,
    this.phone,
    this.email,
    this.bank,
    this.bankAccount,
    this.bankAccountName,
    this.company,
    this.employeeNumber,
    this.memberGroup,
    this.photoFile,
  });

  factory PersonalData.fromJson(Map<String, dynamic> json) {
    return PersonalData(
      memberId: json['mbrid'] as String?,
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      birthPlace: json['birth_place'] as String?,
      birthDate: json['birth_date'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      bank: json['bank'] as String?,
      bankAccount: json['norek'] as String?,
      bankAccountName: json['nama_rek'] as String?,
      company: json['company'] as String?,
      employeeNumber: json['mbr_empno'] as String?,
      memberGroup: json['mbrgroup'] as String?,
      photoFile: json['photo_file'] as String?,
    );
  }
}

class NominalSimpananResponse {
  final int code;
  final String message;
  final List<SavingsBalance>? data;

  NominalSimpananResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory NominalSimpananResponse.fromJson(Map<String, dynamic> json) {
    return NominalSimpananResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? List<SavingsBalance>.from(
              (json['data'] as List).map((x) => SavingsBalance.fromJson(x)))
          : null,
    );
  }
}

class SavingsBalance {
  final String? memberId;
  final String? name;
  final String? company;
  final double principal;
  final double mandatory;
  final double voluntary;
  final double special;
  final double specialQuota;

  SavingsBalance({
    this.memberId,
    this.name,
    this.company,
    this.principal = 0.0,
    this.mandatory = 0.0,
    this.voluntary = 0.0,
    this.special = 0.0,
    this.specialQuota = 0.0,
  });

  factory SavingsBalance.fromJson(Map<String, dynamic> json) {
    return SavingsBalance(
      memberId: json['mbrid'] as String?,
      name: json['name'] as String?,
      company: json['company'] as String?,
      // Field keys matched to Kotlin NominalSimpananResponse
      principal: (json['sspo'] as num?)?.toDouble() ?? 0.0,
      mandatory: (json['sswj'] as num?)?.toDouble() ?? 0.0,
      voluntary: (json['sskr'] as num?)?.toDouble() ?? 0.0,
      special: (json['sskp'] as num?)?.toDouble() ?? 0.0,
      specialQuota: (json['sskq'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double get totalSavings =>
      principal + mandatory + voluntary + special + specialQuota;
}

class TenorListResponse {
  final int code;
  final String message;
  final List<TenorOption>? data;

  TenorListResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory TenorListResponse.fromJson(Map<String, dynamic> json) {
    return TenorListResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? List<TenorOption>.from(
              (json['data'] as List).map((x) => TenorOption.fromJson(x)))
          : null,
    );
  }
}

class TenorOption {
  final String? id;
  final String? tenor;
  final String? description;

  TenorOption({
    this.id,
    this.tenor,
    this.description,
  });

  factory TenorOption.fromJson(Map<String, dynamic> json) {
    return TenorOption(
      id: json['id'] as String?,
      tenor: json['tenor'] as String?,
      description: json['ket'] as String?,
    );
  }
}

class LoanCalculationResponse {
  final int code;
  final String message;
  final LoanCalculation? data;

  LoanCalculationResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory LoanCalculationResponse.fromJson(Map<String, dynamic> json) {
    // Support both nested 'data' map and flat map formats
    final dataMap = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return LoanCalculationResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: LoanCalculation.fromJson(dataMap),
    );
  }
}

class LoanCalculation {
  final double requestAmount;
  final double adminFee;
  final double provision;
  final double netAmount;
  final double monthlyInstallment;
  final double principalMonthly;
  final double interestMonthly;
  final int tenor;

  // Clodios Specific Fields
  final double totPjm;
  final double simpKhusus;
  final double asuransi;
  final double batang;
  final double maksur;
  final double total;
  final double minsimp;
  final double jasa;
  final double jasaTotpjm;

  LoanCalculation({
    required this.requestAmount,
    required this.adminFee,
    required this.provision,
    required this.netAmount,
    required this.monthlyInstallment,
    this.principalMonthly = 0.0,
    this.interestMonthly = 0.0,
    required this.tenor,
    this.totPjm = 0.0,
    this.simpKhusus = 0.0,
    this.asuransi = 0.0,
    this.batang = 0.0,
    this.maksur = 0.0,
    this.total = 0.0,
    this.minsimp = 0.0,
    this.jasa = 0.0,
    this.jasaTotpjm = 0.0,
  });

  factory LoanCalculation.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return LoanCalculation(
      requestAmount: _toDouble(json['request_amount']),
      adminFee: _toDouble(json['adm']),
      provision: _toDouble(json['provisi']),
      netAmount: _toDouble(json['dana_cair'] ?? json['diterima']),
      monthlyInstallment: _toDouble(json['angsuran'] ?? json['total_bulanan']),
      principalMonthly: _toDouble(json['pokok_bulanan']),
      interestMonthly: _toDouble(json['jasa_bulanan'] ?? json['jasa']),
      tenor: json['tenor'] as int? ?? 0,
      totPjm: _toDouble(json['tot_pjm']),
      simpKhusus: _toDouble(json['simp_khusus']),
      asuransi: _toDouble(json['asuransi']),
      batang: _toDouble(json['batang']),
      maksur: _toDouble(json['maksur']),
      total: _toDouble(json['total']),
      minsimp: _toDouble(json['minsimp']),
      jasa: _toDouble(json['jasa']),
      jasaTotpjm: _toDouble(json['jasa_totpjm']),
    );
  }
}

class LoanApplicationResponse {
  final int code;
  final String message;
  final String? docNumber;
  final String? details;

  LoanApplicationResponse({
    required this.code,
    required this.message,
    this.docNumber,
    this.details,
  });

  factory LoanApplicationResponse.fromJson(Map<String, dynamic> json) {
    return LoanApplicationResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      docNumber: json['docnum'] as String?,
      details: json['details'] as String?,
    );
  }

  bool get isSuccess => code == 200;
}

class LoanHistoryResponse {
  final int code;
  final String message;
  final List<LoanHistory>? data;

  LoanHistoryResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory LoanHistoryResponse.fromJson(Map<String, dynamic> json) {
    return LoanHistoryResponse(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? List<LoanHistory>.from(
              (json['data'] as List).map((x) => LoanHistory.fromJson(x)))
          : null,
    );
  }
}

class LoanHistory {
  final String? docNumber;
  final String? docDate;
  final double amount;
  final int tenor;
  final String? status;
  final String? approvalDate;
  final String? loanType;
  // Additional fields from Kotlin DetailHistoryPinjamanResponse
  final double disbursed;
  final double totalLoan;
  final double remaining;

  LoanHistory({
    this.docNumber,
    this.docDate,
    required this.amount,
    required this.tenor,
    this.status,
    this.approvalDate,
    this.loanType,
    this.disbursed = 0.0,
    this.totalLoan = 0.0,
    this.remaining = 0.0,
  });

  factory LoanHistory.fromJson(Map<String, dynamic> json) {
    return LoanHistory(
      // FIXED: server sends 'doc_num' not 'doc_number'
      docNumber: (json['doc_num'] ?? json['doc_number']) as String?,
      docDate: json['doc_date'] as String?,
      // FIXED: server sends 'plafon_am' not 'amount'
      amount: (json['plafon_am'] ?? json['amount'] as num?)?.toDouble() ?? 0.0,
      // FIXED: server sends 'sisa_tenor' not 'tenor'
      tenor: (json['sisa_tenor'] ?? json['tenor']) as int? ?? 0,
      // FIXED: server sends 'status' not 'pstatus'
      status: (json['status'] ?? json['pstatus']) as String?,
      // FIXED: server sends 'apr' not 'approval_date'
      approvalDate: (json['apr'] ?? json['approval_date']) as String?,
      // FIXED: server sends 'loan_name' not 'loan_type'
      loanType: (json['loan_name'] ?? json['loan_type']) as String?,
      // New fields
      disbursed: (json['dana_cair'] as num?)?.toDouble() ?? 0.0,
      totalLoan: (json['tot_pjm'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remain'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
