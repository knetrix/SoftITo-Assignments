import 'package:flutter/foundation.dart';

/// Prototiplerdeki 24×24 çizgi simgelerin SVG işaretlemesi (birebir).
///
/// `AppIcon` bu işaretlemeyi bir kez ayrıştırıp `Path` olarak önbelleğe alır;
/// harici simge ya da SVG paketi gerekmez.
@immutable
class AppIconData {
  final String markup;

  const AppIconData(this.markup);
}

abstract final class AppIcons {
  static const AppIconData sun = AppIconData(
    '<path d="M12 3v2M12 19v2M5 12H3M21 12h-2M6.3 6.3 4.9 4.9M19.1 19.1l-1.4-1.4M6.3 17.7l-1.4 1.4M19.1 4.9l-1.4 1.4"/><circle cx="12" cy="12" r="4"/>',
  );
  static const AppIconData grid = AppIconData(
    '<rect x="3.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="3.5" y="13.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="13.5" width="7" height="7" rx="1.5"/>',
  );
  static const AppIconData chart = AppIconData('<path d="M4 20V10M10 20V4M16 20v-7M21 20H3"/>');
  static const AppIconData lock = AppIconData(
    '<rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>',
  );
  static const AppIconData unlock = AppIconData(
    '<rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 7.5-2"/>',
  );
  static const AppIconData check = AppIconData('<path d="m5 12.5 4.5 4.5L19 7.5"/>');
  static const AppIconData left = AppIconData('<path d="m15 18-6-6 6-6"/>');
  static const AppIconData right = AppIconData('<path d="m9 18 6-6-6-6"/>');
  static const AppIconData close = AppIconData('<path d="M6 6l12 12M18 6 6 18"/>');
  static const AppIconData shield = AppIconData('<path d="M12 3 5 6v5c0 4.5 3 8 7 10 4-2 7-5.5 7-10V6l-7-3z"/>');
  static const AppIconData dot = AppIconData('<circle cx="12" cy="12" r="1.2"/>');
  static const AppIconData gear = AppIconData(
    '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/>',
  );
  static const AppIconData backspace = AppIconData(
    '<path d="M21 5H9l-6 7 6 7h12a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1z"/><path d="m16 9-5 6M11 9l5 6"/>',
  );
  static const AppIconData alert = AppIconData('<circle cx="12" cy="12" r="9"/><path d="M12 7.5v5M12 16h.01"/>');
  static const AppIconData back = AppIconData('<path d="m15 18-6-6 6-6"/>');
  static const AppIconData arrowBack = AppIconData('<path d="M19 12H5M11 18l-6-6 6-6"/>');
  static const AppIconData chevron = AppIconData('<path d="m9 18 6-6-6-6"/>');
  static const AppIconData chip = AppIconData(
    '<rect x="5" y="5" width="14" height="14" rx="3"/><path d="M9 2v3M15 2v3M9 19v3M15 19v3M2 9h3M2 15h3M19 9h3M19 15h3"/>',
  );
  static const AppIconData fingerprint = AppIconData(
    '<path d="M12 11v3.5a6 6 0 0 1-1.2 3.6"/><path d="M8.5 10.5a3.5 3.5 0 0 1 7 0V13a10 10 0 0 1-.6 3.5"/><path d="M5.5 9.5a6.5 6.5 0 0 1 13 0V12M5.5 13v-1M7 19.5a9 9 0 0 0 1.5-4.5"/><path d="M17.5 18.5c.4-.9.7-1.9.9-3"/>',
  );
  static const AppIconData key = AppIconData(
    '<circle cx="8" cy="15" r="4"/><path d="m10.8 12.2 8.2-8.2M17 6l2 2M14.5 8.5l2 2"/>',
  );
  static const AppIconData bell = AppIconData(
    '<path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/>',
  );
  static const AppIconData theme = AppIconData(
    '<circle cx="12" cy="12" r="9"/><path d="M12 3a9 9 0 0 0 0 18z" fill="currentColor"/>',
  );
  static const AppIconData info = AppIconData('<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>');
  static const AppIconData restore = AppIconData('<path d="M3 12a9 9 0 1 0 2.6-6.4L3 8"/><path d="M3 3v5h5"/>');
}
