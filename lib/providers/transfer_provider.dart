import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transfer_state.dart';
import '../services/transfer_service.dart';

/// Transfer service provider
final transferServiceProvider = Provider<TransferService>((ref) {
  final service = TransferService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream provider for transfer states
final transferStateStreamProvider = StreamProvider<TransferState>((ref) {
  final service = ref.watch(transferServiceProvider);
  return service.transferStateStream;
});

/// Active transfers provider
class ActiveTransfersNotifier extends StateNotifier<List<TransferState>> {
  ActiveTransfersNotifier() : super([]);

  void addTransfer(TransferState transfer) {
    state = [...state, transfer];
  }

  void updateTransfer(TransferState transfer) {
    state = [
      for (final t in state)
        if (t.id == transfer.id) transfer else t,
    ];
  }

  void removeTransfer(String transferId) {
    state = state.where((t) => t.id != transferId).toList();
  }

  void clearCompleted() {
    state = state.where((t) => 
      t.status != TransferStatus.finished && 
      t.status != TransferStatus.failed &&
      t.status != TransferStatus.cancelled
    ).toList();
  }
}

final activeTransfersProvider = StateNotifierProvider<ActiveTransfersNotifier, List<TransferState>>((ref) {
  final notifier = ActiveTransfersNotifier();
  
  // Listen to transfer state stream and update active transfers
  ref.listen<AsyncValue<TransferState>>(
    transferStateStreamProvider,
    (previous, next) {
      next.whenData((transfer) {
        final existing = notifier.state.any((t) => t.id == transfer.id);
        if (existing) {
          notifier.updateTransfer(transfer);
        } else {
          notifier.addTransfer(transfer);
        }
      });
    },
  );
  
  return notifier;
});
