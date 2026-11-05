import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/transfer_state.dart';

/// Transfer history tile widget
class TransferHistoryTile extends StatelessWidget {
  final TransferState transfer;

  const TransferHistoryTile({
    super.key,
    required this.transfer,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = transfer.status.toString().contains('finished');
    final isFailed = transfer.status.toString().contains('failed');
    final isCancelled = transfer.status.toString().contains('cancelled');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(context),
          child: Icon(
            _getStatusIcon(),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          transfer.direction.toString().contains('send') ? 'Sent to' : 'Received from',
          style: const TextStyle(fontSize: 13),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              transfer.device.alias,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${transfer.files.length} file${transfer.files.length != 1 ? 's' : ''} • ${_formatBytes(transfer.totalBytes ?? 0)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              timeago.format(transfer.startTime),
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildStatusBadge(context),
            if (transfer.endTime != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDuration(transfer.endTime!.difference(transfer.startTime)),
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Files:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...transfer.files.map((file) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          file.fileName,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        file.sizeString,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                )),
                if (isFailed && transfer.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            transfer.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isFailed)
                      TextButton.icon(
                        onPressed: () {
                          // Retry transfer
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    if (isSuccess && transfer.direction.toString().contains('receive'))
                      TextButton.icon(
                        onPressed: () {
                          // Open folder
                        },
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Open Folder'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    String text;
    Color color;

    if (transfer.status.toString().contains('finished')) {
      text = 'Success';
      color = Colors.green;
    } else if (transfer.status.toString().contains('failed')) {
      text = 'Failed';
      color = Colors.red;
    } else if (transfer.status.toString().contains('cancelled')) {
      text = 'Cancelled';
      color = Colors.orange;
    } else {
      text = 'Unknown';
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    if (transfer.status.toString().contains('finished')) {
      return Colors.green;
    } else if (transfer.status.toString().contains('failed')) {
      return Colors.red;
    } else if (transfer.status.toString().contains('cancelled')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  IconData _getStatusIcon() {
    if (transfer.status.toString().contains('finished')) {
      return Icons.check;
    } else if (transfer.status.toString().contains('failed')) {
      return Icons.close;
    } else if (transfer.status.toString().contains('cancelled')) {
      return Icons.block;
    }
    return Icons.help_outline;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1000) return '$bytes B';
    if (bytes < 1000000) return '${(bytes / 1000).toStringAsFixed(1)} KB';
    if (bytes < 1000000000) return '${(bytes / 1000000).toStringAsFixed(1)} MB';
    return '${(bytes / 1000000000).toStringAsFixed(2)} GB';
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m ${seconds % 60}s';
    return '${seconds ~/ 3600}h ${(seconds % 3600) ~/ 60}m';
  }
}
