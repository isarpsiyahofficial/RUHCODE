import 'package:flutter/material.dart';

import '../../calculation_core/time/civil_calendar.dart';
import '../../content/daily_messages/daily_message_catalog.dart';

typedef DailyMessageClock = DateTime Function();

class DailyMessageTodayPage extends StatelessWidget {
  const DailyMessageTodayPage({
    super.key,
    required this.catalog,
    this.clock,
  });

  final DailyMessageCatalog catalog;
  final DailyMessageClock? clock;

  @override
  Widget build(BuildContext context) {
    final now = (clock ?? DateTime.now)();
    final date = CivilDate(now.year, now.month, now.day);
    final languageCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final localeTag = languageCode == 'tr' ? 'tr' : 'en';
    final entry = catalog.find(date: date, localeTag: localeTag);

    if (entry == null) {
      final message = localeTag == 'tr'
          ? 'Bugünün mesajı bu tarih için kullanılamıyor.'
          : "Today's message is unavailable for this date.";
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Semantics(
            liveRegion: true,
            label: message,
            child: Text(
              message,
              key: const ValueKey('daily-message-missing'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    return ListView(
      key: const ValueKey('daily-message-today'),
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          localeTag == 'tr' ? 'Günün Mesajı' : 'Message of the Day',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          date.isoKey,
          key: const ValueKey('daily-message-date'),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            entry.title,
            key: const ValueKey('daily-message-title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          entry.teaser,
          key: const ValueKey('daily-message-teaser'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Text(
          entry.fullText,
          key: const ValueKey('daily-message-full-text'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
