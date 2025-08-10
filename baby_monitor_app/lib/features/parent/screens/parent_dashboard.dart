import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../shared/models/app_user.dart';
import '../../shared/models/room_model.dart';
import '../../shared/models/alarm_model.dart';
import '../providers/parent_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ParentDashboard extends ConsumerStatefulWidget {
  final AppUser user;

  const ParentDashboard({super.key, required this.user});

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  @override
  Widget build(BuildContext context) {
    final parentState = ref.watch(parentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Orangtua'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
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
          ref.invalidate(parentProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeCard(widget.user),
              const Gap(24),

              // Room Selection Section
              _buildRoomSection(parentState),
              const Gap(24),

              // Main Alarm Section
              if (parentState.selectedRoom != null) ...[
                _buildAlarmSection(parentState),
                const Gap(24),
              ],

              // Status Section
              _buildStatusSection(),
              const Gap(24),

              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
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
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.family_restroom,
                color: Color(0xFF2196F3),
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
                    'Tekan tombol alarm untuk memanggil pengasuh',
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

  Widget _buildRoomSection(ParentState parentState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Kamar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(12),
        if (parentState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (parentState.userRooms.isEmpty)
          _buildNoRoomsCard()
        else
          _buildRoomsList(parentState.userRooms, parentState.selectedRoom),
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
              'Belum ada kamar tersedia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8),
            Text(
              'Hubungi admin untuk menambahkan kamar dan mengassign pengasuh',
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

  Widget _buildRoomsList(List<Room> rooms, Room? selectedRoom) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        final isSelected = selectedRoom?.id == room.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              ref.read(parentProvider.notifier).selectRoom(room);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[50] : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[100] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.home,
                      color: isSelected ? Colors.blue[600] : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected ? Colors.blue[700] : Colors.black87,
                          ),
                        ),
                        if (room.description.isNotEmpty) ...[
                          const Gap(2),
                          Text(
                            room.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const Gap(4),
                        Text(
                          '${room.caretakerIds.length} pengasuh assigned',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlarmSection(ParentState parentState) {
    final selectedRoom = parentState.selectedRoom;
    final activeAlarm = parentState.activeAlarm;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Kamar: ${selectedRoom!.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'Pengasuh: ${selectedRoom.caretakerIds.length} orang',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const Gap(24),

            // Main Alarm Button
            GestureDetector(
              onTap: () {
                if (activeAlarm != null) {
                  ref.read(parentProvider.notifier).resetAlarm();
                } else {
                  ref.read(parentProvider.notifier).triggerAlarm();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: activeAlarm != null
                        ? [Colors.red[400]!, Colors.red[600]!, Colors.red[800]!]
                        : [
                            const Color(0xFFE53935),
                            const Color(0xFFD32F2F),
                            const Color(0xFFB71C1C)
                          ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeAlarm != null
                          ? Colors.red.withOpacity(0.4)
                          : Colors.black.withOpacity(0.3),
                      blurRadius: activeAlarm != null ? 20 : 15,
                      spreadRadius: activeAlarm != null ? 5 : 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      activeAlarm != null ? Icons.stop : Icons.emergency,
                      size: 48,
                      color: Colors.white,
                    ),
                    const Gap(8),
                    Text(
                      activeAlarm != null ? 'STOP' : 'ALARM',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (activeAlarm != null) ...[
              const Gap(16),
              _buildAlarmStatus(activeAlarm),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmStatus(Alarm alarm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alarm.isAcknowledged ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              alarm.isAcknowledged ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            alarm.isAcknowledged ? Icons.check_circle : Icons.access_time,
            color:
                alarm.isAcknowledged ? Colors.green[600] : Colors.orange[600],
            size: 32,
          ),
          const Gap(8),
          Text(
            alarm.isAcknowledged ? 'Panggilan Diterima!' : 'Menunggu Respon...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  alarm.isAcknowledged ? Colors.green[600] : Colors.orange[600],
            ),
          ),
          const Gap(4),
          Text(
            alarm.isAcknowledged
                ? 'Pengasuh telah menerima panggilan'
                : 'Alarm sedang berbunyi di perangkat pengasuh',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Koneksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(8),
                const Text('Terhubung ke server'),
              ],
            ),
          ],
        ),
      ),
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
                    onPressed: () {
                      // Show alarm history
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Riwayat'),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Show settings
                    },
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
}
