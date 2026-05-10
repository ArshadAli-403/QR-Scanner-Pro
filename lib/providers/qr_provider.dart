// lib/providers/qr_provider.dart
import 'package:flutter/foundation.dart';
import '../models/qr_scan_model.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

enum LoadingState { idle, loading, loaded, error }

class QrProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<QrScanModel> _scans = [];
  List<QrScanModel> _filteredScans = [];
  LoadingState _loadingState = LoadingState.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  bool _isSearching = false;

  // ── Getters ───────────────────────────────────────────────
  List<QrScanModel> get scans =>
      _isSearching ? _filteredScans : _scans;
  LoadingState get loadingState => _loadingState;
  String get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasScans => _scans.isNotEmpty;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  int get totalScans => _scans.length;

  // ── Load all scans ────────────────────────────────────────
  Future<void> loadScans() async {
    _setLoading();
    try {
      _scans = await _dbService.getAllScans();
      _loadingState = LoadingState.loaded;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load history: ${e.toString()}');
    }
  }

  // ── Insert a new scan ─────────────────────────────────────
  Future<QrScanModel?> addScan(String qrText) async {
    try {
      final now = DateTime.now();
      final formatted = DateFormat('dd MMM yyyy  hh:mm a').format(now);

      final scan = QrScanModel(
        qrText: qrText,
        scanDate: formatted,
      );

      final id = await _dbService.insertScan(scan);
      final inserted = scan.copyWith(id: id);

      // Prepend to local list
      _scans.insert(0, inserted);
      notifyListeners();

      return inserted;
    } catch (e) {
      debugPrint('addScan error: $e');
      return null;
    }
  }

  // ── Delete a single scan ──────────────────────────────────
  Future<bool> deleteScan(int id) async {
    try {
      final deleted = await _dbService.deleteScan(id);
      if (deleted > 0) {
        _scans.removeWhere((s) => s.id == id);
        _filteredScans.removeWhere((s) => s.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('deleteScan error: $e');
      return false;
    }
  }

  // ── Delete all scans ──────────────────────────────────────
  Future<bool> deleteAllScans() async {
    try {
      await _dbService.deleteAllScans();
      _scans.clear();
      _filteredScans.clear();
      _searchQuery = '';
      _isSearching = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('deleteAllScans error: $e');
      return false;
    }
  }

  // ── Search ────────────────────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _isSearching = false;
      _filteredScans = [];
    } else {
      _isSearching = true;
      _filteredScans = _scans
          .where((s) =>
              s.qrText.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _isSearching = false;
    _filteredScans = [];
    notifyListeners();
  }

  // ── Undo delete (restore a scan locally) ─────────────────
  Future<void> undoDelete(QrScanModel scan) async {
    try {
      final id = await _dbService.insertScan(scan);
      final restored = scan.copyWith(id: id);
      // Insert in correct position by date (prepend for now)
      _scans.insert(0, restored);
      notifyListeners();
    } catch (e) {
      debugPrint('undoDelete error: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────
  void _setLoading() {
    _loadingState = LoadingState.loading;
    notifyListeners();
  }

  void _setError(String message) {
    _loadingState = LoadingState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
