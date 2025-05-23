import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../screen/detail_event_screen.dart';
import '../utils/date_utils.dart' as date_util;
import '../utils/url_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/media_viewer.dart';
import '../utils/event_utils.dart';
import '../screen/event_screen.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final ThemeState themeState;

  const EventCard({
    Key? key,
    required this.event,
    required this.themeState,
  }) : super(key: key);

  String getEventStatus(String? timestart, String? timeend) {
    if (timestart == null || timeend == null) return 'Không xác định';
    final now = DateTime.now();
    final start = DateTime.tryParse(timestart);
    final end = DateTime.tryParse(timeend);
    if (start == null || end == null) return 'Không xác định';

    if (now.isBefore(start)) {
      return 'Sắp diễn ra';
    } else if (now.isAfter(end)) {
      return 'Đã diễn ra';
    } else {
      return 'Đang diễn ra';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = getEventStatus(
        event.startTime.toIso8601String(), event.endTime.toIso8601String());
    Color statusColor;
    switch (status) {
      case 'Đã diễn ra':
        statusColor = Colors.red;
        break;
      case 'Đang diễn ra':
        statusColor = Colors.green;
        break;
      case 'Sắp diễn ra':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = themeState.secondaryTextColor;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(eventId: event.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: themeState.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: themeState.primaryColor.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 140,
              width: 120,
              child: MediaViewer(
                resources: event.resourcesData,
                height: 140,
                borderRadius: 12,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: themeState.primaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: themeState.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style:
                                TextStyle(color: themeState.secondaryTextColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: themeState.secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date_util
                              .formatDate(event.startTime.toIso8601String()),
                          style:
                              TextStyle(color: themeState.secondaryTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
