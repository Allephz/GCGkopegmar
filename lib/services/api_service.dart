// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/responses.dart';

class ApiService {
  // ===== REAL API MODE =====
  // Set to true only for offline testing with dummy data
  static const bool _useMockData = false;

  // API Configuration — matched from Kotlin ApiConfig.kt
  static const String baseUrl = 'https://kopegmar.gcgakor.id/';
  static const String apiKey = 'AwA88Z410ngJmkDj52TkQw'; // API_DEV_CODE_KOPEGMAR
  static const String workspaceId = 'YPNRO'; // WORKSPACE_CODE_KOPEGMAR

  // ============================
  // Route Codes (RC) — MATCHED exactly from Kotlin ApiService.kt
  // ============================

  // --- GET endpoints ---
  static const String rcPersonalData =
      'gS%2BZtyMBHTdgEoheRgK6hoGn9gB9jdSeepx4X6/t2uDtvQTu57s32w%3D%3D';
  static const String rcProfileExt =
      'KvRnqbr%2Bktu7HRDvQttp6LEdk0Nmqoyg7GQ98Ln6DH4%3D';
  static const String rcProfileImage =
      'KvRnqbr%2Bktu7HRDvQttp6EuNm8yG06I%2BsB2%2BPg9itk8%3D';
  static const String rcNominalSimpanan =
      'NU5mgOhAZUE%2Bb0mTYNGiy8FnGKoc3rg3V1Q9KP8l2D9Qwl%2Bjv4wJfA%3D%3D';
  static const String rcDetailSimpanan =
      'NU5mgOhAZUGhJ24WH1zuqwTnRtBFfK6yTAxuvzoHj/mdTherKRvxb70mprxQNT2w';
  static const String rcRiwayatTarikSimp =
      'NU5mgOhAZUGhJ24WH1zuqwTnRtBFfK6yxaqXRILhNI6FFnG1cZ%2BfN92u5JH/Gt%2BrUA0E9KRDqbA%3D';
  static const String rcTipePotongan =
      'tBuYtyWkt9BVca9T0hdoheGNqUKSfmxc0OeVrYJV618%3D';
  // FIXED: tenor list RC was wrong
  static const String rcTenorList =
      'tBuYtyWkt9DJpiePfo46tA3TDdHcBBda/t0TnlvsUHGFBHt4quLErXfLmMJrecF6';
  // FIXED: total pinjaman RC was wrong
  static const String rcGetTotalPinjaman =
      'eDnXtEc2652RTOAUh6gjc0fTS6w6yarnNmGlUghIFK8vvOgHSm1Qlw%3D%3D';
  // FIXED: history pinjaman RC was wrong
  static const String rcGetHistoryPinjaman =
      'UQihbFj9rzSMdr02uS94Z1oDhH69zUlWBxxyo8ewHNB3y5jCa3nBeg%3D%3D';
  // FIXED: detail history pinjaman RC was wrong
  static const String rcGetDetailHistoryPinjaman =
      'UQihbFj9rzSMdr02uS94Z1oDhH69zUlWP9Zwm1Tdxg2Gye0yFDZXOY5AHiEp%2BuOwUA0E9KRDqbA%3D';
  // FIXED: riwayat transaksi RC was wrong
  static const String rcGetRiwayatTransaksi =
      'eDnXtEc2652RTOAUh6gjczLzlgxjU9l1ptFYPDEmI32mLptn1Yft3g%3D%3D';

  // --- POST endpoints ---
  static const String rcTarikSimpanan =
      'NU5mgOhAZUGhJ24WH1zuqwTnRtBFfK6y6OVw0Q2/ZWSE2T%2BDBSLsen/SgBttLGZS';
  // FIXED: update profile RC was wrong
  static const String rcUpdateProfile =
      'KvRnqbr%2Bktu7HRDvQttp6MRyn3VICeItrNiEgAa5Ce0%3D';
  // FIXED: hitung adm pinjaman RC was wrong
  static const String rcHitungAdmPinjaman =
      'tBuYtyWkt9DJpiePfo46tATnRtBFfK6yd3qgnOiweQo%3D';
  // NEW: ajukan pinjaman (was missing)
  static const String rcAjukanPinjaman =
      'tBuYtyWkt9DJpiePfo46tATnRtBFfK6yK6ChYzspyElabeFBWEFWHoPNmn8uf4HQ';
  // NEW: hitung adm pinjaman lain (was missing)
  static const String rcHitungAdmPinjamanLain =
      'tBuYtyWkt9DJpiePfo46tATnRtBFfK6yeFEM8SP96ycJmkDj52TkQw%3D%3D';
  // NEW: ajukan pinjaman lain (was missing)
  static const String rcAjukanPinjamanLain =
      'tBuYtyWkt9DJpiePfo46tATnRtBFfK6yK6ChYzspyElabeFBWEFWHoDRiFVzSWeNxBeogXA5IyQ%3D';
  // FIXED: edit personal data RC was wrong
  static const String rcEditPersonalData =
      'gS%2BZtyMBHTdgEoheRgK6hpiC0koiixuPdMRrFD8wcA/ok1VvRGdRugmaQOPnZORD';

