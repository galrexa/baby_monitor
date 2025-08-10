import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../shared/models/room_model.dart';
import '../../shared/models/alarm_model.dart';

class CaretakerState {
  final List<Room> assignedRooms;
  final List<Alarm> activeAlarms;
  final bool isLoading;
  final String? error;

  const CaretakerState({
    this.assignedRooms = const [],
    this.activeAlarms = const [],
    this.isLoading = false,
    this.error,
  });

  CaretakerState copyWith({
    List<Room>? assignedRooms,
    List<Alarm>? activeAlarms,
    bool? isLoading,
    String? error,
  }) {
    return CaretakerState(
      assignedRooms: assignedRooms ?? this.assignedRooms,
      activeAlarms: activeAlarms ?? this.activeAlarms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasActiveAlarms => activeAlarms.isNotEmpty;
  int get activeAlarmCount => activeAlarms.length;
}

class CaretakerNotifier extends StateNotifier<CaretakerState> {
  CaretakerNotifier() : super(const CaretakerState(isLoading: true)) {
    _initialize();
  }

  void _initialize() {
    _loadAssignedRooms();
    _loadActiveAlarms();
  }

  Future<void> _loadAssignedRooms() async {
    try {
      final response = await ApiService.getRooms();

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          assignedRooms: response.data!,
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load rooms',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadActiveAlarms() async {
    try {
      final response = await ApiService.getActiveAlarmsForCaretaker();

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(activeAlarms: response.data!);
      }
    } catch (e) {
      print('Error loading active alarms: $e');
    }
  }

  Future<void> acknowledgeAlarm(int alarmId) async {
    try {
      final response = await ApiService.acknowledgeAlarm(alarmId);

      if (response.isSuccess) {
        final updatedAlarms =
            state.activeAlarms.where((alarm) => alarm.id != alarmId).toList();

        state = state.copyWith(activeAlarms: updatedAlarms);
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to acknowledge alarm',
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> acknowledgeAllAlarms() async {
    final alarmIds = state.activeAlarms.map((a) => a.id).toList();

    for (final alarmId in alarmIds) {
      try {
        await ApiService.acknowledgeAlarm(alarmId);
      } catch (e) {
        print('Error acknowledging alarm $alarmId: $e');
      }
    }

    state = state.copyWith(activeAlarms: []);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final caretakerProvider =
    StateNotifierProvider<CaretakerNotifier, CaretakerState>((ref) {
  return CaretakerNotifier();
});
