import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/device_provider.dart';

class RoomSelector extends ConsumerWidget {
  const RoomSelector({super.key});

  static const List<String> rooms = [
    'All Rooms',
    'Living Room',
    'Master Suite',
    'Kitchen',
    'Home Office',
    'Solar Garage',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRoom = ref.watch(selectedRoomProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: rooms.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final room = rooms[index];
          final isSelected = room == selectedRoom;

          return ChoiceChip(
            showCheckmark: false,
            label: Text(room),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            selected: isSelected,
            selectedColor: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainer,
            side: BorderSide(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) {
              ref.read(selectedRoomProvider.notifier).state = room;
            },
          );
        },
      ),
    );
  }
}
