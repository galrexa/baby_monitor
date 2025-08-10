import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../shared/models/room_model.dart';
import '../../shared/models/alarm_model.dart';

class ParentState {
  final List<Room> userRooms;
  final Room? selectedRoom;
  final Alarm? activeAlarm;
  final bool isLoading;
  final String? error;

  const ParentState({
    this.userRooms = const [],
    this.selectedRoom,
    this.activeAlarm,
    this.isLoading = false,
    this.error,
  });

  ParentState copyWith({
    List<Room>? userRooms,
    Room? selectedRoom,
    Alarm? activeAlarm,
    bool? isLoading,
    String? error,
  }) {
    return ParentState(
      userRooms: userRooms ?? this.userRooms,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      activeAlarm: activeAlarm ?? this.activeAlarm,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ParentNotifier extends StateNotifier<ParentState> {
  ParentNotifier() : super(const ParentState(isLoading: true)) {
    _initialize();
  }

  void _initialize() {
    _loadUserRooms();
  }

  Future<void> _loadUserRooms() async {
    try {
      final response = await ApiService.getRooms();

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(
          userRooms: response.data!,
          isLoading: false,
          error: null,
        );

        // Auto-select first room if available
        if (response.data!.isNotEmpty && state.selectedRoom == null) {
          selectRoom(response.data!.first);
        }
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

  void selectRoom(Room room) {
    state = state.copyWith(selectedRoom: room);
    _checkActiveAlarm(room.id);
  }

  Future<void> _checkActiveAlarm(int roomId) async {
    try {
      final response = await ApiService.getAlarms(status: 'active');

      if (response.isSuccess && response.data != null) {
        final activeAlarms =
            response.data!.where((alarm) => alarm.roomId == roomId).toList();

        state = state.copyWith(
          activeAlarm: activeAlarms.isNotEmpty ? activeAlarms.first : null,
        );
      }
    } catch (e) {
      print('Error checking active alarm: $e');
    }
  }

  Future<void> triggerAlarm() async {
    if (state.selectedRoom == null) {
      state = state.copyWith(error: 'Pilih kamar terlebih dahulu');
      return;
    }

    try {
      final response = await ApiService.triggerAlarm(state.selectedRoom!.id);

      if (response.isSuccess && response.data != null) {
        state = state.copyWith(activeAlarm: response.data);
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to trigger alarm',
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resetAlarm() async {
    // For now, we'll simulate reset by setting activeAlarm to null
    // In real implementation, this would call API to reset alarm
    state = state.copyWith(activeAlarm: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final parentProvider =
    StateNotifierProvider<ParentNotifier, ParentState>((ref) {
  return ParentNotifier();
});
