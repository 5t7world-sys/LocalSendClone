import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_history_tile.dart';

/// History screen showing past transfers
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(activeTransfersProvider);
    final completedTransfers = transfers.where((t) => 
      t.status.toString().contains('finished') ||
      t.status.toString().contains('failed') ||
      t.status.toString().contains('cancelled')
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (completedTransfers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear history',
              onPressed: () {
                _showClearHistoryDialog(context, ref);
              },
            ),
        ],
      ),
      body: completedTransfers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transfer history',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your completed transfers will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: completedTransfers.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final transfer = completedTransfers[completedTransfers.length - 1 - index];
                return TransferHistoryTile(transfer: transfer);
              },
            ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all transfer history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(activeTransfersProvider.notifier).clearCompleted();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
