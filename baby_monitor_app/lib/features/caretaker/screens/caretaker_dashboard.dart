import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../shared/models/app_user.dart';
import '../../shared/models/room_model.dart';
import '../../shared/models/alarm_model.dart';
import '../providers/caretaker_provider.dart';
import '../../auth/providers/auth_provider.dart';

class CaretakerDashboard extends ConsumerWidget {
  final AppUser user;

  const CaretakerDashboard({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caretakerState = ref.watch(caretakerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pengasuh'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          // Active alarms indicator
          if (caretakerState.activeAlarms.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_active),
                    onPressed: () => _showAlarmsBottomSheet(context, ref),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${caretakerState.activeAlarms.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authProvider.notifier).signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Keluar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(caretakerProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeCard(user),
              const Gap(24),

              // Active Alarms Section (Priority)
              if (caretakerState.activeAlarms.isNotEmpty) ...[
                _buildActiveAlarmsSection(caretakerState.activeAlarms, ref),
                const Gap(24),
              ],

              // Monitored Rooms Section
              _buildMonitoredRoomsSection(caretakerState.assignedRooms),
              const Gap(24),

              // Status Section
              _buildStatusSection(caretakerState),
              const Gap(24),

              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),

      // Floating alarm acknowledgment for active alarms
      floatingActionButton: caretakerState.activeAlarms.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _acknowledgeAllAlarms(ref),
              backgroundColor: Colors.green[600],
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Terima Semua',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildWelcomeCard(AppUser user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.baby_changing_station,
                color: Color(0xFF4CAF50),
                size: 32,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, ${user.name}!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(4),
                  const Text(
                    'Siap menerima panggilan dari orangtua',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAlarmsSection(List<Alarm> activeAlarms, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emergency, color: Colors.red, size: 24),
            const Gap(8),
            const Text(
              'Alarm Aktif',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${activeAlarms.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Gap(12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeAlarms.length,
          itemBuilder: (context, index) {
            final alarm = activeAlarms[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildAlarmNotification(alarm, ref),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlarmNotification(Alarm alarm, WidgetRef ref) {
    return Card(
      elevation: 4,
      color: Colors.red[50],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[400]!, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with room info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.emergency,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ALARM KAMAR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          alarm.room?.name ?? 'Kamar ${alarm.roomId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _getTimeAgo(alarm.triggeredAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Gap(16),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _acknowledgeAlarm(ref, alarm.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'TERIMA PANGGILAN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonitoredRoomsSection(List<Room> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kamar yang Dipantau',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(12),
        if (rooms.isEmpty)
          _buildNoRoomsCard()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _buildRoomCard(room);
            },
          ),
      ],
    );
  }

  Widget _buildNoRoomsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.home_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const Gap(16),
            const Text(
              'Belum ada kamar yang dipantau',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8),
            Text(
              'Hubungi admin untuk assign kamar yang akan Anda pantau',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.home,
              color: Colors.blue[600],
              size: 32,
            ),
          ),
          const Gap(12),
          Text(
            room.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(4),
          Text(
            '${room.caretakerIds.length} pengasuh',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(CaretakerState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Sistem',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            _buildStatusItem(
              'Koneksi',
              'Terhubung',
              Colors.green,
              Icons.wifi,
            ),
            const Gap(8),
            _buildStatusItem(
              'Notifikasi',
              'Aktif',
              Colors.green,
              Icons.notifications,
            ),
            const Gap(8),
            _buildStatusItem(
              'Alarm Audio',
              'Aktif',
              Colors.green,
              Icons.volume_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
      String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const Gap(8),
        Text('$label: '),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _testAlarm(),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Test Alarm'),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSettings(),
                    icon: const Icon(Icons.settings),
                    label: const Text('Pengaturan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m yang lalu';
    } else {
      return '${difference.inHours}h yang lalu';
    }
  }

  void _acknowledgeAlarm(WidgetRef ref, int alarmId) {
    ref.read(caretakerProvider.notifier).acknowledgeAlarm(alarmId);
  }

  void _acknowledgeAllAlarms(WidgetRef ref) {
    ref.read(caretakerProvider.notifier).acknowledgeAllAlarms();
  }

  void _showAlarmsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AlarmsBottomSheet(),
    );
  }

  void _testAlarm() {
    // Test alarm functionality
  }

  void _showSettings() {
    // Show settings
  }
}

class AlarmsBottomSheet extends ConsumerWidget {
  const AlarmsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAlarms = ref.watch(caretakerProvider).activeAlarms;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Alarm Aktif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          ListView.builder(
            shrinkWrap: true,
            itemCount: activeAlarms.length,
            itemBuilder: (context, index) {
              final alarm = activeAlarms[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.emergency, color: Colors.red),
                  title: Text(alarm.room?.name ?? 'Kamar ${alarm.roomId}'),
                  subtitle: Text('Dipicu ${_getTimeAgo(alarm.triggeredAt)}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(caretakerProvider.notifier)
                          .acknowledgeAlarm(alarm.id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Terima'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m yang lalu';
    } else {
      return '${difference.inHours}h yang lalu';
    }
  }
}