  late Dio _dio;
  String? _sessionId;
  String? _token;
  String? _memberId;
  String? _username;

  // Singleton so session is shared across all screens
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      // Accept ALL status codes — Clodios ERP server returns 500 for
      // certain responses (e.g. failed login). We handle errors in code.
      validateStatus: (status) => true,
    ));

    // SSL Certificate bypass — same as UnsafeOkHttpClient in Kotlin ApiConfig.kt
    // Server kopegmar.com may use a self-signed or improperly configured certificate
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Logging interceptor for debugging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[API REQUEST] ${options.method} ${options.uri}');
          if (options.data != null) {
            print('[API BODY] ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
              '[API RESPONSE] ${response.statusCode} ${response.requestOptions.uri}');
          print('[API DATA] ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('[API ERROR] ${error.message}');
          if (error.response != null) {
            print('[API ERROR DATA] ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ==============================
  // URL BUILDERS
  // Clodios ERP uses semicolons (;) as parameter separators,
  // NOT standard ampersand (&). Must build URLs manually.
  // Format: txn?fnc=runLib;opic={API_KEY};csn={WORKSPACE};rc={RC};vars={ENCODED_JSON}
  // ==============================

  /// Build a full GET URL with semicolon-separated parameters
  String _buildGetUrl(String rc, Map<String, dynamic> vars) {
    final jsonString = jsonEncode(vars);
    final encodedVars = Uri.encodeComponent(jsonString);
    return '${baseUrl}txn?fnc=runLib;opic=$apiKey;csn=$workspaceId;rc=$rc;vars=$encodedVars';
  }

  /// Build a full POST URL with semicolon-separated parameters
  String _buildPostUrl(String rc) {
    return '${baseUrl}txn?fnc=runLib;opic=$apiKey;csn=$workspaceId;rc=$rc';
  }

  /// Helper: get current date as dd-MM-yyyy
  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
  }

  // ==============================
  // AUTHENTICATION
  // Login uses preodm?fnc=auth endpoint (same as Kotlin)
  // ==============================

  Future<LoginResponse> login({
    required String username,
    required String password,
    String? deviceId,
    String? deviceInfo,
  }) async {
    if (_useMockData) {
      _sessionId = 'mock-session-12345';
      _token = 'mock-token-abcdef';
      _memberId = username;
      return LoginResponse(
        sessionId: 'mock-session-12345',
        token: 'mock-token-abcdef',
        profileId: 'PROF001',
        errorMessage: 'SUCCESS',
      );
    }

    try {
      final response = await _dio.post(
        '${baseUrl}preodm?fnc=auth',
        data: {
          'csn': workspaceId,
          'usn': username,
          'pwd': password,
          // 'unifie': deviceId ?? 'flutter-mobile-app',
          // 'urifie': deviceInfo ?? 'Flutter Android',
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => true,
        ),
      );

      // Server may return non-JSON (Python traceback) on 500 errors
      Map<String, dynamic> jsonData;
      try {
        if (response.data is Map<String, dynamic>) {
          jsonData = response.data;
        } else {
          jsonData = jsonDecode(response.data.toString());
        }
      } catch (_) {
        // Response is not JSON — server returned an error page/traceback
        return LoginResponse(
          errorMessage: 'Server error (${response.statusCode})',
        );
      }

      final loginResponse = LoginResponse.fromJson(jsonData);

      if (loginResponse.isSuccess) {
        _sessionId = loginResponse.sessionId;
        _token = loginResponse.token;
        _memberId = username.toUpperCase();
        _username = username;
      }
      return loginResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // ==============================
  // USER DATA (GET)
  // ==============================

  Future<PersonalDataResponse> getPersonalData(String username) async {
    if (_useMockData) {
      return PersonalDataResponse(
        code: 200,
        message: 'SUCCESS',
        data: PersonalData(
          memberId: '12345',
          name: 'Candra Wijaya',
          email: 'candra@example.com',
          phone: '08123456789',
          gender: 'Laki-laki',
          birthPlace: 'Jakarta',
          birthDate: '1990-05-15',
          address: 'Jl. Merdeka No. 123, Jakarta',
          company: 'PT Garuda Mas',
          employeeNumber: '198905151001',
          bank: 'Bank Mandiri',
          bankAccount: '1234567890123456',
          bankAccountName: 'Candra Wijaya',
        ),
      );
    }

    try {
      // Use memberId if available, else fall back to provided username
      final effectiveUsername = _memberId ?? username;
      final url = _buildGetUrl(rcPersonalData, {'username': effectiveUsername});
      final response = await _dio.get(url);

      // Handle empty or null response from server
      final rawData = response.data;
      if (rawData == null || rawData.toString().trim().isEmpty) {
        return PersonalDataResponse(code: 200, message: 'empty');
      }

      final profileResponse = PersonalDataResponse.fromJson(
        rawData is Map<String, dynamic>
            ? rawData
            : jsonDecode(rawData.toString()),
      );

      if (profileResponse.data?.memberId != null && profileResponse.data!.memberId!.isNotEmpty) {
        _memberId = profileResponse.data!.memberId;
      } else {
        // Fallback for admin/test accounts (ismi/abdur) that don't have their own member record
        final upperUser = username.toUpperCase();
        if (upperUser == 'ISMI' || upperUser == 'ABDUR') {
          _memberId = '10'; // Fallback to a valid member ID (Agus Djapri) for testing
        }
      }

      return profileResponse;
    } catch (e) {
      // Don't throw — return empty response so app can still show the screen
      print('getPersonalData error: $e');
      return PersonalDataResponse(code: 0, message: 'error: $e');
    }
  }

  Future<NominalSimpananResponse> getNominalSimpanan(String username) async {
    if (_useMockData) {
      return NominalSimpananResponse(
        code: 200,
        message: 'SUCCESS',
        data: [
          SavingsBalance(
            memberId: '12345',
            name: 'Candra Wijaya',
            principal: 5000000,
            mandatory: 2500000,
            voluntary: 3000000,
            special: 1500000,
          ),
        ],
      );
    }

    try {
      final url = _buildGetUrl(rcNominalSimpanan, {'username': username});
      final response = await _dio.get(url);

      return NominalSimpananResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data.toString()),
      );
    } catch (e) {
      throw Exception('Failed to fetch savings balance: $e');
    }
  }

  Future<Map<String, dynamic>> getProfileExt(String userId) async {
    try {
      final url = _buildGetUrl(rcProfileExt, {'userId': userId});
      final response = await _dio.get(url);
      return response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data.toString());
    } catch (e) {
      throw Exception('Failed to fetch profile extension: $e');
    }
  }

  Future<Map<String, dynamic>> getProfileImage(String memberId) async {
    try {
      final url = _buildGetUrl(rcProfileImage, {'mbrid': memberId});
      final response = await _dio.get(url);
      return response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data.toString());
    } catch (e) {
      throw Exception('Failed to fetch profile image: $e');
    }
  }

  /// Get image URL for a user
  String getProfileImageUrl(String imagePath) {
    return '$baseUrl$imagePath';
  }

  // ==============================
  // SAVINGS (GET)
  // ==============================

  Future<Map<String, dynamic>> getDetailSimpanan(
      String userId, String tipeSimp) async {
    try {
      final url = _buildGetUrl(
          rcDetailSimpanan, {'userID': userId, 'tipeSimp': tipeSimp});
      final response = await _dio.get(url);
      return response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data.toString());
    } catch (e) {
      throw Exception('Failed to fetch savings detail: $e');
    }
  }

  Future<Map<String, dynamic>> getRiwayatTarikSimpanan(String memberId) async {
    try {
      final url = _buildGetUrl(rcRiwayatTarikSimp, {'mbrid': memberId});
      final response = await _dio.get(url);
      return response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data.toString());
    } catch (e) {
      throw Exception('Failed to fetch withdrawal history: $e');
    }
  }

  // ==============================
  // SAVINGS WITHDRAWAL (POST)
  // ==============================

  Future<LoanApplicationResponse> requestWithdrawal({
    required String memberId,
    required double amount,
    required String savingsType,
    required double availableBalance,
    required String notes,
  }) async {
    if (_useMockData) {
      final docNumber =
          'WD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      return LoanApplicationResponse(
        code: 200,
        message: 'SUCCESS',
        docNumber: docNumber,
      );
    }

    try {
      // FIXED: use semicolon URL format and correct field names
      final url = _buildPostUrl(rcTarikSimpanan);
      final response = await _dio.post(
        url,
        data: {
          'argt': 'vars',
          'argl': jsonEncode({
            'mbrid': memberId,
            'trans_date': _getCurrentDate(),
            'amount': amount.toStringAsFixed(0),
            'doc_date': _getCurrentDate(),
            'stp': savingsType,
            'txn_amount': availableBalance.toStringAsFixed(0),
            'ket': notes,
          }),
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => true,
        ),
      );

      return LoanApplicationResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data.toString()),
      );
    } catch (e) {
      throw Exception('Failed to request withdrawal: $e');
    }
  }

  // ==============================
  // LOANS — GET
  // ==============================

  Future<Map<String, dynamic>> getTipePotongan(String loanType) async {
    try {
      final url = _buildGetUrl(rcTipePotongan, {'tipepotongan': loanType});
      final response = await _dio.get(url);
      return response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data.toString());
    } catch (e) {
      throw Exception('Failed to fetch deduction types: $e');
    }
  }

  Future<TenorListResponse> getTenorList({String? loanType}) async {
    if (_useMockData) {
      return TenorListResponse(
        code: 200,
        message: 'SUCCESS',
        data: [
          TenorOption(tenor: '12', description: '12 Bulan'),
          TenorOption(tenor: '24', description: '24 Bulan'),
          TenorOption(tenor: '36', description: '36 Bulan'),
          TenorOption(tenor: '48', description: '48 Bulan'),
          TenorOption(tenor: '60', description: '60 Bulan'),
        ],
      );
    }

    try {
      final Map<String, dynamic> vars =
          loanType != null ? {'tipePinjaman': loanType} : {};
      final url = _buildGetUrl(rcTenorList, vars);
      final response = await _dio.get(url);

      return TenorListResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data.toString()),
      );
    } catch (e) {
      throw Exception('Failed to fetch tenor list: $e');
    }
  }

  Future<Map<String, dynamic>> getTotalPinjaman(String userId) async {
    try {
      final url = _buildGetUrl(rcGetTotalPinjaman, {'user_id': userId});
      final response = await _dio.get(url);
      return response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data.toString());
    } catch (e) {
      throw Exception('Failed to fetch total loan: $e');
    }
  }

  Future<LoanHistoryResponse> getLoanHistory(String memberId) async {
    if (_useMockData) {
      return LoanHistoryResponse(
        code: 200,
        message: 'SUCCESS',
        data: [
          LoanHistory(
            docNumber: 'LOAN-2025-001',
            amount: 10000000,
            tenor: 36,
            status: 'ACTIVE',
            approvalDate: '2025-01-10',
            loanType: 'KONSUMER',
          ),
        ],
      );
    }

    try {
      // FIXED: use semicolon URL and correct RC
      final url = _buildGetUrl(rcGetHistoryPinjaman, {'nip': username ?? memberId});
      final response = await _dio.get(url);

      return LoanHistoryResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data.toString()),
      );
    } catch (e) {
      throw Exception('Failed to fetch loan history: $e');
    }
  }

  Future<Map<String, dynamic>> getDetailHistoryPinjaman(String docNum) async {
    try {
      final url = _buildGetUrl(rcGetDetailHistoryPinjaman, {'docNum': docNum});
      final response = await _dio.get(url);
      return response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data.toString());
    } catch (e) {
      throw Exception('Failed to fetch loan detail: $e');
    }
  }

  Future<Map<String, dynamic>> getRiwayatTransaksi(String userId) async {
    try {
      final url = _buildGetUrl(rcGetRiwayatTransaksi, {'user_id': userId});
      final response = await _dio.get(url);
      return response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data.toString());
    } catch (e) {
      throw Exception('Failed to fetch transaction history: $e');
    }
  }

  // ==============================
  // LOANS — POST (Simulation & Application)
  // FIXED: field names now match Kotlin exactly
  // ==============================

  Future<LoanCalculationResponse> calculateLoanInstallment({
    required double amount,
    required int tenor,
    required String loanType,
    String? memberId,
    String? salary,
    String? personalCut,
  }) async {
    if (_useMockData) {
      final adminFee = amount * 0.01;
      final provision = amount * 0.005;
      final netAmount = amount - adminFee - provision;
      final monthlyInstallment = netAmount / tenor;
      return LoanCalculationResponse(
        code: 200,
        message: 'SUCCESS',
        data: LoanCalculation(
          requestAmount: amount,
          adminFee: adminFee,
          provision: provision,
          netAmount: netAmount,
          monthlyInstallment: monthlyInstallment,
          tenor: tenor,
        ),
      );
    }

    try {
      // FIXED: use semicolon URL and correct RC + correct field names
      final url = _buildPostUrl(rcHitungAdmPinjaman);
      final response = await _dio.post(
        url,
        data: {
          'argt': 'vars',
          'argl': jsonEncode({
            'lon': loanType,
            'am': amount.toStringAsFixed(0),
            'term': tenor.toString(),
            'mbrid': memberId ?? _memberId ?? '',
            'sal': salary ?? '0',
            'pot': personalCut ?? '0',
          }),
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => true,
        ),
      );

      return LoanCalculationResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data.toString()),
      );
    } catch (e) {
      throw Exception('Failed to calculate loan: $e');
    }
  }

  Future<LoanApplicationResponse> applyLoan({
    required String memberId,
    required double amount,
    required int tenor,
    required String loanType,
    required String pjmCode,
    required LoanCalculation calculation,
    required String gaji,
    required String potPribadi,
    required String noAtasan,
    String? dateCair,
    String? dateBonus,
  }) async {
    if (_useMockData) {
      final docNumber =
          'DOC${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      return LoanApplicationResponse(
        code: 200,
        message: 'SUCCESS',
        docNumber: docNumber,
      );
    }

    try {
      final url = _buildPostUrl(rcAjukanPinjaman);
      final payload = <String, String>{
        "mbrid": memberId,
        "amount": amount.toStringAsFixed(0),
        "term": tenor.toString(),
        "doc_date": _getCurrentDate(),
        "angsuran": calculation.monthlyInstallment.toStringAsFixed(0),
        "tot_am": calculation.total.toStringAsFixed(0),
        "loancode": pjmCode,
        "adm": calculation.adminFee.toStringAsFixed(0),
        "pjm_code": loanType,
        "provisi": calculation.provision.toStringAsFixed(0),
        "asuransi": calculation.asuransi.toStringAsFixed(0),
        "jasa": calculation.jasa.toStringAsFixed(0),
        "maksur": calculation.maksur.toStringAsFixed(0),
        "batang": calculation.batang.toStringAsFixed(0),
        "simp_khusus": calculation.simpKhusus.toStringAsFixed(0),
        "minisimp": calculation.minsimp.toStringAsFixed(0),
        "dana_cair": calculation.netAmount.toStringAsFixed(0),
        "saldo_pjm": calculation.totPjm.toStringAsFixed(0),
        "jasa_totpjm": calculation.jasaTotpjm.toStringAsFixed(0),
        "gaji": gaji,
        "pot_pribadi": potPribadi,
        "no_atasan": noAtasan,
      };
      if (dateCair != null && dateCair.isNotEmpty) {
        payload["date_cair"] = dateCair;
      }
      if (dateBonus != null && dateBonus.isNotEmpty) {
        payload["date_bonus"] = dateBonus;
      }

      final response = await _dio.post(
        url,
        data: {
          'argt': 'vars',
          'argl': jsonEncode(payload),
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => true,
        ),
      );

      return LoanApplicationResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data.toString()),
      );
    } catch (e) {
      throw Exception('Failed to apply loan: $e');
    }
  }

  // ==============================
  // LOANS LAIN — POST (Simulation & Application)
  // ==============================

  Future<LoanCalculationResponse> calculateLoanInstallmentLain({
    required double amount,
    required int tenor,
    required String loanType,
    required String interest,
    required String memberId,
  }) async {
    if (_useMockData) {
      final adminFee = amount * 0.015;
      final provision = amount * 0.01;
      final netAmount = amount - adminFee - provision;
      final monthlyInstallment = netAmount / tenor;
      return LoanCalculationResponse(
        code: 200,
        message: 'SUCCESS',
        data: LoanCalculation(
          requestAmount: amount,
          adminFee: adminFee,
          provision: provision,
          netAmount: netAmount,
          monthlyInstallment: monthlyInstallment,
          tenor: tenor,
        ),
      );
    }

    try {
      final url = _buildPostUrl(rcHitungAdmPinjamanLain);
      final response = await _dio.post(
        url,
        data: {
          'argt': 'vars',
          'argl': jsonEncode({
            'lon': loanType,
            'am': amount.toStringAsFixed(0),
            'jasa': interest,
            'term': tenor.toString(),
            'mbrid': memberId,
          }),
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => true,
        ),
      );

      return LoanCalculationResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data.toString()),
      );
    } catch (e) {
      throw Exception('Failed to calculate loan lain: $e');
    }
  }

  Future<LoanApplicationResponse> applyLoanLain({
    required String memberId,
    required double amount,
    required int tenor,
    required String loanType,
    required String pjmCode,
    required LoanCalculation calculation,
    required String gaji,
    required String potPribadi,
    required String noAtasan,
  }) async {
    if (_useMockData) {
      final docNumber =
          'DOC${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      return LoanApplicationResponse(
        code: 200,
        message: 'SUCCESS',
        docNumber: docNumber,
      );
    }

    try {
      final url = _buildPostUrl(rcAjukanPinjamanLain);
      final payload = <String, String>{
        "mbrid": memberId,
        "amount": amount.toStringAsFixed(0),
        "term": tenor.toString(),
        "doc_date": _getCurrentDate(),
        "angsuran": calculation.monthlyInstallment.toStringAsFixed(0),
        "tot_am": calculation.total.toStringAsFixed(0),
        "loancode": loanType,
        "adm": calculation.adminFee.toStringAsFixed(0),
        "pjm_code": pjmCode,
        "provisi": calculation.provision.toStringAsFixed(0),
        "asuransi": calculation.asuransi.toStringAsFixed(0),
        "jasa": calculation.jasa.toStringAsFixed(0),
        "simp_khusus": calculation.simpKhusus.toStringAsFixed(0),
        "dana_cair": calculation.netAmount.toStringAsFixed(0),
        "gaji": gaji,
        "pot_pribadi": potPribadi,
        "no_atasan": noAtasan,
      };

      final response = await _dio.post(
        url,
        data: {
          'argt': 'vars',
          'argl': jsonEncode(payload),
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => true,
        ),
      );

      print(response.data);

      return LoanApplicationResponse.fromJson(
        response.data is Map<String, dynamic>
            ? response.data
            : jsonDecode(response.data.toString()),
      );
    } catch (e) {
      throw Exception('Failed to apply loan lain: $e');
    }
  }

  // ==============================
  // PROFILE EDIT (POST)
  // ==============================

  Future<Map<String, dynamic>> editPersonalData({
    required Map<String, String> data,
  }) async {
    try {
      final url = _buildPostUrl(rcEditPersonalData);
      final response = await _dio.post(
        url,
        data: {
          'argt': 'vars',
          'argl': jsonEncode(data),
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => true,
        ),
      );
      return response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data.toString());
    } catch (e) {
      throw Exception('Failed to edit personal data: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required Map<String, String> data,
  }) async {
    try {
      final url = _buildPostUrl(rcUpdateProfile);
      final response = await _dio.post(
        url,
        data: {
          'argt': 'vars',
          'argl': jsonEncode(data),
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => true,
        ),
      );
      return response.data is Map<String, dynamic>
          ? response.data
          : jsonDecode(response.data.toString());
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // ==============================
  // SESSION
  // ==============================

  void setMemberId(String id) {
    _memberId = id;
  }

  void logout() {
    _sessionId = null;
    _token = null;
    _memberId = null;
    _username = null;
  }

  // Getters for session data
  String? get sessionId => _sessionId;
  String? get token => _token;
  String? get memberId => _memberId;
  String? get username => _username;

  bool get isLoggedIn => _token != null && _sessionId != null;
}
