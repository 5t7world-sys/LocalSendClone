import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/device.dart';

/// Device list tile widget
class DeviceListTile extends StatelessWidget {
  final Device device;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const DeviceListTile({
    super.key,
    required this.device,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _getDeviceIcon(),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.alias,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isFavorite)
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${device.ip}:${device.port}',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (device.deviceModel != null) ...[
              const SizedBox(height: 2),
              Text(
                device.deviceModel!,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
            const SizedBox(height: 2),
            Text(
              'Discovered ${timeago.format(device.discoveredAt, locale: 'en_short')}',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (device.https)
              Icon(
                Icons.lock,
                size: 16,
                color: Colors.green,
              ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : null,
              ),
              onPressed: onFavoriteToggle,
              tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getDeviceIcon() {
    switch (device.deviceType?.toLowerCase()) {
      case 'mobile':
        return Icons.smartphone;
      case 'tablet':
        return Icons.tablet;
      case 'desktop':
        return Icons.computer;
      case 'laptop':
        return Icons.laptop;
      default:
        return Icons.devices;
    }
  }
}
