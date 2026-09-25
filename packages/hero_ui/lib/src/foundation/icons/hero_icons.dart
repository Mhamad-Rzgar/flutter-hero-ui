// Icon path data from HeroUI (Apache-2.0) and Gravity UI Icons (MIT,
// Copyright (c) 2022 YANDEX LLC). See THIRD_PARTY_NOTICES.md.

import 'hero_icon.dart';

/// The icon set used by hero_ui components and examples.
///
/// The first group reproduces the icons HeroUI renders inside its own
/// components (`icons.tsx`); the rest are Gravity UI icons, the icon family
/// used throughout HeroUI's documentation. All icons are 16 × 16 and paint
/// with the current color.
abstract final class HeroIcons {
  /// HeroUI chevron pointing down (select and accordion indicators).
  static const HeroIconData chevronDown = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M2.97 5.47a.75.75 0 0 1 1.06 0L8 9.44l3.97-3.97a.75.75 0 1 1 1.06 1.06l-4.5 4.5a.75.75 0 0 1-1.06 0l-4.5-4.5a.75.75 0 0 1 0-1.06',
      evenOdd: true,
    ),
  ]);

  /// HeroUI chevron pointing up.
  static const HeroIconData chevronUp = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.03 10.53a.75.75 0 0 1-1.06 0L8 6.56l-3.97 3.97a.75.75 0 0 1-1.06-1.06l4.5-4.5a.75.75 0 0 1 1.06 0l4.5 4.5a.75.75 0 0 1 0 1.06',
      evenOdd: true,
    ),
  ]);

  /// HeroUI chevron pointing left (mirrors in RTL).
  static const HeroIconData chevronLeft = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10.53 2.97a.75.75 0 0 1 0 1.06L6.56 8l3.97 3.97a.75.75 0 1 1-1.06 1.06l-4.5-4.5a.75.75 0 0 1 0-1.06l4.5-4.5a.75.75 0 0 1 1.06 0',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// HeroUI chevron pointing right (mirrors in RTL).
  static const HeroIconData chevronRight = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5.47 2.97a.75.75 0 0 1 1.06 0l4.5 4.5a.75.75 0 0 1 0 1.06l-4.5 4.5a.75.75 0 1 1-1.06-1.06L9.44 8 5.47 4.03a.75.75 0 0 1 0-1.06Z',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// HeroUI external-link arrow shown by links (7 × 7 view box).
  static const HeroIconData externalLink = HeroIconData(
    <HeroIconPath>[
      HeroIconPath(
        'M1.20592 6.84333L0.379822 6.01723L4.52594 1.8672H1.37819L1.38601 0.731812H6.48742V5.83714H5.34421L5.35203 2.6933L1.20592 6.84333Z',
      ),
    ],
    viewBoxWidth: 7,
    viewBoxHeight: 7,
    matchTextDirection: true,
  );

  /// HeroUI dashed circle.
  static const HeroIconData circleDashed = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M6.906 1.085a7.047 7.047 0 0 1 2.188 0 .75.75 0 0 1-.232 1.482 5.546 5.546 0 0 0-1.724 0 .75.75 0 0 1-.232-1.482ZM4.933 2.502a.75.75 0 0 1-.166 1.048c-.466.34-.878.75-1.217 1.217a.75.75 0 0 1-1.213-.882 7.036 7.036 0 0 1 1.548-1.548.75.75 0 0 1 1.048.165Zm6.135 0a.75.75 0 0 1 1.047-.165 7.037 7.037 0 0 1 1.548 1.548.75.75 0 0 1-1.213.882 5.533 5.533 0 0 0-1.217-1.217.75.75 0 0 1-.165-1.048ZM1.943 6.28a.75.75 0 0 1 .624.857 5.546 5.546 0 0 0 0 1.724.75.75 0 0 1-1.482.232 7.047 7.047 0 0 1 0-2.188.75.75 0 0 1 .858-.625Zm12.114 0a.75.75 0 0 1 .858.625 7.048 7.048 0 0 1 0 2.188.75.75 0 1 1-1.482-.232 5.54 5.54 0 0 0 0-1.724.75.75 0 0 1 .624-.857ZM2.502 11.068a.75.75 0 0 1 1.048.165c.34.466.75.878 1.217 1.217a.75.75 0 0 1-.882 1.213 7.037 7.037 0 0 1-1.548-1.548.75.75 0 0 1 .165-1.047Zm10.996 0a.75.75 0 0 1 .165 1.047 7.037 7.037 0 0 1-1.548 1.548.75.75 0 0 1-.883-1.213 5.53 5.53 0 0 0 1.218-1.217.75.75 0 0 1 1.048-.165Zm-7.217 2.99a.75.75 0 0 1 .857-.625 5.54 5.54 0 0 0 1.724 0 .75.75 0 0 1 .232 1.482 7.048 7.048 0 0 1-2.188 0 .75.75 0 0 1-.625-.857Z',
    ),
  ]);

  /// HeroUI close (×) icon used by close buttons.
  static const HeroIconData close = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.47 3.47a.75.75 0 0 1 1.06 0L8 6.94l3.47-3.47a.75.75 0 1 1 1.06 1.06L9.06 8l3.47 3.47a.75.75 0 1 1-1.06 1.06L8 9.06l-3.47 3.47a.75.75 0 0 1-1.06-1.06L6.94 8 3.47 4.53a.75.75 0 0 1 0-1.06Z',
      evenOdd: true,
    ),
  ]);

  /// HeroUI info status icon (Alert, Toast).
  static const HeroIconData info = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 13.5a5.5 5.5 0 1 0 0-11a5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m1-9.5a1 1 0 1 1-2 0a1 1 0 0 1 2 0m-.25 3a.75.75 0 0 0-1.5 0V11a.75.75 0 0 0 1.5 0z',
      evenOdd: true,
    ),
  ]);

  /// HeroUI warning status icon (Alert, Toast).
  static const HeroIconData warning = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7.134 2.994L2.217 11.5a1 1 0 0 0 .866 1.5h9.834a1 1 0 0 0 .866-1.5L8.866 2.993a1 1 0 0 0-1.732 0m3.03-.75c-.962-1.665-3.366-1.665-4.329 0L.918 10.749c-.963 1.666.24 3.751 2.165 3.751h9.834c1.925 0 3.128-2.085 2.164-3.751zM8 5a.75.75 0 0 1 .75.75v2a.75.75 0 0 1-1.5 0v-2A.75.75 0 0 1 8 5m1 5.75a1 1 0 1 1-2 0a1 1 0 0 1 2 0',
      evenOdd: true,
    ),
  ]);

  /// HeroUI danger status icon (Alert, Toast).
  static const HeroIconData danger = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 13.5a5.5 5.5 0 1 0 0-11a5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m1-4.5a1 1 0 1 1-2 0a1 1 0 0 1 2 0M8.75 5a.75.75 0 0 0-1.5 0v2.5a.75.75 0 0 0 1.5 0z',
      evenOdd: true,
    ),
  ]);

  /// HeroUI success status icon (Alert, Toast).
  static const HeroIconData success = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 8a5.5 5.5 0 1 1-11 0a5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0m-3.9-1.55a.75.75 0 1 0-1.2-.9L7.419 8.858L6.03 7.47a.75.75 0 0 0-1.06 1.06l2 2a.75.75 0 0 0 1.13-.08z',
      evenOdd: true,
    ),
  ]);

  /// HeroUI minus icon (NumberField decrement).
  static const HeroIconData minusSign = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.75 8a.75.75 0 0 1 .75-.75h11a.75.75 0 0 1 0 1.5h-11A.75.75 0 0 1 1.75 8',
      evenOdd: true,
    ),
  ]);

  /// HeroUI plus icon (NumberField increment).
  static const HeroIconData plusSign = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 1.75a.75.75 0 0 1 .75.75v4.75h4.75a.75.75 0 0 1 0 1.5H8.75v4.75a.75.75 0 0 1-1.5 0V8.75H2.5a.75.75 0 0 1 0-1.5h4.75V2.5A.75.75 0 0 1 8 1.75',
      evenOdd: true,
    ),
  ]);

  /// HeroUI search icon (SearchField).
  static const HeroIconData search = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.5 7a4.5 4.5 0 1 1-9 0a4.5 4.5 0 0 1 9 0m-.82 4.74a6 6 0 1 1 1.06-1.06l2.79 2.79a.75.75 0 1 1-1.06 1.06z',
      evenOdd: true,
    ),
  ]);

  /// HeroUI calendar icon used by date pickers (13 × 14 view box).
  static const HeroIconData calendarPicker = HeroIconData(
    <HeroIconPath>[
      HeroIconPath(
        'M3.75 4.5A.75.75 0 0 1 3 3.75v-.748a1.5 1.5 0 0 0-1.5 1.5v1h10v-1a1.5 1.5 0 0 0-1.5-1.5v.75a.75.75 0 1 1-1.5 0v-.75h-4v.747a.75.75 0 0 1-.75.75ZM8.5 1.501h-4V.75a.75.75 0 0 0-1.5 0v.752a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h7a3 3 0 0 0 3-3v-6a3 3 0 0 0-3-3v-.75a.75.75 0 0 0-1.5 0v.75Zm-7 5.5v3.5a1.5 1.5 0 0 0 1.5 1.5h7a1.5 1.5 0 0 0 1.5-1.5v-3.5h-10Z',
        evenOdd: true,
      ),
    ],
    viewBoxWidth: 13,
    viewBoxHeight: 14,
  );

  /// Gravity UI `arrow-right` icon.
  static const HeroIconData arrowRight = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.25 8A.75.75 0 0 1 2 7.25h10.19L9.47 4.53a.75.75 0 0 1 1.06-1.06l4 4a.75.75 0 0 1 0 1.06l-4 4a.75.75 0 1 1-1.06-1.06l2.72-2.72H2A.75.75 0 0 1 1.25 8',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `arrow-right-from-square` icon.
  static const HeroIconData arrowRightFromSquare = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M14.78 7.47a.75.75 0 0 1 0 1.06l-2.5 2.5a.75.75 0 1 1-1.06-1.06l1.22-1.22H4.75a.75.75 0 0 1 0-1.5h7.69l-1.22-1.22a.75.75 0 0 1 1.06-1.06zM9.5 4.25a.75.75 0 0 1-1.5 0V4a1.5 1.5 0 0 0-1.5-1.5H4A1.5 1.5 0 0 0 2.5 4v8A1.5 1.5 0 0 0 4 13.5h2.5A1.5 1.5 0 0 0 8 12v-.25a.75.75 0 0 1 1.5 0V12a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3V4a3 3 0 0 1 3-3h2.5a3 3 0 0 1 3 3z',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `arrow-up` icon.
  static const HeroIconData arrowUp = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 14.75a.75.75 0 0 1-.75-.75V3.81L4.53 6.53a.75.75 0 0 1-1.06-1.06l4-4a.75.75 0 0 1 1.06 0l4 4a.75.75 0 0 1-1.06 1.06L8.75 3.81V14a.75.75 0 0 1-.75.75',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `arrow-up-from-line` icon.
  static const HeroIconData arrowUpFromLine = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7.47 1.22a.75.75 0 0 1 1.06 0l2.5 2.5a.75.75 0 1 1-1.06 1.06L8.75 3.56v7.69a.75.75 0 0 1-1.5 0V3.56L6.03 4.78a.75.75 0 0 1-1.06-1.06zM1.75 13.5a.75.75 0 0 0 0 1.5h12.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `arrow-up-right-from-square` icon.
  static const HeroIconData
  arrowUpRightFromSquare = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10 1.5A.75.75 0 0 0 10 3h1.94L6.97 7.97a.75.75 0 0 0 1.06 1.06L13 4.06V6a.75.75 0 0 0 1.5 0V2.25a.75.75 0 0 0-.75-.75zM7.5 3.25a.75.75 0 0 0-.75-.75H4.5a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h6a3 3 0 0 0 3-3V9.25a.75.75 0 0 0-1.5 0v2.25a1.5 1.5 0 0 1-1.5 1.5h-6A1.5 1.5 0 0 1 3 11.5v-6A1.5 1.5 0 0 1 4.5 4h2.25a.75.75 0 0 0 .75-.75',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `arrow-uturn-ccw-left` icon.
  static const HeroIconData arrowUturnCcwLeft = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M2.47 4.72a.75.75 0 0 0 0 1.06l3 3a.75.75 0 0 0 1.06-1.06L4.81 6H9a3.25 3.25 0 0 1 0 6.5H8A.75.75 0 0 0 8 14h1a4.75 4.75 0 1 0 0-9.5H4.81l1.72-1.72a.75.75 0 0 0-1.06-1.06z',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `arrow-uturn-cw-right` icon.
  static const HeroIconData arrowUturnCwRight = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.53 4.72a.75.75 0 0 1 0 1.06l-3 3a.75.75 0 1 1-1.06-1.06L11.19 6H7a3.25 3.25 0 0 0 0 6.5h1A.75.75 0 0 1 8 14H7a4.75 4.75 0 1 1 0-9.5h4.19L9.47 2.78a.75.75 0 0 1 1.06-1.06z',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `arrows-rotate-left` icon.
  static const HeroIconData arrowsRotateLeft = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 1.5a6.5 6.5 0 0 1 6.445 5.649.75.75 0 1 1-1.488.194A5.001 5.001 0 0 0 4.43 4.5h1.32a.75.75 0 0 1 0 1.5h-3A.75.75 0 0 1 2 5.25v-3a.75.75 0 1 1 1.5 0v1.06A6.48 6.48 0 0 1 8 1.5m5.25 13a.75.75 0 0 0 .75-.75v-3a.75.75 0 0 0-.75-.75h-3a.75.75 0 1 0 0 1.5h1.32a5.001 5.001 0 0 1-8.528-2.843.75.75 0 1 0-1.487.194 6.501 6.501 0 0 0 10.945 3.84v1.059c0 .414.336.75.75.75',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `at` icon.
  static const HeroIconData at = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.18 6.423A7 7 0 1 1 14.808 9.62a2.499 2.499 0 0 1-4.403.92 3.5 3.5 0 1 1 1.005-1.753 1 1 0 0 0 1.949.452l.056-.277a5.5 5.5 0 1 0-2.938 3.949.75.75 0 0 1 .677 1.339A7 7 0 0 1 1.18 6.423m7.27-.371a2 2 0 1 0-.9 3.897 2 2 0 0 0 .9-3.897',
    ),
  ]);

  /// Gravity UI `ban` icon.
  static const HeroIconData ban = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.323 12.383a5.5 5.5 0 0 1-7.706-7.706zm1.06-1.06L4.677 3.617a5.5 5.5 0 0 1 7.706 7.706M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `bars` icon.
  static const HeroIconData bars = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.25 3.25A.75.75 0 0 1 2 2.5h12A.75.75 0 0 1 14 4H2a.75.75 0 0 1-.75-.75m0 4.75A.75.75 0 0 1 2 7.25h12a.75.75 0 0 1 0 1.5H2A.75.75 0 0 1 1.25 8M2 12a.75.75 0 0 0 0 1.5h12a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `bell` icon.
  static const HeroIconData bell = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm4.665 7.822.62-3.096a2.77 2.77 0 0 1 5.43 0l.62 3.096a4.8 4.8 0 0 0 1.305 2.44l.194.193a.567.567 0 0 1-.273.953l-.821.19a16.6 16.6 0 0 1-7.48 0l-.82-.19a.567.567 0 0 1-.274-.953l.194-.193a4.77 4.77 0 0 0 1.305-2.44m-1.47-.294.619-3.096a4.27 4.27 0 0 1 8.372 0l.62 3.096c.126.634.438 1.216.895 1.673l.194.194a2.066 2.066 0 0 1-.997 3.475l-.821.19q-1.053.24-2.12.358a2 2 0 0 1-3.913 0 18 18 0 0 1-2.12-.359l-.822-.19a2.067 2.067 0 0 1-.997-3.474L2.3 9.2c.457-.457.769-1.04.895-1.673',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `bell-fill` icon.
  static const HeroIconData bellFill = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M9.955 13.416a2 2 0 0 1-3.911 0c1.3.141 2.611.141 3.911 0M8 1a4.27 4.27 0 0 1 4.187 3.432l.619 3.096c.127.634.438 1.216.895 1.673l.436.436a1.24 1.24 0 0 1-.598 2.085l-1.462.338a18.1 18.1 0 0 1-8.154 0l-1.462-.338a1.24 1.24 0 0 1-.598-2.085L2.3 9.2a3.27 3.27 0 0 0 .895-1.673l.62-3.096A4.27 4.27 0 0 1 8 1',
    ),
  ]);

  /// Gravity UI `bell-slash` icon.
  static const HeroIconData bellSlash = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.74 4.8 1.97 3.03a.75.75 0 0 1 1.06-1.06l11 11a.75.75 0 1 1-1.06 1.06l-.957-.956q-1.021.231-2.057.344a2 2 0 0 1-3.912 0 18 18 0 0 1-2.12-.359l-.822-.19a2.067 2.067 0 0 1-.997-3.474L2.3 9.2c.457-.457.769-1.04.895-1.673zm6.996 6.997a16.6 16.6 0 0 1-6.476-.2l-.82-.189a.567.567 0 0 1-.274-.953l.194-.193a4.77 4.77 0 0 0 1.305-2.44l.35-1.747zm.599-3.975q.042.21.101.412l3.025 3.024a2.07 2.07 0 0 0-.566-1.863L13.7 9.2a3.27 3.27 0 0 1-.895-1.673l-.62-3.096a4.27 4.27 0 0 0-6.96-2.408L6.292 3.09a2.77 2.77 0 0 1 4.424 1.637z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `bold` icon.
  static const HeroIconData bold = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4.25 2.25A.75.75 0 0 0 3.5 3v10c0 .414.336.75.75.75H9.5a3.25 3.25 0 0 0 1.477-6.146A3.25 3.25 0 0 0 8.5 2.25zm3.5 5a1.75 1.75 0 1 0 0-3.5h-2v3.5zm-2 1.5v3.5h3a1.75 1.75 0 1 0 0-3.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `bookmark` icon.
  static const HeroIconData bookmark = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm8 9.524.976.837 2.988 2.56a.325.325 0 0 0 .536-.246V4.5A1.5 1.5 0 0 0 11 3H5a1.5 1.5 0 0 0-1.5 1.5v8.175a.325.325 0 0 0 .536.247l2.988-2.56zM14 4.5a3 3 0 0 0-3-3H5a3 3 0 0 0-3 3v8.175a1.825 1.825 0 0 0 3.013 1.386L8 11.5l2.987 2.56A1.825 1.825 0 0 0 14 12.676z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `box` icon.
  static const HeroIconData box = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 10.421V5.475l-2 .714V8.25a.75.75 0 0 1-1.5 0V6.725l-2.25.804v6.088l4.777-1.792a1.5 1.5 0 0 0 .973-1.404m-2.254-5.734 1.6-.571a2 2 0 0 0-.175-.104L9.499 2.427a1.5 1.5 0 0 0-1.197-.063l-.941.353 3.724 1.862q.09.045.16.108M5.444 3.435l3.878 1.94-2.273.811-3.805-1.903q.108-.063.23-.109zm.806 4.029L2.5 5.589v5.057a1.5 1.5 0 0 0 .83 1.342l2.92 1.46zM1 5.579c0-.436.094-.856.266-1.236a.75.75 0 0 1 .2-.37c.342-.54.855-.968 1.48-1.203L7.777.96a3 3 0 0 1 2.394.125l3.172 1.586A3 3 0 0 1 15 5.354v5.067a3 3 0 0 1-1.947 2.809l-4.828 1.81a3 3 0 0 1-2.395-.125l-3.172-1.586A3 3 0 0 1 1 10.646z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `calendar` icon.
  static const HeroIconData calendar = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5.25 5.497a.75.75 0 0 1-.75-.75V4A1.5 1.5 0 0 0 3 5.5v1h10v-1A1.5 1.5 0 0 0 11.5 4v.75a.75.75 0 0 1-1.5 0V4H6v.747a.75.75 0 0 1-.75.75M10 2.5H6v-.752a.75.75 0 1 0-1.5 0V2.5a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h7a3 3 0 0 0 3-3v-6a3 3 0 0 0-3-3v-.75a.75.75 0 0 0-1.5 0zM3 8v3.5A1.5 1.5 0 0 0 4.5 13h7a1.5 1.5 0 0 0 1.5-1.5V8z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `check` icon.
  static const HeroIconData check = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.488 3.43a.75.75 0 0 1 .081 1.058l-6 7a.75.75 0 0 1-1.1.042l-3.5-3.5A.75.75 0 0 1 4.03 6.97l2.928 2.927 5.473-6.385a.75.75 0 0 1 1.057-.081',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `chevrons-down` icon.
  static const HeroIconData chevronsDown = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5.03 3.47a.75.75 0 0 0-1.06 1.06l3.5 3.5a.75.75 0 0 0 1.06 0l3.5-3.5a.75.75 0 0 0-1.06-1.06L8 6.44zm0 5a.75.75 0 0 0-1.06 1.06l3.5 3.5a.75.75 0 0 0 1.06 0l3.5-3.5a.75.75 0 0 0-1.06-1.06L8 11.44z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `chevrons-expand-vertical` icon.
  static const HeroIconData
  chevronsExpandVertical = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.58 4.109a.75.75 0 0 0 1.061 1.06L8 1.811l3.354 3.353a.75.75 0 0 0 1.06-1.06L8.53.22a.75.75 0 0 0-1.06 0zm8.84 7.782a.75.75 0 1 0-1.061-1.06l-3.36 3.358-3.353-3.353a.75.75 0 1 0-1.06 1.06L7.47 15.78a.75.75 0 0 0 1.06 0z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-check` icon.
  static const HeroIconData circleCheck = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 8a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0m-3.9-1.55a.75.75 0 1 0-1.2-.9L7.419 8.858 6.03 7.47a.75.75 0 0 0-1.06 1.06l2 2a.75.75 0 0 0 1.13-.08z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-check-fill` icon.
  static const HeroIconData circleCheckFill = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m3.1-8.55a.75.75 0 1 0-1.2-.9L7.419 8.858 6.03 7.47a.75.75 0 0 0-1.06 1.06l2 2a.75.75 0 0 0 1.13-.08z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-chevron-down` icon.
  static const HeroIconData circleChevronDown = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M2.5 8a5.5 5.5 0 1 1 11 0 5.5 5.5 0 0 1-11 0M1 8a7 7 0 1 1 14 0A7 7 0 0 1 1 8m5.03-1.28a.75.75 0 0 0-1.06 1.06l2.5 2.5a.75.75 0 0 0 1.06 0l2.5-2.5a.75.75 0 1 0-1.06-1.06L8 8.69z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-dollar` icon.
  static const HeroIconData circleDollar = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 8a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0M8.75 4.25a.75.75 0 0 0-1.5 0v.339a2.5 2.5 0 0 0-1.007.47 1.95 1.95 0 0 0-.74 1.546c0 .764.474 1.265.94 1.559.456.287 1.007.448 1.448.547.462.102.843.191 1.118.341.228.125.275.224.275.376 0 .102-.04.217-.248.341-.224.135-.577.229-.982.229-.344 0-.683-.114-.953-.29-.281-.184-.42-.388-.457-.506a.75.75 0 1 0-1.43.452c.171.543.591 1 1.068 1.31.284.185.612.335.968.429v.357a.75.75 0 0 0 1.5 0v-.313c.375-.067.74-.19 1.058-.382.53-.319.976-.864.976-1.627 0-.864-.51-1.394-1.055-1.692-.478-.26-1.056-.389-1.46-.478l-.053-.012c-.386-.086-.736-.202-.973-.352-.227-.142-.24-.236-.24-.29a.45.45 0 0 1 .18-.375c.134-.108.403-.227.87-.227.47 0 .742.11.9.218a.83.83 0 0 1 .316.41.75.75 0 0 0 1.407-.52 2.33 2.33 0 0 0-.878-1.13 2.7 2.7 0 0 0-1.048-.417z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-fill` icon.
  static const HeroIconData circleFill = HeroIconData(<HeroIconPath>[
    HeroIconPath('M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14', evenOdd: true),
  ]);

  /// Gravity UI `circle-info` icon.
  static const HeroIconData circleInfo = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 13.5a5.5 5.5 0 1 0 0-11 5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m1-9.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0m-.25 3a.75.75 0 0 0-1.5 0V11a.75.75 0 0 0 1.5 0z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-question` icon.
  static const HeroIconData circleQuestion = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 13.5a5.5 5.5 0 1 0 0-11 5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14M6.44 4.54c.43-.354.994-.565 1.56-.565 1.217 0 2.34.82 2.34 2.14 0 .377-.078.745-.298 1.1-.208.339-.513.614-.875.867-.217.153-.325.257-.379.328-.038.052-.038.07-.038.089a.75.75 0 0 1-1.5 0c0-.794.544-1.286 1.057-1.645.28-.196.4-.332.458-.426a.54.54 0 0 0 .075-.312c0-.3-.244-.641-.84-.641a1 1 0 0 0-.608.223c-.167.138-.231.287-.231.418a.75.75 0 0 1-1.5 0c0-.674.345-1.22.78-1.577M8 12a1 1 0 1 0 0-2 1 1 0 0 0 0 2',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-xmark` icon.
  static const HeroIconData circleXmark = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 8a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0M6.53 5.47a.75.75 0 0 0-1.06 1.06L6.94 8 5.47 9.47a.75.75 0 1 0 1.06 1.06L8 9.06l1.47 1.47a.75.75 0 1 0 1.06-1.06L9.06 8l1.47-1.47a.75.75 0 1 0-1.06-1.06L8 6.94z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-xmark-fill` icon.
  static const HeroIconData circleXmarkFill = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14M6.53 5.47a.75.75 0 0 0-1.06 1.06L6.94 8 5.47 9.47a.75.75 0 1 0 1.06 1.06L8 9.06l1.47 1.47a.75.75 0 1 0 1.06-1.06L9.06 8l1.47-1.47a.75.75 0 1 0-1.06-1.06L8 6.94z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `clock` icon.
  static const HeroIconData clock = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 8a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0M8.75 4.5a.75.75 0 0 0-1.5 0V8a.75.75 0 0 0 .3.6l2 1.5a.75.75 0 1 0 .9-1.2l-1.7-1.275z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `code-fork` icon.
  static const HeroIconData codeFork = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.504 5.897a2.751 2.751 0 1 1 1.503-.002A1.5 1.5 0 0 0 6.5 7.25h3a1.5 1.5 0 0 0 1.493-1.355 2.751 2.751 0 1 1 1.503.002A3 3 0 0 1 9.5 8.75h-.75v1.354a2.751 2.751 0 1 1-1.5 0V8.75H6.5a3 3 0 0 1-2.996-2.853M3 3.25a1.25 1.25 0 1 1 2.5 0 1.25 1.25 0 0 1-2.5 0m3.75 9.5a1.25 1.25 0 1 1 2.5 0 1.25 1.25 0 0 1-2.5 0m3.75-9.5a1.25 1.25 0 1 1 2.5 0 1.25 1.25 0 0 1-2.5 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `comment` icon.
  static const HeroIconData comment = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm4.843 10.944-.194 2.335a.204.204 0 0 0 .339.17l2.21-1.964.589.013L8 11.5c1.695 0 3.087-.44 4.02-1.177.89-.702 1.48-1.76 1.48-3.323s-.59-2.62-1.48-3.323C11.087 2.94 9.695 2.5 8 2.5s-3.087.44-4.02 1.177C3.09 4.38 2.5 5.437 2.5 7c0 1.648.656 2.742 1.648 3.448zm1.141 3.625 1.77-1.572Q7.875 13 8 13c3.866 0 7-2 7-6s-3.134-6-7-6-7 2-7 6c0 2.117.878 3.674 2.277 4.67l-.123 1.484a1.704 1.704 0 0 0 2.83 1.415',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `copy` icon.
  static const HeroIconData copy = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12 2.5H8A1.5 1.5 0 0 0 6.5 4v1H8a3 3 0 0 1 3 3v1.5h1A1.5 1.5 0 0 0 13.5 8V4A1.5 1.5 0 0 0 12 2.5M11 11h1a3 3 0 0 0 3-3V4a3 3 0 0 0-3-3H8a3 3 0 0 0-3 3v1H4a3 3 0 0 0-3 3v4a3 3 0 0 0 3 3h4a3 3 0 0 0 3-3zM4 6.5h4A1.5 1.5 0 0 1 9.5 8v4A1.5 1.5 0 0 1 8 13.5H4A1.5 1.5 0 0 1 2.5 12V8A1.5 1.5 0 0 1 4 6.5',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `credit-card` icon.
  static const HeroIconData creditCard = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12.5 4h-9A1.5 1.5 0 0 0 2 5.5h12A1.5 1.5 0 0 0 12.5 4M2 10.5V7h12v3.5a1.5 1.5 0 0 1-1.5 1.5h-9A1.5 1.5 0 0 1 2 10.5m1.5-8a3 3 0 0 0-3 3v5a3 3 0 0 0 3 3h9a3 3 0 0 0 3-3v-5a3 3 0 0 0-3-3zM4.25 9a.75.75 0 0 0 0 1.5h2.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `ellipsis` icon.
  static const HeroIconData ellipsis = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3M9.5 8a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m5 0a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `ellipsis-vertical` icon.
  static const HeroIconData ellipsisVertical = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 4.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3M9.5 8a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m0 5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `envelope` icon.
  static const HeroIconData envelope = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.5 4h9c.25 0 .485.06.692.169L8.75 7.5a1.25 1.25 0 0 1-1.5 0L2.808 4.169C3.015 4.06 3.251 4 3.5 4M2.001 5.438 2 5.5v5A1.5 1.5 0 0 0 3.5 12h9a1.5 1.5 0 0 0 1.5-1.5v-5l-.001-.062L9.65 8.7a2.75 2.75 0 0 1-3.3 0zM.5 5.5a3 3 0 0 1 3-3h9a3 3 0 0 1 3 3v5a3 3 0 0 1-3 3h-9a3 3 0 0 1-3-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `eye` icon.
  static const HeroIconData eye = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.87 8.515 1.641 8l.229-.515a6.708 6.708 0 0 1 12.26 0l.228.515-.229.515a6.708 6.708 0 0 1-12.259 0M.5 6.876l-.26.585a1.33 1.33 0 0 0 0 1.079l.26.584a8.208 8.208 0 0 0 15 0l.26-.584a1.33 1.33 0 0 0 0-1.08l-.26-.584a8.208 8.208 0 0 0-15 0M9.5 8a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0M11 8a3 3 0 1 1-6 0 3 3 0 0 1 6 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `eye-slash` icon.
  static const HeroIconData eyeSlash = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.03 1.97a.75.75 0 0 0-1.06 1.06l.83.83A8.2 8.2 0 0 0 .5 6.876l-.26.585a1.33 1.33 0 0 0 0 1.079l.26.585a8.21 8.21 0 0 0 11.434 3.87l1.036 1.035a.75.75 0 1 0 1.06-1.06zm7.788 9.908-1.294-1.293a3 3 0 0 1-4.109-4.109L3.866 4.927A6.7 6.7 0 0 0 1.87 7.486L1.641 8l.23.515a6.71 6.71 0 0 0 8.947 3.363M6.55 7.611A1.502 1.502 0 0 0 8.389 9.45zm1.658-2.604 2.784 2.784a3 3 0 0 0-2.784-2.784m5.92 3.508a6.7 6.7 0 0 1-.915 1.496l1.065 1.066A8.2 8.2 0 0 0 15.5 9.125l.26-.585a1.33 1.33 0 0 0 0-1.08l-.26-.584A8.21 8.21 0 0 0 5.572 2.37L6.81 3.61a6.71 6.71 0 0 1 7.32 3.877l.228.514z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `floppy-disk` icon.
  static const HeroIconData floppyDisk = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3 11.5A1.5 1.5 0 0 0 4.5 13v-2.5a2 2 0 0 1 2-2h3a2 2 0 0 1 2 2V13a1.5 1.5 0 0 0 1.5-1.5V6.036a1 1 0 0 0-.293-.708l-2.035-2.035A1 1 0 0 0 9.964 3H6v1a.5.5 0 0 0 .5.5h3a.75.75 0 0 1 0 1.5h-3a2 2 0 0 1-2-2V3A1.5 1.5 0 0 0 3 4.5zm-1.5 0a3 3 0 0 0 3 3h7a3 3 0 0 0 3-3V6.036a2.5 2.5 0 0 0-.732-1.768l-2.036-2.036A2.5 2.5 0 0 0 9.964 1.5H4.5a3 3 0 0 0-3 3zm8.5-1V13H6v-2.5a.5.5 0 0 1 .5-.5h3a.5.5 0 0 1 .5.5',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `folder-open` icon.
  static const HeroIconData folderOpen = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm6.379 4.5-.44-.44-.621-.62A1.5 1.5 0 0 0 4.258 3H3a1.5 1.5 0 0 0-1.5 1.5v5.25l1.376-2.293A3 3 0 0 1 5.45 6h7.05A1.5 1.5 0 0 0 11 4.5zM14 6.026V6a3 3 0 0 0-3-3H7l-.621-.621A3 3 0 0 0 4.257 1.5H3a3 3 0 0 0-3 3V11a3 3 0 0 0 3 3h8.301a3 3 0 0 0 2.573-1.457l1.791-2.985A2.35 2.35 0 0 0 14 6.026M10 12.5h1.301a1.5 1.5 0 0 0 1.287-.728l1.791-2.986 1.286.772-1.286-.772a.85.85 0 0 0-.728-1.286H5.449a1.5 1.5 0 0 0-1.287.728l-1.791 2.986a.85.85 0 0 0 .728 1.286z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `gear` icon.
  static const HeroIconData gear = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7.199 2H8.8a.2.2 0 0 1 .2.2c0 1.808 1.958 2.939 3.524 2.034a.2.2 0 0 1 .271.073l.802 1.388a.2.2 0 0 1-.073.272c-1.566.904-1.566 3.164 0 4.069a.2.2 0 0 1 .073.271l-.802 1.388a.2.2 0 0 1-.271.073C10.958 10.863 9 11.993 9 13.8a.2.2 0 0 1-.199.2H7.2a.2.2 0 0 1-.2-.2c0-1.808-1.958-2.938-3.524-2.034a.2.2 0 0 1-.272-.073l-.8-1.388a.2.2 0 0 1 .072-.271c1.566-.905 1.566-3.165 0-4.07a.2.2 0 0 1-.073-.27l.801-1.389a.2.2 0 0 1 .272-.072C5.042 5.138 7 4.007 7 2.199c0-.11.089-.199.199-.199M5.5 2.2c0-.94.76-1.7 1.699-1.7H8.8c.94 0 1.7.76 1.7 1.7a.85.85 0 0 0 1.274.735 1.7 1.7 0 0 1 2.32.622l.802 1.388c.469.813.19 1.851-.622 2.32a.85.85 0 0 0 0 1.472 1.7 1.7 0 0 1 .622 2.32l-.802 1.388a1.7 1.7 0 0 1-2.32.622.85.85 0 0 0-1.274.735c0 .939-.76 1.7-1.699 1.7H7.2a1.7 1.7 0 0 1-1.699-1.7.85.85 0 0 0-1.274-.735 1.7 1.7 0 0 1-2.32-.622l-.802-1.388a1.7 1.7 0 0 1 .622-2.32.85.85 0 0 0 0-1.471 1.7 1.7 0 0 1-.622-2.32l.801-1.389a1.7 1.7 0 0 1 2.32-.622A.85.85 0 0 0 5.5 2.2m4 5.8a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0M11 8a3 3 0 1 1-6 0 3 3 0 0 1 6 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `globe` icon.
  static const HeroIconData globe = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M9.208 12.346c-.485 1-.953 1.154-1.208 1.154s-.723-.154-1.208-1.154c-.372-.768-.647-1.858-.749-3.187a21 21 0 0 0 3.914 0c-.102 1.329-.377 2.419-.75 3.187m.788-4.699C9.358 7.714 8.69 7.75 8 7.75s-1.358-.036-1.996-.103c.037-1.696.343-3.075.788-3.993C7.277 2.654 7.745 2.5 8 2.5s.723.154 1.208 1.154c.445.918.75 2.297.788 3.993m1.478 1.306c-.085 1.516-.375 2.848-.836 3.874a5.5 5.5 0 0 0 2.843-4.364c-.621.199-1.295.364-2.007.49m1.918-2.043c-.572.204-1.21.379-1.901.514-.056-1.671-.354-3.14-.853-4.251a5.5 5.5 0 0 1 2.754 3.737m-8.883.514c.056-1.671.354-3.14.853-4.251A5.5 5.5 0 0 0 2.608 6.91c.572.204 1.21.379 1.901.514M2.52 8.463a5.5 5.5 0 0 0 2.843 4.364c-.46-1.026-.75-2.358-.836-3.874a15.5 15.5 0 0 1-2.007-.49M15 8A7 7 0 1 0 1 8a7 7 0 0 0 14 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `hard-drive` icon.
  static const HeroIconData hardDrive = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12 8.5a1.5 1.5 0 0 1 1.5 1.5v1a1.5 1.5 0 0 1-1.5 1.5H4A1.5 1.5 0 0 1 2.5 11v-1A1.5 1.5 0 0 1 4 8.5zm.89-1.366L11.488 4.33a1.5 1.5 0 0 0-1.342-.829H5.854a1.5 1.5 0 0 0-1.342.83L3.11 7.133A3 3 0 0 1 4 7h8a3 3 0 0 1 .89.134M15 9.18V11a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3V9.18a5 5 0 0 1 .528-2.236L3.17 3.658A3 3 0 0 1 5.854 2h4.292a3 3 0 0 1 2.683 1.658l1.643 3.286A5 5 0 0 1 15 9.18m-6 .57a.75.75 0 0 0 0 1.5h2.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `heart` icon.
  static const HeroIconData heart = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.633 2.796c.762-.837 1.85-1.297 3.127-1.297 1.164 0 2.407.55 3.24 1.626.828-1.075 2.066-1.626 3.24-1.626 1.274 0 2.36.458 3.124 1.293.756.828 1.136 1.962 1.136 3.22 0 2.166-1.113 3.909-2.522 5.264-1.405 1.352-3.17 2.383-4.633 3.14a.75.75 0 0 1-.693-.002c-1.463-.765-3.228-1.788-4.633-3.133C1.61 9.93.5 8.193.5 6.013c0-1.255.378-2.389 1.133-3.217m1.109 1.01C2.287 4.306 2 5.053 2 6.013c0 1.624.816 2.996 2.057 4.184 1.146 1.098 2.6 1.985 3.945 2.705 1.335-.71 2.79-1.604 3.937-2.707C13.182 8.998 14 7.62 14 6.013c0-.963-.288-1.71-.744-2.21C12.808 3.314 12.14 3 11.24 3c-.976 0-2.093.628-2.527 1.95a.75.75 0 0 1-1.426 0C6.854 3.63 5.725 3 4.76 3c-.903 0-1.57.315-2.018.807',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `heart-fill` icon.
  static const HeroIconData heartFill = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4.76 1.5c-1.278 0-2.365.459-3.127 1.296C.878 3.624.5 4.758.5 6.013c0 2.18 1.11 3.917 2.52 5.268 1.404 1.345 3.17 2.368 4.632 3.133a.75.75 0 0 0 .693.002c1.463-.757 3.228-1.788 4.633-3.14 1.41-1.355 2.522-3.098 2.522-5.263 0-1.26-.38-2.393-1.136-3.221-.763-.835-1.85-1.293-3.124-1.293-1.076 0-1.966.399-2.643 1.151A4.5 4.5 0 0 0 8 3.504a4.5 4.5 0 0 0-.597-.854C6.726 1.898 5.836 1.5 4.76 1.5',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `house` icon.
  static const HeroIconData house = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12.5 12.618c.307-.275.5-.674.5-1.118V6.977a1.5 1.5 0 0 0-.585-1.189l-3.5-2.692a1.5 1.5 0 0 0-1.83 0l-3.5 2.692A1.5 1.5 0 0 0 3 6.978V11.5A1.496 1.496 0 0 0 4.493 13H5V9.5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2V13h.507c.381-.002.73-.146.993-.382m2-1.118a3 3 0 0 1-3 3h-7a3 3 0 0 1-3-3V6.977A3 3 0 0 1 2.67 4.6l3.5-2.692a3 3 0 0 1 3.66 0l3.5 2.692a3 3 0 0 1 1.17 2.378zm-5-2A.5.5 0 0 0 9 9H7a.5.5 0 0 0-.5.5V13h3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `italic` icon.
  static const HeroIconData italic = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7.25 2a.75.75 0 0 0 0 1.5h1.317l-2.7 9H4.25a.75.75 0 1 0 0 1.5h4.5a.75.75 0 0 0 0-1.5H7.433l2.7-9h1.617a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `link` icon.
  static const HeroIconData link = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.47 6.53a.75.75 0 0 1 1.06 1.061l-.727.727a2.743 2.743 0 0 0 3.879 3.879l.727-.727a.75.75 0 0 1 1.06 1.06l-.726.727a4.243 4.243 0 0 1-6-6zm8 1.879a.75.75 0 0 0 1.06 1.06l.727-.726a4.243 4.243 0 0 0-6-6l-.727.727a.75.75 0 0 0 1.061 1.06l.727-.727a2.743 2.743 0 0 1 3.879 3.879zm-.94-1.879a.75.75 0 1 0-1.06-1.06l-4 4a.75.75 0 1 0 1.06 1.06z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `lock-open` icon.
  static const HeroIconData lockOpen = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10.5 5a2.5 2.5 0 0 0-4.532-1.456c-.242.336-.66.559-1.052.428-.393-.131-.611-.56-.41-.922A4 4 0 0 1 12 5v1h.001a3 3 0 0 1 3 3v3a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3V9a3 3 0 0 1 3-3h6.5zm.75 2.5H4A1.5 1.5 0 0 0 2.5 9v3A1.5 1.5 0 0 0 4 13.5h8a1.5 1.5 0 0 0 1.5-1.5V9A1.5 1.5 0 0 0 12 7.5zM8 8.75a.75.75 0 0 1 .75.75v2a.75.75 0 0 1-1.5 0v-2A.75.75 0 0 1 8 8.75',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `magnifier` icon.
  static const HeroIconData magnifier = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.5 7a4.5 4.5 0 1 1-9 0 4.5 4.5 0 0 1 9 0m-.82 4.74a6 6 0 1 1 1.06-1.06l2.79 2.79a.75.75 0 1 1-1.06 1.06z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `microphone` icon.
  static const HeroIconData microphone = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M9.5 7V3.5a1.5 1.5 0 1 0-3 0V7a1.5 1.5 0 1 0 3 0M8 .5a3 3 0 0 0-3 3V7a3 3 0 0 0 6 0V3.5a3 3 0 0 0-3-3m.75 12.454A6 6 0 0 0 14 7v-.25a.75.75 0 0 0-1.5 0V7a4.5 4.5 0 1 1-9 0v-.25a.75.75 0 0 0-1.5 0V7c0 3.06 2.29 5.585 5.25 5.954v1.796a.75.75 0 0 0 1.5 0z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `microphone-slash` icon.
  static const HeroIconData microphoneSlash = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8.773 9.9A3.004 3.004 0 0 1 5 7v-.94L1.97 3.03a.75.75 0 0 1 1.06-1.06l11 11a.75.75 0 1 1-1.06 1.06l-1.884-1.883a6 6 0 0 1-2.336.807v1.796a.75.75 0 0 1-1.5 0v-1.796A6 6 0 0 1 2 7v-.25a.75.75 0 0 1 1.5 0V7a4.5 4.5 0 0 0 6.481 4.042L8.825 9.885zM9.5 3.5v2.798l1.415 1.415Q11 7.369 11 7V3.5a3 3 0 0 0-5.669-1.371l1.18 1.18A1.5 1.5 0 0 1 9.5 3.5m2.587 5.385L13.2 9.997c.51-.882.8-1.905.8-2.997v-.25a.75.75 0 0 0-1.5 0V7a4.5 4.5 0 0 1-.413 1.885',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `minus` icon.
  static const HeroIconData minus = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.75 8a.75.75 0 0 1 .75-.75h11a.75.75 0 0 1 0 1.5h-11A.75.75 0 0 1 1.75 8',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `moon` icon.
  static const HeroIconData moon = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 13.5a5.5 5.5 0 0 0 2.263-10.514 5.5 5.5 0 0 1-7.278 7.278A5.5 5.5 0 0 0 8 13.5M1.045 8.795a7.001 7.001 0 1 0 7.75-7.75l-.028-.003A7 7 0 0 0 8 1c-.527 0-.59.842-.185 1.18a4 4 0 0 1 .342.322A4 4 0 1 1 2.18 7.814C1.842 7.41 1 7.474 1 8a7 7 0 0 0 .045.794',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `paperclip` icon.
  static const HeroIconData paperclip = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm9.77 10.73.01-.01 3.08-3.08a3.889 3.889 0 1 0-5.5-5.5L4.73 4.77l-.01.01-1.667 1.666a5.303 5.303 0 0 0 7.5 7.5l3.167-3.166a.75.75 0 1 0-1.061-1.06l-3.166 3.166a3.803 3.803 0 1 1-5.379-5.379L5.33 6.291l.011-.01L8.421 3.2a2.39 2.39 0 0 1 3.38 3.378l-1.13 1.13-.012.012-2.995 2.994a.975.975 0 1 1-1.378-1.378L9.28 6.34a.75.75 0 0 0-1.06-1.06L5.225 8.274a2.475 2.475 0 0 0 3.5 3.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `pencil` icon.
  static const HeroIconData pencil = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.423 1A3.577 3.577 0 0 1 15 4.577c0 .27-.108.53-.3.722l-.528.529-1.971 1.971-5.059 5.059a3 3 0 0 1-1.533.82l-2.638.528a1 1 0 0 1-1.177-1.177l.528-2.638a3 3 0 0 1 .82-1.533l5.059-5.059 2.5-2.5c.191-.191.451-.299.722-.299m-2.31 4.009-4.91 4.91a1.5 1.5 0 0 0-.41.766l-.38 1.903 1.902-.38a1.5 1.5 0 0 0 .767-.41l4.91-4.91a2.08 2.08 0 0 0-1.88-1.88m3.098.658a3.6 3.6 0 0 0-1.878-1.879l1.28-1.28c.995.09 1.788.884 1.878 1.88z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `person` icon.
  static const HeroIconData person = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 8.5c3.85 0 7 2.5 7 4.5a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2c0-2 3.15-4.5 7-4.5M8 10c-1.61 0-3.064.526-4.092 1.234C2.798 12.001 2.5 12.733 2.5 13a.5.5 0 0 0 .5.5h10a.5.5 0 0 0 .5-.5c0-.267-.297-1-1.408-1.766C11.064 10.526 9.609 10 8 10m0-9a3.5 3.5 0 1 1 0 7 3.5 3.5 0 0 1 0-7m0 1.5a2 2 0 1 0 0 4 2 2 0 0 0 0-4',
    ),
  ]);

  /// Gravity UI `persons` icon.
  static const HeroIconData persons = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5.5 6a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3m0 1.5a3 3 0 1 0 0-6 3 3 0 0 0 0 6m-3.029 2.886c-.777.54-.971 1.063-.971 1.306 0 .446.362.808.808.808h6.384a.81.81 0 0 0 .808-.808c0-.244-.194-.767-.971-1.306C7.792 9.875 6.719 9.5 5.5 9.5s-2.292.375-3.029.886M0 11.692C0 9.846 2.475 8 5.5 8c1.18 0 2.278.281 3.177.734A5.67 5.67 0 0 1 11.5 8c2.475 0 4.5 1.538 4.5 3.077A1.923 1.923 0 0 1 14.077 13h-3.483c-.416.604-1.113 1-1.902 1H2.308A2.31 2.31 0 0 1 0 11.692m10.991-.192h3.086c.234 0 .423-.19.423-.423 0-.103-.096-.472-.688-.89-.554-.393-1.375-.687-2.312-.687-.517 0-.999.09-1.42.236.526.534.854 1.146.911 1.764M12.5 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0M14 5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `picture` icon.
  static const HeroIconData picture = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.5 3h-7A1.5 1.5 0 0 0 3 4.5v5.027l.962-.7a1.75 1.75 0 0 1 2.079.016l.928.696 2.368-2.03a1.75 1.75 0 0 1 2.325.043L13 8.787V4.5A1.5 1.5 0 0 0 11.5 3m3 7.498V4.5a3 3 0 0 0-3-3h-7a3 3 0 0 0-3 3v7a3 3 0 0 0 3 3h7a3 3 0 0 0 3-3zm-1.5.33-2.355-2.174a.25.25 0 0 0-.332-.006L7.488 11.07l-.457.392-.481-.361-1.41-1.057a.25.25 0 0 0-.296-.002L3 11.381v.119A1.5 1.5 0 0 0 4.5 13h7a1.5 1.5 0 0 0 1.5-1.5zM7.5 6a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `pin` icon.
  static const HeroIconData pin = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10.5 2.255v-.01c.003-.03.013-.157-.361-.35C9.703 1.668 8.967 1.5 8 1.5s-1.703.169-2.138.394c-.375.194-.365.32-.362.351v.01c-.003.03-.013.157.362.35C6.297 2.832 7.033 3 8 3s1.703-.169 2.139-.394c.374-.194.364-.32.361-.351M8 4.5c.506 0 .99-.04 1.436-.118l.84 2.352.253.707.717.221c.648.2 1.055.44 1.277.65.192.18.227.31.227.438 0 .14-.055.488-.937.878-.869.384-2.2.622-3.813.622s-2.944-.238-3.813-.622c-.882-.39-.937-.738-.937-.878 0-.128.035-.259.227-.439.222-.209.629-.448 1.277-.649l.717-.221.253-.707.84-2.352c.445.079.93.118 1.436.118m4-2.25c0 .738-.433 1.294-1.136 1.669l.825 2.31c1.553.48 2.561 1.32 2.561 2.52 0 1.854-2.402 2.848-5.5 2.985V15a.75.75 0 0 1-1.5 0v-3.266c-3.098-.136-5.5-1.131-5.5-2.984 0-1.2 1.008-2.04 2.561-2.52l.825-2.311C4.433 3.544 4 2.988 4 2.25 4 .75 5.79 0 8 0s4 .75 4 2.25',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `planet-earth` icon.
  static const HeroIconData planetEarth = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 13.5c1.63 0 3.094-.709 4.101-1.835A2.5 2.5 0 0 1 10.25 9.25V9a.75.75 0 0 0-.75-.75 2.25 2.25 0 0 1 0-4.5.75.75 0 0 0 .75-.75v-.02a5.5 5.5 0 0 0-7.471 3.287A2.25 2.25 0 0 1 4.75 8.5c0 .414.336.75.75.75a2.25 2.25 0 0 1 1.265 4.11q.597.139 1.235.14m-3.491-1.25H5.5a.75.75 0 0 0 0-1.5A2.25 2.25 0 0 1 3.25 8.5a.75.75 0 0 0-.744-.75 5.49 5.49 0 0 0 2.003 4.5m8.241-2h.27A5.5 5.5 0 0 0 13.5 8c0-1.665-.74-3.158-1.91-4.166A2.25 2.25 0 0 1 9.5 5.25a.75.75 0 1 0 0 1.5A2.25 2.25 0 0 1 11.75 9v.25a1 1 0 0 0 1 1M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `plug-connection` icon.
  static const HeroIconData plugConnection = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M15.53 1.53A.75.75 0 0 0 14.47.47l-1.29 1.29a4.24 4.24 0 0 0-5.423.483l-.58.58a.96.96 0 0 0 0 1.354l4.646 4.646a.96.96 0 0 0 1.354 0l.58-.58a4.24 4.24 0 0 0 .484-5.423zm-8.5 4.94a.75.75 0 0 1 0 1.06L5.78 8.78l1.44 1.44 1.25-1.25a.75.75 0 0 1 1.06 1.06l-1.25 1.25.543.543a.96.96 0 0 1 0 1.354l-.58.58a4.24 4.24 0 0 1-5.423.484l-1.29 1.29A.75.75 0 0 1 .47 14.47l1.29-1.29a4.24 4.24 0 0 1 .483-5.423l.58-.58a.96.96 0 0 1 1.354 0l.543.543 1.25-1.25a.75.75 0 0 1 1.06 0M3.5 8.62l-.197.197a2.743 2.743 0 0 0 3.879 3.879l.197-.197zm9.197-1.439-.197.197L8.621 3.5l.197-.197a2.743 2.743 0 0 1 3.879 3.879',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `plus` icon.
  static const HeroIconData plus = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 1.75a.75.75 0 0 1 .75.75v4.75h4.75a.75.75 0 0 1 0 1.5H8.75v4.75a.75.75 0 0 1-1.5 0V8.75H2.5a.75.75 0 0 1 0-1.5h4.75V2.5A.75.75 0 0 1 8 1.75',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `power` icon.
  static const HeroIconData power = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8.75 1.75a.75.75 0 0 0-1.5 0v5.5a.75.75 0 0 0 1.5 0zM4.92 3.442A.75.75 0 1 0 4.08 2.2a7 7 0 1 0 7.841 0 .75.75 0 1 0-.841 1.242 5.5 5.5 0 1 1-6.159 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `qr-code` icon.
  static const HeroIconData qrCode = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8.75 2.25a.75.75 0 0 0-1.5 0v5h-5a.75.75 0 0 0 0 1.5h5.5a1 1 0 0 0 1-1zM7.25 11a1 1 0 0 1 1-1H11a.75.75 0 0 1 0 1.5H8.75v2.25a.75.75 0 0 1-1.5 0zM13 13h-2.25a.75.75 0 0 0 0 1.5h2.75a1 1 0 0 0 1-1V8.25a1 1 0 0 0-1-1h-2.75a.75.75 0 0 0 0 1.5H13zM3 4.5V3h1.5v1.5zm-1.5-2a1 1 0 0 1 1-1H5a1 1 0 0 1 1 1V5a1 1 0 0 1-1 1H2.5a1 1 0 0 1-1-1zm1.5 9V13h1.5v-1.5zM2.5 10a1 1 0 0 0-1 1v2.5a1 1 0 0 0 1 1H5a1 1 0 0 0 1-1V11a1 1 0 0 0-1-1zm9-5.5V3H13v1.5zm-1.5-2a1 1 0 0 1 1-1h2.5a1 1 0 0 1 1 1V5a1 1 0 0 1-1 1H11a1 1 0 0 1-1-1z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `receipt` icon.
  static const HeroIconData receipt = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M6.3 2 3.9.5 2 2v13.5l1.5-.776L4.9 14l2.4 1.5L9.7 14l2.4 1.5L14 14V.5l-1.5.776L11.1 2 8.7.5zm2.4.269L7.095 3.272l-.795.497-.795-.497-1.504-.94-.501.395v10.308l.71-.367.76-.393.725.453L7.3 13.731l1.605-1.003.795-.497.795.497 1.504.94.501-.395V2.965l-.71.367-.76.393-.725-.453zM5 6.5a.75.75 0 0 1 .75-.75h4.5a.75.75 0 0 1 0 1.5h-4.5A.75.75 0 0 1 5 6.5m.75 2.25a.75.75 0 0 0 0 1.5h2.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `rocket` icon.
  static const HeroIconData rocket = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm6.993 5.628-.787-.157-1.118-.224a1.13 1.13 0 0 0-1.024.31L2.837 6.785a1.15 1.15 0 0 0-.285.474l1.02.185a6.19 6.19 0 0 1 4.985 4.985l.185 1.02c.178-.055.34-.152.474-.285l1.227-1.227c.268-.268.384-.652.31-1.024l-.224-1.118-.157-.787.567-.568 1.243-1.242A4.5 4.5 0 0 0 13.5 4.015V2.5h-1.515a4.5 4.5 0 0 0-3.182 1.318L7.561 5.061zM12 9.5l1.243-1.243A6 6 0 0 0 15 4.015V2.5A1.5 1.5 0 0 0 13.5 1h-1.515a6 6 0 0 0-4.242 1.757L6.5 4l-1.118-.224a2.63 2.63 0 0 0-2.379.72L1.777 5.724A2.65 2.65 0 0 0 1 7.598c0 .522.373.97.887 1.063l1.417.258a4.69 4.69 0 0 1 3.777 3.777l.258 1.417c.093.514.54.887 1.063.887.703 0 1.377-.28 1.875-.777l1.226-1.226a2.63 2.63 0 0 0 .72-2.38zm-8.06 2.571c-.311-.31-.76-.28-1.005-.036-.233.233-.423.658-.527 1.247a5 5 0 0 0-.05.366q.184-.019.377-.053c.596-.106 1.017-.296 1.24-.52.245-.244.275-.693-.036-1.004M5 11.011c-.873-.874-2.273-.89-3.126-.036C.777 12.07.802 14.094.837 14.712c.007.12.06.23.145.315a.5.5 0 0 0 .32.145c.622.032 2.652.046 3.734-1.035.853-.854.837-2.253-.036-3.126m6.78-5.73a.75.75 0 0 0-1.06-1.061l-1.5 1.5a.75.75 0 0 0 1.06 1.06z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `scissors` icon.
  static const HeroIconData scissors = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4.5 6a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3m-3-1.5a3 3 0 0 0 4.524 2.585L6.939 8l-.915.915a3 3 0 1 0 1.06 1.06L8.122 8.94l5.501 3.209a.75.75 0 1 0 .756-1.296L9.488 8l4.89-2.852a.75.75 0 0 0-.756-1.296l-5.5 3.209-1.037-1.037A3 3 0 1 0 1.5 4.5m3 5.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `shopping-bag` icon.
  static const HeroIconData shoppingBag = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5.174 3h5.652a1.5 1.5 0 0 1 1.49 1.328l.808 7A1.5 1.5 0 0 1 11.634 13H4.366a1.5 1.5 0 0 1-1.49-1.672l.808-7A1.5 1.5 0 0 1 5.174 3m-2.98 1.156A3 3 0 0 1 5.174 1.5h5.652a3 3 0 0 1 2.98 2.656l.808 7a3 3 0 0 1-2.98 3.344H4.366a3 3 0 0 1-2.98-3.344zM5 5.25a.75.75 0 0 1 1.5 0v.25a1.5 1.5 0 1 0 3 0v-.25a.75.75 0 0 1 1.5 0v.25a3 3 0 0 1-6 0z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `sparkles` icon.
  static const HeroIconData sparkles = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13 10a.75.75 0 0 1 .725.556 2.37 2.37 0 0 0 1.72 1.72.75.75 0 0 1 0 1.449 2.37 2.37 0 0 0-1.72 1.72.75.75 0 0 1-1.45 0 2.37 2.37 0 0 0-1.72-1.72.75.75 0 0 1 0-1.45 2.37 2.37 0 0 0 1.72-1.72l.043-.117A.75.75 0 0 1 13 10M7 0a1.5 1.5 0 0 1 1.48 1.253c.242 1.455.696 2.364 1.3 2.968.603.603 1.512 1.057 2.967 1.3a1.5 1.5 0 0 1 0 2.958c-1.455.243-2.364.697-2.968 1.3-.603.604-1.057 1.513-1.3 2.968a1.5 1.5 0 0 1-2.958 0c-.243-1.455-.697-2.364-1.3-2.968-.604-.603-1.513-1.057-2.968-1.3a1.5 1.5 0 0 1 0-2.958c1.455-.243 2.364-.697 2.968-1.3.603-.604 1.057-1.513 1.3-2.968l.028-.133A1.5 1.5 0 0 1 7 0m0 1.5C6.45 4.8 4.8 6.45 1.5 7c3.3.55 4.95 2.2 5.5 5.5.55-3.3 2.2-4.95 5.5-5.5C9.2 6.45 7.55 4.8 7 1.5',
    ),
  ]);

  /// Gravity UI `square-article` icon.
  static const HeroIconData squareArticle = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.5 3h-7A1.5 1.5 0 0 0 3 4.5v7A1.5 1.5 0 0 0 4.5 13h7a1.5 1.5 0 0 0 1.5-1.5v-7A1.5 1.5 0 0 0 11.5 3m-7-1.5a3 3 0 0 0-3 3v7a3 3 0 0 0 3 3h7a3 3 0 0 0 3-3v-7a3 3 0 0 0-3-3zm6 6H5.43a1 1 0 0 0-1 1v2a1 1 0 0 0 1 1h5.07a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1m-5.32-3h3.57a.75.75 0 0 1 0 1.5H5.18a.75.75 0 0 1 0-1.5',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `square-plus` icon.
  static const HeroIconData squarePlus = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4.5 3h7A1.5 1.5 0 0 1 13 4.5v7a1.5 1.5 0 0 1-1.5 1.5h-7A1.5 1.5 0 0 1 3 11.5v-7A1.5 1.5 0 0 1 4.5 3m-3 1.5a3 3 0 0 1 3-3h7a3 3 0 0 1 3 3v7a3 3 0 0 1-3 3h-7a3 3 0 0 1-3-3zm7.25 1a.75.75 0 0 0-1.5 0v1.75H5.5a.75.75 0 1 0 0 1.5h1.75v1.75a.75.75 0 0 0 1.5 0V8.75h1.75a.75.75 0 0 0 0-1.5H8.75z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `star` icon.
  static const HeroIconData star = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm9.194 5 .351.873.94.064 3.197.217-2.46 2.055-.722.603.23.914.782 3.108-2.714-1.704L8 10.629l-.798.5-2.714 1.705.782-3.108.23-.914-.723-.603-2.46-2.055 3.198-.217.94-.064.35-.874L8 2.025zm-7.723-.292 3.943-.268L6.886.773C7.29-.231 8.71-.231 9.114.773l1.472 3.667 3.943.268c1.08.073 1.518 1.424.688 2.118L12.185 9.36l.964 3.832c.264 1.05-.886 1.884-1.802 1.31L8 12.4l-3.347 2.101c-.916.575-2.066-.26-1.802-1.309l.964-3.832L.783 6.826c-.83-.694-.391-2.045.688-2.118',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `strikethrough` icon.
  static const HeroIconData strikethrough = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5.502 2.757C6.214 2.236 7.122 2 7.984 2c1.685 0 3.015.572 3.687 1.915a.75.75 0 1 1-1.342.67C10.001 3.93 9.331 3.5 7.984 3.5c-.611 0-1.19.17-1.597.468-.384.28-.627.678-.627 1.242 0 .403.165.758.463 1.04H4.447a2.9 2.9 0 0 1-.187-1.04c0-1.084.507-1.916 1.242-2.453m6.047 5.993h1.201a.75.75 0 0 0 0-1.5h-9.5a.75.75 0 0 0 0 1.5h5.475l.043.012h.002c1.196.323 1.98 1.005 1.98 1.988 0 .669-.289 1.063-.742 1.33-.5.296-1.222.437-2 .437-1.398 0-2.453-.472-2.796-1.504a.75.75 0 1 0-1.424.474c.657 1.969 2.602 2.53 4.22 2.53.915 0 1.94-.16 2.762-.644.869-.512 1.48-1.376 1.48-2.623 0-.822-.276-1.481-.7-2',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `sun` icon.
  static const HeroIconData sun = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 3a.75.75 0 0 1-.75-.75V.75a.75.75 0 0 1 1.5 0v1.5A.75.75 0 0 1 8 3m0 7.5a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5M8 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8m-.75 3.25a.75.75 0 0 0 1.5 0v-1.5a.75.75 0 0 0-1.5 0zM13 8a.75.75 0 0 1 .75-.75h1.5a.75.75 0 0 1 0 1.5h-1.5A.75.75 0 0 1 13 8M.75 7.25a.75.75 0 0 0 0 1.5h1.5a.75.75 0 0 0 0-1.5zm10.786-2.786a.75.75 0 0 1 0-1.06l1.06-1.06a.75.75 0 0 1 1.06 1.06l-1.06 1.06a.75.75 0 0 1-1.06 0m-9.193 8.132a.75.75 0 0 0 1.06 1.06l1.062-1.06a.75.75 0 0 0-1.061-1.06zm9.193-1.06a.75.75 0 0 1 1.06 0l1.06 1.06a.75.75 0 0 1-1.06 1.06l-1.06-1.06a.75.75 0 0 1 0-1.06M3.404 2.343a.75.75 0 0 0-1.06 1.06l1.06 1.061a.75.75 0 1 0 1.06-1.06z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `text-align-center` icon.
  static const HeroIconData textAlignCenter = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M2.75 2a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5zm0 7a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5zm2 3.5a.75.75 0 0 0 0 1.5h6.5a.75.75 0 0 0 0-1.5zM4 6.25a.75.75 0 0 1 .75-.75h6.5a.75.75 0 0 1 0 1.5h-6.5A.75.75 0 0 1 4 6.25',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `text-align-justify` icon.
  static const HeroIconData textAlignJustify = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M2.75 2a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5zM2 6.25a.75.75 0 0 1 .75-.75h10.5a.75.75 0 0 1 0 1.5H2.75A.75.75 0 0 1 2 6.25M2.75 9a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5zm0 3.5a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `text-align-left` icon.
  static const HeroIconData textAlignLeft = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M2.75 2a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5zm0 7a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5zm0 3.5a.75.75 0 0 0 0 1.5h6.5a.75.75 0 0 0 0-1.5zM2 6.25a.75.75 0 0 1 .75-.75h6.5a.75.75 0 0 1 0 1.5h-6.5A.75.75 0 0 1 2 6.25',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `text-align-right` icon.
  static const HeroIconData textAlignRight = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M2.75 2a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5zM6 6.25a.75.75 0 0 1 .75-.75h6.5a.75.75 0 0 1 0 1.5h-6.5A.75.75 0 0 1 6 6.25M2.75 9a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5zm4 3.5a.75.75 0 0 0 0 1.5h6.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `thumbs-down` icon.
  static const HeroIconData thumbsDown = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm12 9-2.94 5.041a1.932 1.932 0 0 1-3.56-1.378l.25-1.163.321-1.5h-2.94a2 2 0 0 1-1.927-2.535l.879-3.162A4 4 0 0 1 6.404 1.4L11.5 2zM6.229 2.89l3.863.455.379 5.3-2.708 4.64a.432.432 0 0 1-.796-.308l.571-2.663.389-1.814H3.13a.5.5 0 0 1-.482-.634l.879-3.162a2.5 2.5 0 0 1 2.7-1.814m7.023 5.663a.75.75 0 1 0 1.496-.106l-.5-7a.75.75 0 0 0-1.496.106z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `thumbs-up` icon.
  static const HeroIconData thumbsUp = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm4 7 2.94-5.041a1.932 1.932 0 0 1 3.56 1.378L10.25 4.5 9.93 6h2.94a2 2 0 0 1 1.927 2.535l-.879 3.162A4 4 0 0 1 9.596 14.6L4.5 14zm5.771 6.11-3.863-.455-.379-5.3 2.708-4.64a.432.432 0 0 1 .796.308l-.571 2.663L8.073 7.5h4.796a.5.5 0 0 1 .482.634l-.879 3.162a2.5 2.5 0 0 1-2.7 1.814M2.748 7.447a.75.75 0 1 0-1.496.106l.5 7a.75.75 0 0 0 1.496-.106z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `trash-bin` icon.
  static const HeroIconData trashBin = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M9 2H7a.5.5 0 0 0-.5.5V3h3v-.5A.5.5 0 0 0 9 2m2 1v-.5a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2V3H2.251a.75.75 0 0 0 0 1.5h.312l.317 7.625A3 3 0 0 0 5.878 15h4.245a3 3 0 0 0 2.997-2.875l.318-7.625h.312a.75.75 0 0 0 0-1.5zm.936 1.5H4.064l.315 7.562A1.5 1.5 0 0 0 5.878 13.5h4.245a1.5 1.5 0 0 0 1.498-1.438zm-6.186 2v5a.75.75 0 0 0 1.5 0v-5a.75.75 0 0 0-1.5 0m3.75-.75a.75.75 0 0 1 .75.75v5a.75.75 0 0 1-1.5 0v-5a.75.75 0 0 1 .75-.75',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `triangle-exclamation` icon.
  static const HeroIconData triangleExclamation = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7.134 2.994 2.217 11.5a1 1 0 0 0 .866 1.5h9.834a1 1 0 0 0 .866-1.5L8.866 2.993a1 1 0 0 0-1.732 0m3.03-.75c-.962-1.665-3.366-1.665-4.329 0L.918 10.749c-.963 1.666.24 3.751 2.165 3.751h9.834c1.925 0 3.128-2.085 2.164-3.751zM8 5a.75.75 0 0 1 .75.75v2a.75.75 0 0 1-1.5 0v-2A.75.75 0 0 1 8 5m1 5.75a1 1 0 1 1-2 0 1 1 0 0 1 2 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `underline` icon.
  static const HeroIconData underline = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5 2.75a.75.75 0 0 0-1.5 0V7a4.5 4.5 0 0 0 9 0V2.75a.75.75 0 0 0-1.5 0V7a3 3 0 0 1-6 0zm-.75 9.75a.75.75 0 0 0 0 1.5h7.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `video` icon.
  static const HeroIconData video = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3 4.5h5.5A1.5 1.5 0 0 1 10 6v4a1.5 1.5 0 0 1-1.5 1.5H3A1.5 1.5 0 0 1 1.5 10V6A1.5 1.5 0 0 1 3 4.5m8.452 6.037A3 3 0 0 1 8.5 13H3a3 3 0 0 1-3-3V6a3 3 0 0 1 3-3h5.5a3 3 0 0 1 2.952 2.463l1.554-1.11A1.893 1.893 0 0 1 16 5.893v4.214a1.893 1.893 0 0 1-2.994 1.54zm.048-1.809 2.378 1.699a.393.393 0 0 0 .622-.32V5.893a.393.393 0 0 0-.622-.32L11.5 7.272z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `volume-fill` icon.
  static const HeroIconData volumeFill = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.5 11h3l2.586 2.586a1.414 1.414 0 0 0 2.414-1V3.414a1.414 1.414 0 0 0-2.414-1L4.5 5h-3A1.5 1.5 0 0 0 0 6.5v3A1.5 1.5 0 0 0 1.5 11m12.662 2.103c-.265.319-.743.317-1.036.024-.292-.293-.288-.766-.031-1.09A6.47 6.47 0 0 0 14.5 8a6.47 6.47 0 0 0-1.405-4.036c-.257-.325-.261-.797.032-1.09.292-.293.77-.295 1.035.024A7.97 7.97 0 0 1 16 8c0 1.94-.69 3.718-1.838 5.103m-2.138-2.135c-.246.333-.726.33-1.019.037-.293-.292-.284-.764-.06-1.112A3.5 3.5 0 0 0 11.5 8c0-.697-.204-1.346-.555-1.892-.224-.348-.233-.82.06-1.113s.773-.296 1.02.038C12.638 5.863 13 6.889 13 8a4.98 4.98 0 0 1-.976 2.968',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `volume-slash-fill` icon.
  static const HeroIconData volumeSlashFill = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.03 1.97a.75.75 0 0 0-1.06 1.06L3.94 5H1.5A1.5 1.5 0 0 0 0 6.5v3A1.5 1.5 0 0 0 1.5 11h3l2.586 2.586a1.414 1.414 0 0 0 2.414-1V10.56l3.47 3.47a.75.75 0 1 0 1.06-1.061zm8.459 6.317 1.265 1.265C12.915 9.064 13 8.542 13 8a4.98 4.98 0 0 0-.975-2.967c-.247-.334-.727-.33-1.02-.038s-.284.765-.06 1.113a3.5 3.5 0 0 1 .544 2.179m2.422 2.422 1.117 1.117C15.648 10.689 16 9.386 16 8c0-1.94-.69-3.717-1.838-5.102-.264-.32-.743-.317-1.035-.024-.293.293-.29.765-.032 1.09A6.47 6.47 0 0 1 14.5 8c0 .967-.21 1.884-.59 2.709m-7.56-7.56L9.5 6.298V3.414a1.414 1.414 0 0 0-2.414-1z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `xmark` icon.
  static const HeroIconData xmark = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.47 3.47a.75.75 0 0 1 1.06 0L8 6.94l3.47-3.47a.75.75 0 1 1 1.06 1.06L9.06 8l3.47 3.47a.75.75 0 1 1-1.06 1.06L8 9.06l-3.47 3.47a.75.75 0 0 1-1.06-1.06L6.94 8 3.47 4.53a.75.75 0 0 1 0-1.06',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `arrow-left` icon.
  static const HeroIconData arrowLeft = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M14.75 8a.75.75 0 0 1-.75.75H3.81l2.72 2.72a.75.75 0 1 1-1.06 1.06l-4-4a.75.75 0 0 1 0-1.06l4-4a.75.75 0 0 1 1.06 1.06L3.81 7.25H14a.75.75 0 0 1 .75.75',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `shuffle` icon.
  static const HeroIconData shuffle = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.75 12.5a.75.75 0 0 1 0-1.5h2.044c.86 0 1.644-.49 2.021-1.262L6.665 8l-.85-1.738A2.25 2.25 0 0 0 3.794 5H1.75a.75.75 0 1 1 0-1.5h2.044a3.75 3.75 0 0 1 3.369 2.103l.337.69.337-.69A3.75 3.75 0 0 1 11.206 3.5h1.233l-.97-.97a.75.75 0 0 1 1.061-1.06l2.25 2.25a.75.75 0 0 1 0 1.06l-2.25 2.25a.75.75 0 1 1-1.06-1.06l.97-.97h-1.234c-.86 0-1.644.49-2.021 1.262l-2.022 4.135A3.75 3.75 0 0 1 3.794 12.5zm6.639-1.542.696-1.424.1.204A2.25 2.25 0 0 0 11.206 11h1.233l-.97-.97a.75.75 0 1 1 1.061-1.06l2.25 2.25a.75.75 0 0 1 0 1.06l-2.25 2.25a.75.75 0 1 1-1.06-1.06l.97-.97h-1.234a3.75 3.75 0 0 1-2.905-1.378q.046-.08.088-.164',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `tray` icon.
  static const HeroIconData tray = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 8.5h-2.388a3.422 3.422 0 0 1-6.224 0H2.5V11A1.5 1.5 0 0 0 4 12.5h8a1.5 1.5 0 0 0 1.5-1.5zm-2.204-4.757L13.251 7H10l-.136.545a1.921 1.921 0 0 1-3.728 0L6 7H2.75l1.954-3.257a.5.5 0 0 1 .428-.243h5.736a.5.5 0 0 1 .428.243M15 8.5v-.67a3 3 0 0 0-.428-1.543l-1.99-3.316A2 2 0 0 0 10.869 2H5.132a2 2 0 0 0-1.715.971l-1.99 3.316A3 3 0 0 0 1 7.831V11a3 3 0 0 0 3 3h8a3 3 0 0 0 3-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `envelope-open` icon.
  static const HeroIconData envelopeOpen = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M14 6.498V11.5a1.5 1.5 0 0 1-1.5 1.5h-9A1.5 1.5 0 0 1 2 11.5V6.498l.001-.06L6.35 9.7a2.75 2.75 0 0 0 3.3 0l4.349-3.262zm-.806-1.33L8.74 2.642a1.5 1.5 0 0 0-1.48 0L2.806 5.167 7.25 8.5a1.25 1.25 0 0 0 1.5 0zM.5 6.497a3 3 0 0 1 1.521-2.61l4.5-2.55a3 3 0 0 1 2.958 0l4.5 2.55a3 3 0 0 1 1.521 2.61V11.5a3 3 0 0 1-3 3h-9a3 3 0 0 1-3-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `chart-column` icon.
  static const HeroIconData chartColumn = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.5 3.5h2a.5.5 0 0 1 .5.5v8a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1-.5-.5V4a.5.5 0 0 1 .5-.5m-2.5 9a.5.5 0 0 0 .5-.5V7a.5.5 0 0 0-.5-.5H7a.5.5 0 0 0-.5.5v5a.5.5 0 0 0 .5.5zm-4.5 0A.5.5 0 0 0 5 12v-2a.5.5 0 0 0-.5-.5h-2a.5.5 0 0 0-.5.5v2a.5.5 0 0 0 .5.5zm-1 1.5h-1a2 2 0 0 1-2-2v-2a2 2 0 0 1 2-2h2q.26 0 .5.063V7a2 2 0 0 1 2-2h2q.26 0 .5.063V4a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `chart-line` icon.
  static const HeroIconData chartLine = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M15.326 1.27a.75.75 0 0 1-.096 1.056l-3.674 3.062a2.75 2.75 0 0 1-2.55.522l-2.869-.86a1.25 1.25 0 0 0-1.214.285l-3.16 2.962A.75.75 0 1 1 .737 7.203l3.16-2.963a2.75 2.75 0 0 1 2.671-.628l2.868.86c.402.121.837.032 1.16-.236l3.674-3.062a.75.75 0 0 1 1.056.096m.113 6.185a.75.75 0 0 1-.393.984l-4.398 1.885a2.75 2.75 0 0 1-2.313-.068L6.186 9.182a1.25 1.25 0 0 0-1.238.068l-3.29 2.13a.75.75 0 0 1-.815-1.26l3.29-2.129a2.75 2.75 0 0 1 2.724-.15l2.149 1.073a1.25 1.25 0 0 0 1.051.031l4.398-1.884a.75.75 0 0 1 .984.394M1.25 12.5a.75.75 0 0 0 0 1.5h13.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `chart-pie` icon.
  static const HeroIconData chartPie = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.45 8.75a5.501 5.501 0 1 1-6.2-6.2V8c0 .414.336.75.75.75zm0-1.5h-4.7v-4.7a5.5 5.5 0 0 1 4.7 4.7M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `chart-area-stacked` icon.
  static const HeroIconData chartAreaStacked = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10.257 4.2a.86.86 0 0 1-.86.274l-3.103-.776a2.81 2.81 0 0 0-2.796.876L1.242 7.152A3 3 0 0 0 .5 9.127V12a2 2 0 0 0 2 2h11a2 2 0 0 0 2-2V3.309a1.933 1.933 0 0 0-3.4-1.258l-1.31 1.528zM14 6.48V3.31a.433.433 0 0 0-.762-.282l-1.842 2.15a2.36 2.36 0 0 1-2.362.753L5.93 5.154a1.31 1.31 0 0 0-1.303.408L2.37 8.139a1.5 1.5 0 0 0-.37.988v.685l2.304-1.44a2.59 2.59 0 0 1 2.458-.155l1.923.888a1.58 1.58 0 0 0 1.777-.317l.22-.22 1.575-1.574A1.86 1.86 0 0 1 14 6.479m-12 5.52c0 .277.226.501.5.501h11a.5.5 0 0 0 .5-.5V8.337a.4.4 0 0 0-.683-.283L11.523 9.85a3.08 3.08 0 0 1-3.466.618L6.134 9.58a1.09 1.09 0 0 0-1.035.066L2.353 11.36a.75.75 0 0 0-.353.637',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `chart-bar` icon.
  static const HeroIconData chartBar = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M6 4v1a.5.5 0 0 1-.5.5h-3A.5.5 0 0 1 2 5V4a.5.5 0 0 1 .5-.5h3A.5.5 0 0 1 6 4M2 7.5v1a.5.5 0 0 0 .5.5h7a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-7a.5.5 0 0 0-.5.5M2 11v1a.5.5 0 0 0 .5.5h11a.5.5 0 0 0 .5-.5v-1a.5.5 0 0 0-.5-.5h-11a.5.5 0 0 0-.5.5m-1.5.503V4a2 2 0 0 1 2-2h3a2 2 0 0 1 2 2v1q0 .26-.063.5H9.5a2 2 0 0 1 2 2v1q0 .26-.063.5H13.5a2 2 0 0 1 2 2v1a2 2 0 0 1-2 2h-11a2 2 0 0 1-2-2z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `folder` icon.
  static const HeroIconData folder = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm6.44 4.06.439.44H12.5A1.5 1.5 0 0 1 14 6v5a1.5 1.5 0 0 1-1.5 1.5h-9A1.5 1.5 0 0 1 2 11V4.5A1.5 1.5 0 0 1 3.5 3h1.257a1.5 1.5 0 0 1 1.061.44zM.5 4.5a3 3 0 0 1 3-3h1.257a3 3 0 0 1 2.122.879L7.5 3h5a3 3 0 0 1 3 3v5a3 3 0 0 1-3 3h-9a3 3 0 0 1-3-3zm4.25 2a.75.75 0 0 0 0 1.5h6.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `file` icon.
  static const HeroIconData file = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11 13.5H5A1.5 1.5 0 0 1 3.5 12V4A1.5 1.5 0 0 1 5 2.5h2V5a3 3 0 0 0 3 3h2.5v4a1.5 1.5 0 0 1-1.5 1.5m1.303-7a1.5 1.5 0 0 0-.242-.318L8.818 2.939a1.5 1.5 0 0 0-.318-.242V5A1.5 1.5 0 0 0 10 6.5zm.818-1.379A3 3 0 0 1 14 7.243V12a3 3 0 0 1-3 3H5a3 3 0 0 1-3-3V4a3 3 0 0 1 3-3h2.757a3 3 0 0 1 2.122.879z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `file-text` icon.
  static const HeroIconData fileText = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5 13.5h6a1.5 1.5 0 0 0 1.5-1.5V7.243a1.5 1.5 0 0 0-.44-1.061L8.819 2.939a1.5 1.5 0 0 0-1.06-.439H5A1.5 1.5 0 0 0 3.5 4v8A1.5 1.5 0 0 0 5 13.5m9-6.257a3 3 0 0 0-.879-2.122L9.88 1.88A3 3 0 0 0 7.757 1H5a3 3 0 0 0-3 3v8a3 3 0 0 0 3 3h6a3 3 0 0 0 3-3zM5 8.25a.75.75 0 0 1 .75-.75h4.5a.75.75 0 0 1 0 1.5h-4.5A.75.75 0 0 1 5 8.25m.75 2.25a.75.75 0 0 0 0 1.5h2.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `layout-side-content-left` icon.
  static const HeroIconData layoutSideContentLeft = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M6 3.5h6A1.5 1.5 0 0 1 13.5 5v6a1.5 1.5 0 0 1-1.5 1.5H6zm-1.5 0H4A1.5 1.5 0 0 0 2.5 5v6A1.5 1.5 0 0 0 4 12.5h.5zM1 5a3 3 0 0 1 3-3h8a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `layout-cells-large` icon.
  static const HeroIconData layoutCellsLarge = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12 3.5H8.75v3.75h4.75V5A1.5 1.5 0 0 0 12 3.5m1.5 5.25H8.75v3.75H12a1.5 1.5 0 0 0 1.5-1.5zm-6.25-1.5V3.5H4A1.5 1.5 0 0 0 2.5 5v2.25zM2.5 8.75h4.75v3.75H4A1.5 1.5 0 0 1 2.5 11zM4 2a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h8a3 3 0 0 0 3-3V5a3 3 0 0 0-3-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `layout-list` icon.
  static const HeroIconData layoutList = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4 3.5h1.25v2H2.5V5A1.5 1.5 0 0 1 4 3.5m2.75 2v-2H12A1.5 1.5 0 0 1 13.5 5v.5zM2.5 7h2.75v2H2.5zm0 3.5v.5A1.5 1.5 0 0 0 4 12.5h1.25v-2zm4.25 0v2H12a1.5 1.5 0 0 0 1.5-1.5v-.5zM13.5 9V7H6.75v2zM1 5a3 3 0 0 1 3-3h8a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `sliders` icon.
  static const HeroIconData sliders = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7.5 5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m1.405.75a3.001 3.001 0 0 1-5.81 0H1.747a.75.75 0 0 1 0-1.5h1.348a3.001 3.001 0 0 1 5.81 0h5.345a.75.75 0 0 1 0 1.5zm-7.158 4.5h5.345a3.001 3.001 0 0 1 5.811 0h1.347a.75.75 0 1 1 0 1.5h-1.347a3.001 3.001 0 0 1-5.81 0H1.746a.75.75 0 0 1 0-1.5m8.25-.75a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `square-list-ul` icon.
  static const HeroIconData squareListUl = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4.5 3h7A1.5 1.5 0 0 1 13 4.5v7a1.5 1.5 0 0 1-1.5 1.5h-7A1.5 1.5 0 0 1 3 11.5v-7A1.5 1.5 0 0 1 4.5 3m-3 1.5a3 3 0 0 1 3-3h7a3 3 0 0 1 3 3v7a3 3 0 0 1-3 3h-7a3 3 0 0 1-3-3zm4.75.75a1 1 0 1 1-2 0 1 1 0 0 1 2 0m1 0A.75.75 0 0 1 8 4.5h2.75a.75.75 0 0 1 0 1.5H8a.75.75 0 0 1-.75-.75M5.25 9a1 1 0 1 0 0-2 1 1 0 0 0 0 2m1 1.75a1 1 0 1 1-2 0 1 1 0 0 1 2 0M8 7.25a.75.75 0 0 0 0 1.5h2.75a.75.75 0 0 0 0-1.5zm-.75 3.5A.75.75 0 0 1 8 10h2.75a.75.75 0 0 1 0 1.5H8a.75.75 0 0 1-.75-.75',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `funnel` icon.
  static const HeroIconData funnel = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12.5 4c0 .174-.071.513-.885.888S9.538 5.5 8 5.5s-2.799-.237-3.615-.612C3.57 4.513 3.5 4.174 3.5 4s.071-.513.885-.888S6.462 2.5 8 2.5s2.799.237 3.615.612c.814.375.885.714.885.888m-1.448 2.66C10.158 6.888 9.115 7 8 7s-2.158-.113-3.052-.34l1.98 2.905c.21.308.322.672.322 1.044v3.37q.088.02.25.021c.422 0 .749-.14.95-.316.185-.162.3-.38.3-.684v-2.39c0-.373.112-.737.322-1.045zM8 1c3.314 0 6 1 6 3a3.24 3.24 0 0 1-.563 1.826l-3.125 4.584a.35.35 0 0 0-.062.2V13c0 1.5-1.25 2.5-2.75 2.5s-1.75-1-1.75-1v-3.89a.35.35 0 0 0-.061-.2L2.563 5.826A3.24 3.24 0 0 1 2 4c0-2 2.686-3 6-3m-.88 12.936q-.015-.008-.013-.01z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `arrow-down` icon.
  static const HeroIconData arrowDown = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 1.25a.75.75 0 0 1 .75.75v10.19l2.72-2.72a.75.75 0 1 1 1.06 1.06l-4 4a.75.75 0 0 1-1.06 0l-4-4a.75.75 0 1 1 1.06-1.06l2.72 2.72V2A.75.75 0 0 1 8 1.25',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `arrow-up-arrow-down` icon.
  static const HeroIconData arrowUpArrowDown = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.72 2.22a.75.75 0 0 1 1.06 0l3 3a.75.75 0 0 1-1.06 1.06L5 4.56v8.69a.75.75 0 0 1-1.5 0V4.56L1.78 6.28A.75.75 0 0 1 .72 5.22zM11.75 14a.75.75 0 0 1-.53-.22l-3-3a.75.75 0 1 1 1.06-1.06L11 11.44V2.75a.75.75 0 0 1 1.5 0v8.69l1.72-1.72a.75.75 0 1 1 1.06 1.06l-3 3a.75.75 0 0 1-.53.22',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `clock-fill` icon.
  static const HeroIconData clockFill = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m.75-10.5a.75.75 0 0 0-1.5 0V8a.75.75 0 0 0 .3.6l2 1.5a.75.75 0 1 0 .9-1.2l-1.7-1.275z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `person-plus` icon.
  static const HeroIconData personPlus = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 6.5a2 2 0 1 0 0-4 2 2 0 0 0 0 4M8 8a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7m1 1.225a.71.71 0 0 0-.679-.72A11 11 0 0 0 8 8.5c-3.85 0-7 2-7 4A2.5 2.5 0 0 0 3.5 15h8.75a.75.75 0 0 0 0-1.5H3.5a1 1 0 0 1-1-1c0-.204.22-.809 1.32-1.459C4.838 10.44 6.32 10 8 10q.088 0 .175.002c.442.008.825-.335.825-.777M13.75 8a.75.75 0 0 0-1.5 0v1.25H11a.75.75 0 0 0 0 1.5h1.25V12a.75.75 0 0 0 1.5 0v-1.25H15a.75.75 0 0 0 0-1.5h-1.25z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `person-xmark` icon.
  static const HeroIconData personXmark = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 6.5a2 2 0 1 0 0-4 2 2 0 0 0 0 4M8 8a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7m1 1.225a.71.71 0 0 0-.679-.72A11 11 0 0 0 8 8.5c-3.85 0-7 2-7 4A2.5 2.5 0 0 0 3.5 15h8.75a.75.75 0 0 0 0-1.5H3.5a1 1 0 0 1-1-1c0-.204.22-.809 1.32-1.459C4.838 10.44 6.32 10 8 10q.088 0 .175.002c.442.008.825-.335.825-.777m4-.286-.97-.97a.75.75 0 1 0-1.06 1.061l.97.97-.97.97a.75.75 0 1 0 1.06 1.06l.97-.97.97.97a.75.75 0 1 0 1.06-1.06l-.97-.97.97-.97a.75.75 0 0 0-1.06-1.06z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `persons-lock` icon.
  static const HeroIconData personsLock = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.5 4.5a1 1 0 1 0 0-2 1 1 0 0 0 0 2m0 1.5a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5m-.75 1.25a.75.75 0 0 1 .75-.75c1.238 0 2.363.385 3.178.962C15.496 8.04 16 8.81 16 9.577a1.923 1.923 0 0 1-1.923 1.923h-.327a.75.75 0 0 1 0-1.5h.327c.234 0 .423-.19.423-.423 0-.105-.099-.474-.688-.89C13.257 8.293 12.437 8 11.5 8a.75.75 0 0 1-.75-.75M2.188 8.686C2.743 8.294 3.563 8 4.5 8a.75.75 0 0 0 0-1.5c-1.238 0-2.363.385-3.178.962C.504 8.04 0 8.81 0 9.577 0 10.639.861 11.5 1.923 11.5h.327a.75.75 0 0 0 0-1.5h-.327a.423.423 0 0 1-.423-.423c0-.105.099-.474.688-.89M4.5 4.5a1 1 0 1 0 0-2 1 1 0 0 0 0 2m0 1.5a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5m6.25 3.5h-.25V9a2.5 2.5 0 1 0-5 0v.5h-.25c-.69 0-1.25.56-1.25 1.25v3c0 .69.56 1.25 1.25 1.25h5.5c.69 0 1.25-.56 1.25-1.25v-3c0-.69-.56-1.25-1.25-1.25M9 9v.5H7V9a1 1 0 1 1 2 0m-3.5 2v2.5h5V11z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `comments` icon.
  static const HeroIconData comments = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10 9.5h.621l.44.44 1.51 1.51a.174.174 0 0 0 .295-.136l-.112-1.454-.062-.809.642-.495C14.037 8.016 14.5 7.211 14.5 6c0-1.214-.465-2.019-1.17-2.56-.754-.578-1.902-.94-3.33-.94s-2.576.362-3.33.94C5.966 3.98 5.5 4.786 5.5 6s.465 2.019 1.17 2.56c.754.578 1.902.94 3.33.94m.52 2.02.99.99a1.673 1.673 0 0 0 2.851-1.312l-.111-1.453C15.33 8.91 16 7.663 16 6c0-3.333-2.686-5-6-5-2.127 0-3.995.687-5.06 2.06C2.131 3.384 0 5.03 0 8c0 1.663.669 2.911 1.75 3.745l-.111 1.453A1.673 1.673 0 0 0 4.49 14.51L6 13c1.803 0 3.42-.493 4.52-1.48M4.143 4.736Q4.001 5.32 4 6c0 2.905 2.04 4.544 4.759 4.918-.717.366-1.654.582-2.759.582h-.621l-.44.44-1.51 1.51a.174.174 0 0 1-.295-.136l.112-1.454.062-.809-.642-.495C1.963 10.016 1.5 9.211 1.5 8c0-1.214.465-2.019 1.17-2.56.391-.3.887-.541 1.473-.704',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `comment-dot` icon.
  static const HeroIconData commentDot = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.98 3.677C4.913 2.94 6.305 2.5 8 2.5a9 9 0 0 1 .924.046.75.75 0 0 0 .152-1.492A11 11 0 0 0 8 1c-1.933 0-3.683.5-4.95 1.5C1.784 3.5 1 5 1 7c0 2.117.878 3.674 2.277 4.67l-.123 1.484a1.704 1.704 0 0 0 2.83 1.415l1.77-1.572Q7.875 13 8 13c1.933 0 3.683-.5 4.95-1.5C14.216 10.5 15 9 15 7a.75.75 0 0 0-1.5 0c0 1.563-.59 2.62-1.48 3.323C11.087 11.06 9.695 11.5 8 11.5q-.108 0-.213-.002l-.295-.007-.295-.006-.22.195-1.99 1.768a.204.204 0 0 1-.338-.17l.159-1.909.035-.425-.348-.248-.347-.248C3.156 9.743 2.5 8.648 2.5 7c0-1.563.59-2.62 1.48-3.323M12.5 5.5a2 2 0 1 0 0-4 2 2 0 0 0 0 4',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `paper-plane` icon.
  static const HeroIconData paperPlane = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7.29 13.904 5.25 10.75 2.096 8.71a2.4 2.4 0 0 1 .5-4.278l9.273-3.296a2.346 2.346 0 0 1 2.996 2.995L13.45 3.63a.844.844 0 0 0-1.08-1.08L3.1 5.846a.9.9 0 0 0-.19 1.604l2.78 1.799 3.279-3.28a.75.75 0 1 1 1.06 1.061L6.75 10.31l1.799 2.779a.9.9 0 0 0 1.604-.188l3.297-9.272 1.413.502-3.296 9.273a2.4 2.4 0 0 1-4.277.5',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `face-smile` icon.
  static const HeroIconData faceSmile = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 8a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0M6.67 9.665a.75.75 0 0 0-1.34.67c.403.809 1.452 1.415 2.67 1.415s2.267-.606 2.67-1.415a.75.75 0 1 0-1.34-.67c-.097.191-.548.585-1.33.585s-1.233-.394-1.33-.585M10 8a.75.75 0 0 1-.75-.75v-1a.75.75 0 0 1 1.5 0v1A.75.75 0 0 1 10 8m-4.75-.75a.75.75 0 0 0 1.5 0v-1a.75.75 0 0 0-1.5 0z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `graph-node` icon.
  static const HeroIconData graphNode = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5.75 2.5h4.5a1.5 1.5 0 0 1 1.269.7 2.5 2.5 0 0 0 .231 4.686V12a1.5 1.5 0 0 1-1.5 1.5h-4.5c-.534 0-1.003-.28-1.269-.7a2.5 2.5 0 0 0-.231-4.686v-.228A2.501 2.501 0 0 0 4.481 3.2c.266-.42.735-.7 1.269-.7m-3 5.614v-.228a2.501 2.501 0 0 1 .146-4.812A3 3 0 0 1 5.75 1h4.5a3 3 0 0 1 2.854 2.074 2.501 2.501 0 0 1 .146 4.812V12a3 3 0 0 1-3 3h-4.5a3 3 0 0 1-2.854-2.073 2.501 2.501 0 0 1-.146-4.813M3.5 11.5a1 1 0 1 0 0-2 1 1 0 0 0 0 2m-1-6a1 1 0 1 1 2 0 1 1 0 0 1-2 0m10-1a1 1 0 1 0 0 2 1 1 0 0 0 0-2',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `wallet` icon.
  static const HeroIconData wallet = HeroIconData(<HeroIconPath>[
    HeroIconPath('M10.753 8.005a.75.75 0 0 1 0 1.5h-1a.75.75 0 0 1 0-1.5z'),
    HeroIconPath(
      'M12.75 1.5a.75.75 0 0 1 0 1.5H3.195a.7.7 0 0 0-.698.7l.004.081a.8.8 0 0 0 .796.718h8.96a2.75 2.75 0 0 1 2.75 2.75v4.5a2.75 2.75 0 0 1-2.75 2.75h-8.51a2.75 2.75 0 0 1-2.75-2.75V3.7c0-1.215.984-2.2 2.198-2.2zM2.497 11.75c0 .69.56 1.25 1.25 1.25h8.51c.691 0 1.25-.56 1.25-1.25v-4.5c0-.69-.56-1.25-1.25-1.25h-8.96c-.281 0-.55-.054-.8-.146z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `shopping-cart` icon.
  static const HeroIconData shoppingCart = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.018 3.068 3.395 4.5 4.58 9.005a3 3 0 0 0 4.186 1.948l4.518-2.14A3 3 0 0 0 15 6.102V5a2 2 0 0 0-2-2H4.556l-.15-.535A2 2 0 0 0 2.48 1H.75a.75.75 0 0 0 0 1.5h1.73a.5.5 0 0 1 .482.366zm5.106 6.53 4.518-2.14a1.5 1.5 0 0 0 .858-1.356V5a.5.5 0 0 0-.5-.5H4.946L6.03 8.624a1.5 1.5 0 0 0 2.093.973M12 14.75a1.75 1.75 0 1 0 0-3.5 1.75 1.75 0 0 0 0 3.5M4.75 13a1.75 1.75 0 1 1-3.5 0 1.75 1.75 0 0 1 3.5 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `tag` icon.
  static const HeroIconData tag = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm13.06 8.818-4.869 4.87a1 1 0 0 1-1.408.006l-4.45-4.37a1 1 0 0 1-.012-1.414l4.868-4.96a1.5 1.5 0 0 1 1.07-.45H12.5a1 1 0 0 1 1 1v4.257a1.5 1.5 0 0 1-.44 1.061m-6.942-6.92A3 3 0 0 1 8.259 1H12.5A2.5 2.5 0 0 1 15 3.5v4.257a3 3 0 0 1-.879 2.122l-4.87 4.87a2.5 2.5 0 0 1-3.519.015l-4.45-4.37a2.5 2.5 0 0 1-.032-3.535zM10.5 6.5a1.25 1.25 0 1 1 0-2.5 1.25 1.25 0 0 1 0 2.5',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `tags` icon.
  static const HeroIconData tags = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm10.884 6.995-4.12 4.12a.75.75 0 0 1-1.055.005L1.906 7.395a.75.75 0 0 1-.011-1.06l4.118-4.21a1.25 1.25 0 0 1 .894-.375H10.5a.75.75 0 0 1 .75.75v3.61c0 .332-.132.65-.366.885M4.94 1.077A2.75 2.75 0 0 1 6.907.25H10.5a2.25 2.25 0 0 1 2.25 2.25v.75h.75a2.25 2.25 0 0 1 2.25 2.25v3.61c0 .73-.29 1.43-.806 1.946l-4.12 4.12a2.25 2.25 0 0 1-3.165.016l-3.803-3.726a2.3 2.3 0 0 1-.286-.341L.856 8.466a2.25 2.25 0 0 1-.033-3.18zm2.242 11.548a2.3 2.3 0 0 0 .642-.45L11.52 8.48q.11.021.229.021a1.25 1.25 0 0 0 .976-2.03q.024-.178.024-.36V4.75h.75a.75.75 0 0 1 .75.75v3.61c0 .332-.132.65-.366.885l-4.12 4.12a.75.75 0 0 1-1.055.005zM8.75 5.5a1.25 1.25 0 1 1 0-2.5 1.25 1.25 0 0 1 0 2.5',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `flag` icon.
  static const HeroIconData flag = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7.47 3.588a4.45 4.45 0 0 0-4.15-.224.55.55 0 0 0-.32.499v5.533a6.25 6.25 0 0 1 5.547.439l.344.207a4.02 4.02 0 0 0 3.865.148.44.44 0 0 0 .244-.395V4.182a6.26 6.26 0 0 1-5.386-.508zm5.957 7.944a5.52 5.52 0 0 1-5.307-.204l-.345-.207a4.75 4.75 0 0 0-4.314-.293L3 11.026v3.255a.75.75 0 0 1-1.5 0V3.863c0-.8.465-1.526 1.19-1.861a5.95 5.95 0 0 1 5.552.3l.144.086a4.76 4.76 0 0 0 4.447.24l.603-.278a.75.75 0 0 1 1.064.681v6.764c0 .735-.416 1.408-1.073 1.737',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `map-pin` icon.
  static const HeroIconData mapPin = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.125 7a4.875 4.875 0 1 1 9.75 0c0 1.864-.774 2.962-1.687 3.815-.385.36-.765.65-1.17.958l-.365.28a9 9 0 0 0-.781.668c-.243.24-.535.575-.73 1.01a.34.34 0 0 1-.095.132l-.015.008s-.01.004-.032.004l-.032-.003-.015-.009a.34.34 0 0 1-.095-.131 3.4 3.4 0 0 0-.73-1.01 9 9 0 0 0-.781-.668q-.187-.145-.366-.28a15 15 0 0 1-1.169-.96C3.9 9.963 3.125 8.865 3.125 7M14.5 7c0 3.4-2.066 4.975-3.53 6.091-.634.485-1.156.882-1.345 1.305C9.355 15 8.788 15.5 8 15.5s-1.354-.5-1.625-1.104c-.19-.423-.71-.82-1.346-1.305C3.566 11.975 1.5 10.399 1.5 7a6.5 6.5 0 0 1 13 0m-5 0a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0M11 7a3 3 0 1 1-6 0 3 3 0 0 1 6 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `location-arrow` icon.
  static const HeroIconData locationArrow = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7.16 13.134 6.5 9.5l-3.634-.66a2.272 2.272 0 0 1-.355-4.377l9.358-3.327a2.346 2.346 0 0 1 2.996 2.995l-3.328 9.358a2.272 2.272 0 0 1-4.376-.355m2.964-.148L13.45 3.63a.844.844 0 0 0-1.08-1.08L3.014 5.876a.772.772 0 0 0 .12 1.487l3.634.661 1.022.186.186 1.022.66 3.634a.772.772 0 0 0 1.488.12',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `camera` icon.
  static const HeroIconData camera = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4.273 5h1.05l.36-.987.248-.684A.5.5 0 0 1 6.401 3h3.198a.5.5 0 0 1 .47.33l.249.683.359.987H12a1.5 1.5 0 0 1 1.5 1.5V11a1.5 1.5 0 0 1-1.5 1.5H4A1.5 1.5 0 0 1 2.5 11V6.5A1.5 1.5 0 0 1 4 5zM6.4 1.5a2 2 0 0 0-1.88 1.317l-.248.683H4a3 3 0 0 0-3 3V11a3 3 0 0 0 3 3h8a3 3 0 0 0 3-3V6.5a3 3 0 0 0-3-3h-.273l-.248-.683A2 2 0 0 0 9.599 1.5zm3.099 7a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m1.5 0a3 3 0 1 1-6 0 3 3 0 0 1 6 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `headphones` icon.
  static const HeroIconData headphones = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M15 8A7 7 0 1 0 1 8v4h.01a3.25 3.25 0 0 0 3.24 3h.083C5.253 15 6 14.254 6 13.333v-3.166C6 9.247 5.254 8.5 4.333 8.5H4.25c-.644 0-1.245.188-1.75.51V8a5.5 5.5 0 1 1 11 0v1.01a3.24 3.24 0 0 0-1.75-.51h-.083c-.92 0-1.667.746-1.667 1.667v3.166c0 .92.746 1.667 1.667 1.667h.083a3.25 3.25 0 0 0 3.24-3H15zm-1.5 3.75A1.75 1.75 0 0 0 11.75 10h-.083a.167.167 0 0 0-.167.167v3.166c0 .092.075.167.167.167h.083a1.75 1.75 0 0 0 1.75-1.75M4.25 13.5a1.75 1.75 0 1 1 0-3.5h.083c.092 0 .167.075.167.167v3.166a.167.167 0 0 1-.167.167z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `star-fill` icon.
  static const HeroIconData starFill = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M6.886.773C7.29-.231 8.71-.231 9.114.773l1.472 3.667 3.943.268c1.08.073 1.518 1.424.688 2.118L12.185 9.36l.964 3.832c.264 1.05-.886 1.884-1.802 1.31L8 12.4l-3.347 2.101c-.916.575-2.066-.26-1.802-1.309l.964-3.832L.783 6.826c-.83-.694-.391-2.045.688-2.118l3.943-.268z',
    ),
  ]);

  /// Gravity UI `lock` icon.
  static const HeroIconData lock = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10.5 6V5a2.5 2.5 0 0 0-5 0v1zM4 5v1a3 3 0 0 0-3 3v3a3 3 0 0 0 3 3h8a3 3 0 0 0 3-3V9a3 3 0 0 0-3-3V5a4 4 0 0 0-8 0m6.5 2.5H12A1.5 1.5 0 0 1 13.5 9v3a1.5 1.5 0 0 1-1.5 1.5H4A1.5 1.5 0 0 1 2.5 12V9A1.5 1.5 0 0 1 4 7.5zm-1.75 2a.75.75 0 0 0-1.5 0v2a.75.75 0 0 0 1.5 0z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `key` icon.
  static const HeroIconData key = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10.313 7.488 9 7.653v5.37a.5.5 0 0 1-.353.478l-1.62.498-.006.001h-.008l-.007-.006-.005-.007v-.003L7 13.979V7.653l-1.313-.165a1.5 1.5 0 0 1-1.271-1.144l-.588-2.5A1.5 1.5 0 0 1 5.288 2h5.424a1.5 1.5 0 0 1 1.46 1.844l-.588 2.5a1.5 1.5 0 0 1-1.271 1.144m2.731-.8A3 3 0 0 1 10.5 8.976v4.046a2 2 0 0 1-1.412 1.911l-1.62.499A1.52 1.52 0 0 1 5.5 13.979V8.977a3 3 0 0 1-2.544-2.29l-.588-2.5A3 3 0 0 1 5.288.5h5.424a3 3 0 0 1 2.92 3.687zM6.75 3.5a.75.75 0 0 0 0 1.5h2.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `shield` icon.
  static const HeroIconData shield = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm3.003 4.702 4.22-2.025a1.8 1.8 0 0 1 1.554 0l4.22 2.025a.89.89 0 0 1 .503.8V6a8.55 8.55 0 0 1-3.941 7.201l-.986.631a1.06 1.06 0 0 1-1.146 0l-.986-.63A8.55 8.55 0 0 1 2.5 6v-.498c0-.341.196-.652.503-.8m3.57-3.377L2.354 3.35A2.39 2.39 0 0 0 1 5.502V6a10.05 10.05 0 0 0 4.632 8.465l.986.63a2.56 2.56 0 0 0 2.764 0l.986-.63A10.05 10.05 0 0 0 15 6v-.498c0-.918-.526-1.755-1.354-2.152l-4.22-2.025a3.3 3.3 0 0 0-2.852 0M8.47 9.97a.75.75 0 1 0 1.06 1.06c.575-.574 1.118-1.398 1.516-2.195.386-.772.704-1.653.704-2.335a.75.75 0 0 0-1.5 0c0 .318-.182.937-.546 1.665-.352.703-.809 1.379-1.234 1.805',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `shield-check` icon.
  static const HeroIconData shieldCheck = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm3.003 4.702 4.22-2.025a1.8 1.8 0 0 1 1.554 0l4.22 2.025a.89.89 0 0 1 .503.8V6a8.55 8.55 0 0 1-3.941 7.201l-.986.631a1.06 1.06 0 0 1-1.146 0l-.986-.63A8.55 8.55 0 0 1 2.5 6v-.498c0-.341.196-.652.503-.8m3.57-3.377L2.354 3.35A2.39 2.39 0 0 0 1 5.502V6a10.05 10.05 0 0 0 4.632 8.465l.986.63a2.56 2.56 0 0 0 2.764 0l.986-.63A10.05 10.05 0 0 0 15 6v-.498c0-.918-.526-1.755-1.354-2.152l-4.22-2.025a3.3 3.3 0 0 0-2.852 0M11.1 6.45a.75.75 0 1 0-1.2-.9L7.419 8.858 6.03 7.47a.75.75 0 0 0-1.06 1.06l2 2a.75.75 0 0 0 1.13-.08z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-plus` icon.
  static const HeroIconData circlePlus = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 8a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0M8.75 5.5a.75.75 0 0 0-1.5 0v1.75H5.5a.75.75 0 1 0 0 1.5h1.75v1.75a.75.75 0 0 0 1.5 0V8.75h1.75a.75.75 0 0 0 0-1.5H8.75z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-minus` icon.
  static const HeroIconData circleMinus = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 8a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0m-9.5-.75a.75.75 0 1 0 0 1.5h5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `circle-exclamation` icon.
  static const HeroIconData circleExclamation = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 13.5a5.5 5.5 0 1 0 0-11 5.5 5.5 0 0 0 0 11M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14m1-4.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0M8.75 5a.75.75 0 0 0-1.5 0v2.5a.75.75 0 0 0 1.5 0z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `octagon-xmark` icon.
  static const HeroIconData octagonXmark = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5.829 2.5h4.342a.5.5 0 0 1 .354.146l2.829 2.829a.5.5 0 0 1 .146.353v4.344a.5.5 0 0 1-.146.353l-2.829 2.829a.5.5 0 0 1-.354.146H5.83a.5.5 0 0 1-.354-.146l-2.829-2.829a.5.5 0 0 1-.146-.354V5.829a.5.5 0 0 1 .147-.353l2.828-2.829a.5.5 0 0 1 .354-.146m-1.415-.914A2 2 0 0 1 5.83 1h4.342a2 2 0 0 1 1.415.586l2.828 2.828A2 2 0 0 1 15 5.828v4.343a2 2 0 0 1-.586 1.415l-2.828 2.828A2 2 0 0 1 10.17 15H5.83a2 2 0 0 1-1.415-.586l-2.828-2.828A2 2 0 0 1 1 10.17V5.828a2 2 0 0 1 .586-1.414zM6.53 5.47a.75.75 0 1 0-1.06 1.06L6.94 8 5.47 9.47a.75.75 0 1 0 1.06 1.06L8 9.06l1.47 1.47a.75.75 0 1 0 1.06-1.06L9.06 8l1.47-1.47a.75.75 0 1 0-1.06-1.06L8 6.94z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `grip` icon.
  static const HeroIconData grip = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7 3a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0M5.5 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3m5 0a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3m0-5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3M7 13a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m3.5 1.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `grip-horizontal` icon.
  static const HeroIconData gripHorizontal = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3 9a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3m6.5 1.5a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0m0-5a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0m-5 0a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0M13 9a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3m1.5-3.5a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `dots-9` icon.
  static const HeroIconData dots9 = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M9.5 3a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0M3 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3M9.5 8a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m5 0a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0M13 4.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3M4.5 3a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0M8 14.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3m6.5-1.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0M3 14.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `arrow-rotate-right` icon.
  static const HeroIconData arrowRotateRight = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 1.5a6.5 6.5 0 1 0 6.445 7.348.75.75 0 1 0-1.487-.194A5.001 5.001 0 1 1 11.57 4.5h-1.32a.75.75 0 0 0 0 1.5h3a.75.75 0 0 0 .75-.75v-3a.75.75 0 0 0-1.5 0v1.06A6.48 6.48 0 0 0 8 1.5',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `cloud` icon.
  static const HeroIconData cloud = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4.5 6.25a3.25 3.25 0 0 1 6.051-1.65 4.5 4.5 0 0 0-2.35 1.34A.75.75 0 0 0 9.3 6.96a3 3 0 0 1 2.3-.958A3 3 0 0 1 11.5 12H3.75a2.25 2.25 0 0 1-.002-4.5h.03a.75.75 0 0 0 .747-.843A3 3 0 0 1 4.5 6.25M7.75 1.5a4.75 4.75 0 0 0-4.747 4.574A3.751 3.751 0 0 0 3.75 13.5h7.75a4.5 4.5 0 0 0 .687-8.948A4.75 4.75 0 0 0 7.75 1.5',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `cloud-arrow-up-in` icon.
  static const HeroIconData cloudArrowUpIn = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4.5 5.25a3.25 3.25 0 0 1 6.398-.811.75.75 0 0 0 .702.563A3 3 0 0 1 11.5 11h-.75a.75.75 0 0 0 0 1.5h.75a4.5 4.5 0 0 0 .687-8.948 4.751 4.751 0 0 0-9.184 1.522A3.751 3.751 0 0 0 3.75 12.5h1.5a.75.75 0 0 0 0-1.5H3.751a2.25 2.25 0 0 1-.003-4.5h.03a.75.75 0 0 0 .747-.843A3 3 0 0 1 4.5 5.25m4.25 3.31.72.72a.75.75 0 1 0 1.06-1.06l-2-2a.75.75 0 0 0-1.06 0l-2 2a.75.75 0 0 0 1.06 1.06l.72-.72v6.69a.75.75 0 0 0 1.5 0z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `archive` icon.
  static const HeroIconData archive = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M2.5 8h11v3a1.5 1.5 0 0 1-1.5 1.5H4A1.5 1.5 0 0 1 2.5 11zm10.697-1.5-1.851-2.777a.5.5 0 0 0-.416-.223H5.07a.5.5 0 0 0-.416.223L2.803 6.5zM15 7.408V11a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3V7.408a3 3 0 0 1 .504-1.664l1.902-2.853A2 2 0 0 1 5.07 2h5.86a2 2 0 0 1 1.664.89l1.902 2.854A3 3 0 0 1 15 7.408M9.25 11a.75.75 0 0 0 0-1.5h-2.5a.75.75 0 0 0 0 1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `pencil-to-square` icon.
  static const HeroIconData pencilToSquare = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M6.169 6.331a3 3 0 0 0-.833 1.6l-.338 1.912a1 1 0 0 0 1.159 1.159l1.912-.338a3 3 0 0 0 1.6-.833l3.07-3.07 2-2A.9.9 0 0 0 15 4.13 3.13 3.13 0 0 0 11.87 1a.9.9 0 0 0-.632.262l-2 2zm3.936-1.814L7.229 7.392a1.5 1.5 0 0 0-.416.8L6.6 9.4l1.208-.213.057-.01a1.5 1.5 0 0 0 .743-.406l2.875-2.876a1.63 1.63 0 0 0-1.378-1.378m2.558.199a3.14 3.14 0 0 0-1.379-1.38l.82-.82a1.63 1.63 0 0 1 1.38 1.38zM8 2.25a.75.75 0 0 0-.75-.75H4.5a3 3 0 0 0-3 3v7a3 3 0 0 0 3 3h7a3 3 0 0 0 3-3V8.75a.75.75 0 0 0-1.5 0v2.75a1.5 1.5 0 0 1-1.5 1.5h-7A1.5 1.5 0 0 1 3 11.5v-7A1.5 1.5 0 0 1 4.5 3h2.75A.75.75 0 0 0 8 2.25',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `square-dashed` icon.
  static const HeroIconData squareDashed = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4.5 3A1.5 1.5 0 0 0 3 4.5v1.75a.75.75 0 0 1-1.5 0V4.5a3 3 0 0 1 3-3h1.75a.75.75 0 0 1 0 1.5zM9 2.25a.75.75 0 0 1 .75-.75h1.75a3 3 0 0 1 3 3v1.75a.75.75 0 0 1-1.5 0V4.5A1.5 1.5 0 0 0 11.5 3H9.75A.75.75 0 0 1 9 2.25M2.25 9a.75.75 0 0 1 .75.75v1.75A1.5 1.5 0 0 0 4.5 13h1.75a.75.75 0 0 1 0 1.5H4.5a3 3 0 0 1-3-3V9.75A.75.75 0 0 1 2.25 9m11.5 0a.75.75 0 0 1 .75.75v1.75a3 3 0 0 1-3 3H9.75a.75.75 0 0 1 0-1.5h1.75a1.5 1.5 0 0 0 1.5-1.5V9.75a.75.75 0 0 1 .75-.75',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `square` icon.
  static const HeroIconData square = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.5 3h-7A1.5 1.5 0 0 0 3 4.5v7A1.5 1.5 0 0 0 4.5 13h7a1.5 1.5 0 0 0 1.5-1.5v-7A1.5 1.5 0 0 0 11.5 3m-7-1.5a3 3 0 0 0-3 3v7a3 3 0 0 0 3 3h7a3 3 0 0 0 3-3v-7a3 3 0 0 0-3-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `check-shape` icon.
  static const HeroIconData checkShape = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M6.943 8.703 4.301 6.3a.25.25 0 0 0-.355.02L2.299 8.171a.25.25 0 0 0 .023.355l4.785 4.147a.25.25 0 0 0 .36-.032L13.29 5.36a.25.25 0 0 0-.03-.343l-1.856-1.65a.25.25 0 0 0-.364.034zM6.75 6.5l3.104-4.017a1.75 1.75 0 0 1 2.547-.238l1.857 1.651a1.75 1.75 0 0 1 .204 2.401L8.637 13.58a1.75 1.75 0 0 1-2.512.229L1.339 9.66a1.75 1.75 0 0 1-.162-2.486l1.647-1.852A1.75 1.75 0 0 1 5.31 5.19z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `display` icon.
  static const HeroIconData display = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12 3H4a1.5 1.5 0 0 0-1.5 1.5v4A1.5 1.5 0 0 0 4 10h8a1.5 1.5 0 0 0 1.5-1.5v-4A1.5 1.5 0 0 0 12 3M4 1.5a3 3 0 0 0-3 3v4a3 3 0 0 0 3 3h3.25V13h-2.5a.75.75 0 0 0 0 1.5h6.5a.75.75 0 0 0 0-1.5h-2.5v-1.5H12a3 3 0 0 0 3-3v-4a3 3 0 0 0-3-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `smartphone` icon.
  static const HeroIconData smartphone = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12 3.5v9a1.5 1.5 0 0 1-1.5 1.5h-5A1.5 1.5 0 0 1 4 12.5v-9A1.5 1.5 0 0 1 5.5 2h5A1.5 1.5 0 0 1 12 3.5m-1.5-3a3 3 0 0 1 3 3v9a3 3 0 0 1-3 3h-5a3 3 0 0 1-3-3v-9a3 3 0 0 1 3-3zM6.25 11a.75.75 0 0 0 0 1.5h3.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `code` icon.
  static const HeroIconData code = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10.218 3.216a.75.75 0 0 0-1.436-.431l-3 10a.75.75 0 0 0 1.436.43zM4.53 4.97a.75.75 0 0 1 0 1.06L2.56 8l1.97 1.97a.75.75 0 0 1-1.06 1.06l-2.5-2.5a.75.75 0 0 1 0-1.06l2.5-2.5a.75.75 0 0 1 1.06 0m6.94 6.06a.75.75 0 0 1 0-1.06L13.44 8l-1.97-1.97a.75.75 0 0 1 1.06-1.06l2.5 2.5a.75.75 0 0 1 0 1.06l-2.5 2.5a.75.75 0 0 1-1.06 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `terminal` icon.
  static const HeroIconData terminal = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12 3.5H4A1.5 1.5 0 0 0 2.5 5v6A1.5 1.5 0 0 0 4 12.5h8a1.5 1.5 0 0 0 1.5-1.5V5A1.5 1.5 0 0 0 12 3.5M4 2a3 3 0 0 0-3 3v6a3 3 0 0 0 3 3h8a3 3 0 0 0 3-3V5a3 3 0 0 0-3-3zm.47 8.53a.75.75 0 0 1 0-1.06L5.94 8 4.47 6.53a.75.75 0 0 1 1.06-1.06l2 2a.75.75 0 0 1 0 1.06l-2 2a.75.75 0 0 1-1.06 0M8.75 9.5a.75.75 0 0 0 0 1.5h2.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `cube` icon.
  static const HeroIconData cube = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.5 5.475v4.946a1.5 1.5 0 0 1-.973 1.405l-4.777 1.79V7.53zm-.654-1.36a2 2 0 0 0-.175-.103L9.499 2.427a1.5 1.5 0 0 0-1.197-.063l-4.829 1.81q-.12.045-.23.11L7.05 6.185zM2.5 5.59l3.75 1.875v5.984l-2.92-1.46a1.5 1.5 0 0 1-.83-1.342zM1.267 4.343c-.173.38-.267.8-.267 1.236v5.067a3 3 0 0 0 1.658 2.683l3.172 1.586a3 3 0 0 0 2.395.126l4.828-1.811A3 3 0 0 0 15 10.421V5.354a3 3 0 0 0-1.658-2.683L10.17 1.085A3 3 0 0 0 7.775.959L2.947 2.77a3 3 0 0 0-1.48 1.203.75.75 0 0 0-.2.37',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `layers` icon.
  static const HeroIconData layers = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm2.789 5.283 4.037-2.02A2.5 2.5 0 0 1 7.944 3h.112c.388 0 .77.09 1.118.264l4.037 2.019a.522.522 0 0 1 0 .934l-4.037 2.02a2.5 2.5 0 0 1-1.118.263h-.112a2.5 2.5 0 0 1-1.118-.264L2.79 6.217a.523.523 0 0 1 0-.934M1 5.75c0-.766.433-1.466 1.118-1.809l4.037-2.019a4 4 0 0 1 1.79-.422h.11a4 4 0 0 1 1.79.422l4.037 2.019a2.023 2.023 0 0 1 0 3.618l-.882.44.882.442a2.023 2.023 0 0 1 0 3.618l-4.037 2.019a4 4 0 0 1-1.79.422h-.11a4 4 0 0 1-1.79-.422l-4.037-2.02a2.023 2.023 0 0 1 0-3.617L3 8l-.882-.441A2.02 2.02 0 0 1 1 5.75m3.677 3.088-1.888.945a.523.523 0 0 0 0 .934l4.037 2.019A2.5 2.5 0 0 0 7.944 13h.112a2.5 2.5 0 0 0 1.118-.264l4.037-2.019a.523.523 0 0 0 0-.934l-1.888-.945-1.478.74a4 4 0 0 1-1.79.422h-.11a4 4 0 0 1-1.79-.422z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `database` icon.
  static const HeroIconData database = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.615 4.888c.814-.375.885-.714.885-.888s-.071-.513-.885-.888S9.538 2.5 8 2.5s-2.799.237-3.615.612C3.57 3.487 3.5 3.826 3.5 4s.071.513.885.888S6.462 5.5 8 5.5s2.799-.237 3.615-.612m.885 1.235C11.4 6.708 9.792 7 8 7s-3.4-.292-4.5-.877V8c0 .174.071.513.885.888S6.462 9.5 8 9.5s2.799-.237 3.615-.612c.814-.375.885-.714.885-.888zm0 4C11.4 10.708 9.792 11 8 11s-3.4-.293-4.5-.877V12c0 .174.071.513.885.887.816.377 2.077.613 3.615.613s2.799-.236 3.615-.613c.814-.374.885-.713.885-.887zM14 4c0-2-2.686-3-6-3S2 2 2 4v8c0 2 2.686 3 6 3s6-1 6-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `server` icon.
  static const HeroIconData server = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4 3.5h8A1.5 1.5 0 0 1 13.5 5v2.25h-11V5A1.5 1.5 0 0 1 4 3.5M2.5 8.75V11A1.5 1.5 0 0 0 4 12.5h8a1.5 1.5 0 0 0 1.5-1.5V8.75zM1 5a3 3 0 0 1 3-3h8a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3zm2.75.5a.75.75 0 0 1 .75-.75H7a.75.75 0 0 1 0 1.5H4.5a.75.75 0 0 1-.75-.75m.75 4.25a.75.75 0 0 0 0 1.5H7a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `bug` icon.
  static const HeroIconData bug = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M5.865.031a.75.75 0 0 1 .918.53l.531 1.981a5.55 5.55 0 0 1 2.384.225 2.5 2.5 0 1 1 3.535 3.535 5.5 5.5 0 0 1 .225 2.384l1.98.53a.75.75 0 0 1-.388 1.45l-1.98-.531q-.271.64-.687 1.188l1.45 1.45a.75.75 0 0 1-1.06 1.06l-1.45-1.45a5.5 5.5 0 0 1-1.188.687l.53 1.98a.75.75 0 1 1-1.448.388l-.531-1.98a5.5 5.5 0 0 1-6.144-6.143l-1.98-.532A.75.75 0 0 1 .95 5.334l1.98.531q.27-.64.687-1.188l-1.45-1.45a.75.75 0 0 1 1.06-1.06l1.45 1.45a5.5 5.5 0 0 1 1.188-.687L5.335.95a.75.75 0 0 1 .53-.919M8 12a4 4 0 1 0-3.309-1.752L8.42 6.52a.75.75 0 0 1 1.06 1.06l-3.728 3.73c.64.435 1.414.69 2.248.69',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `gift` icon.
  static const HeroIconData gift = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'm9.035 3.863.182-1.276a.92.92 0 0 1 .818-.783.914.914 0 0 1 .272 1.805zM7.25 5.5v2H3a.5.5 0 0 1-.5-.5V6a.5.5 0 0 1 .5-.5zM8 1.564A2.415 2.415 0 1 0 3.83 4H3a2 2 0 0 0-2 2v1a2 2 0 0 0 1 1.732V12a3 3 0 0 0 3 3h6a3 3 0 0 0 3-3V8.732A2 2 0 0 0 15 7V6a2 2 0 0 0-2-2h-.83A2.415 2.415 0 1 0 8 1.565m.75 4.186V7.5H13a.5.5 0 0 0 .5-.5V6a.5.5 0 0 0-.5-.5H8.75zM7.25 9H3.5v3A1.5 1.5 0 0 0 5 13.5h2.25zm1.5 4.5V9h3.75v3a1.5 1.5 0 0 1-1.5 1.5zM6.783 2.587l.182 1.276-1.272-.254a.914.914 0 0 1 .272-1.805.92.92 0 0 1 .818.783',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `pin-fill` icon.
  static const HeroIconData pinFill = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10.5 2.255v-.01c.003-.03.013-.157-.361-.35C9.703 1.668 8.967 1.5 8 1.5s-1.703.169-2.138.394c-.375.194-.365.32-.362.351v.01c-.003.03-.013.157.362.35C6.297 2.832 7.033 3 8 3s1.703-.169 2.139-.394c.374-.194.364-.32.361-.351M12 2.25c0 .738-.433 1.294-1.136 1.669l.825 2.31c1.553.48 2.561 1.32 2.561 2.52 0 1.854-2.402 2.848-5.5 2.985V15a.75.75 0 0 1-1.5 0v-3.266c-3.098-.136-5.5-1.131-5.5-2.984 0-1.2 1.008-2.04 2.561-2.52l.825-2.311C4.433 3.544 4 2.988 4 2.25 4 .75 5.79 0 8 0s4 .75 4 2.25',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `thunderbolt` icon.
  static const HeroIconData thunderbolt = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M9.262.498a.75.75 0 0 1 1.275.717L9.229 5.622h3.272c1.104 0 1.665 1.328.897 2.12l-7.542 7.779a.75.75 0 0 1-1.248-.764l1.602-4.723H3.445c-1.083-.001-1.653-1.286-.926-2.09zM4.01 8.534h3.246a.75.75 0 0 1 .711.99l-.869 2.56 4.813-4.962H8.224a.75.75 0 0 1-.719-.963l.656-2.21z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `palette` icon.
  static const HeroIconData palette = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12.012 10c.431.004.764-.15 1.002-.411.244-.268.486-.762.486-1.589a5.5 5.5 0 1 0-5.17 5.491 4.3 4.3 0 0 1-.106-.89 2.37 2.37 0 0 1 .495-1.48c.386-.493.92-.763 1.448-.914C10.69 10.06 11.303 10 12 10zM8.43 14.01v-.005zM12 11.5c1.66.013 3-1.25 3-3.5a7 7 0 1 0-7 7c2.19 0 2.011-.83 1.827-1.68-.194-.898-.393-1.82 2.173-1.82M9 5a1 1 0 1 1-2 0 1 1 0 0 1 2 0m2 2.75a1 1 0 1 0 0-2 1 1 0 0 0 0 2m-4.75-1a1 1 0 1 1-2 0 1 1 0 0 1 2 0M5.75 11a1 1 0 1 0 0-2 1 1 0 0 0 0 2',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `font` icon.
  static const HeroIconData font = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 2.25c-.618 0-1.169.39-1.373.974l-3.335 9.528a.75.75 0 0 0 1.416.496L5.845 10h4.31l1.137 3.248a.75.75 0 0 0 1.416-.496L9.373 3.224A1.455 1.455 0 0 0 8 2.25M9.63 8.5 8 3.842 6.37 8.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `text-indent` icon.
  static const HeroIconData textIndent = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.25 2H2.75a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5m0 3.5h-5.5a.75.75 0 0 0 0 1.5h5.5a.75.75 0 0 0 0-1.5m0 3.5h-5.5a.75.75 0 0 0 0 1.5h5.5a.75.75 0 0 0 0-1.5m-10.5 3.5h10.5a.75.75 0 0 1 0 1.5H2.75a.75.75 0 0 1 0-1.5m.49-7a.74.74 0 0 1 .463.162l1.906 1.526a1.04 1.04 0 0 1 0 1.624l-1.906 1.526A.74.74 0 0 1 2.5 9.76V6.24a.74.74 0 0 1 .74-.74',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `text-outdent` icon.
  static const HeroIconData textOutdent = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.25 2H2.75a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5m0 3.5h-5.5a.75.75 0 0 0 0 1.5h5.5a.75.75 0 0 0 0-1.5m0 3.5h-5.5a.75.75 0 0 0 0 1.5h5.5a.75.75 0 0 0 0-1.5m-10.5 3.5h10.5a.75.75 0 0 1 0 1.5H2.75a.75.75 0 0 1 0-1.5m2.01-7a.74.74 0 0 0-.463.162L2.39 7.188a1.04 1.04 0 0 0 0 1.624l1.907 1.526A.74.74 0 0 0 5.5 9.76V6.24a.74.74 0 0 0-.74-.74',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `bars-descending-align-left` icon.
  static const HeroIconData
  barsDescendingAlignLeft = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1 3.25a.75.75 0 0 1 .75-.75h12.5a.75.75 0 0 1 0 1.5H1.75A.75.75 0 0 1 1 3.25M1 8a.75.75 0 0 1 .75-.75h8.5a.75.75 0 0 1 0 1.5h-8.5A.75.75 0 0 1 1 8m.75 4a.75.75 0 0 0 0 1.5h2.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `arrow-shape-turn-up-left` icon.
  static const HeroIconData arrowShapeTurnUpLeft = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M7 9v2.665a.335.335 0 0 1-.55.257L1.73 7.988a.635.635 0 0 1 0-.976l4.72-3.934a.335.335 0 0 1 .55.257V6h1.5c1.584 0 3.182.571 4.241 1.692.9.951 1.549 2.446 1.31 4.723-.65-1.026-1.365-1.837-2.201-2.413C10.802 9.279 9.677 9 8.5 9zm3 1.731c1.162.396 2.165 1.337 3.151 3.106.223.4.64.663 1.098.663.552 0 1.04-.376 1.143-.917C16.598 7.237 12.322 4.5 8.501 4.5V3.335a1.835 1.835 0 0 0-3.01-1.41L.768 5.86a2.135 2.135 0 0 0 0 3.28l4.721 3.935a1.835 1.835 0 0 0 3.01-1.41V10.5c.533 0 1.03.07 1.5.231',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `arrow-shape-turn-up-right` icon.
  static const HeroIconData arrowShapeTurnUpRight = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M9 9v2.665a.335.335 0 0 0 .55.257l4.72-3.934a.635.635 0 0 0 0-.976L9.55 3.078a.335.335 0 0 0-.55.257V6H7.5c-1.584 0-3.182.571-4.241 1.692-.9.951-1.549 2.446-1.31 4.723.65-1.026 1.365-1.837 2.201-2.413C5.198 9.279 6.323 9 7.5 9zm-3 1.731c-1.162.396-2.165 1.337-3.151 3.106-.223.4-.64.663-1.098.663-.552 0-1.04-.376-1.143-.917C-.598 7.237 3.678 4.5 7.499 4.5V3.335a1.835 1.835 0 0 1 3.01-1.41l4.722 3.935a2.135 2.135 0 0 1 0 3.28l-4.721 3.935a1.835 1.835 0 0 1-3.01-1.41V10.5c-.533 0-1.03.07-1.5.231',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `arrow-uturn-cw-left` icon.
  static const HeroIconData arrowUturnCwLeft = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M2.47 11.28a.75.75 0 0 1 0-1.06l3-3a.75.75 0 0 1 1.06 1.06L4.81 10H9a3.25 3.25 0 0 0 0-6.5H8A.75.75 0 0 1 8 2h1a4.75 4.75 0 1 1 0 9.5H4.81l1.72 1.72a.75.75 0 1 1-1.06 1.06z',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `calendar-xmark` icon.
  static const HeroIconData calendarXmark = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M9.151 6.47a.751.751 0 0 1 1.062 1.06L9.15 8.59l1.06 1.061a.751.751 0 0 1-1.06 1.062L8.091 9.65l-1.06 1.062A.75.75 0 0 1 5.97 9.65l1.06-1.06-1.06-1.06a.75.75 0 0 1 1.06-1.06l1.06 1.06z',
    ),
    HeroIconPath(
      'M11 .95a.75.75 0 0 1 .75.75v.687a3 3 0 0 1 2.75 2.987v6l-.004.154a3 3 0 0 1-2.842 2.842l-.154.004h-7a3 3 0 0 1-2.996-2.846l-.004-.154v-6a3 3 0 0 1 2.75-2.99V1.7a.75.75 0 0 1 1.5 0v.674h4.5V1.7A.75.75 0 0 1 11 .95M5.75 4.476a.75.75 0 0 1-1.5 0v-.58A1.5 1.5 0 0 0 3 5.373v6a1.5 1.5 0 0 0 1.5 1.5h7a1.5 1.5 0 0 0 1.5-1.5v-6a1.5 1.5 0 0 0-1.25-1.479v.581a.75.75 0 0 1-1.5 0v-.602h-4.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `person-fill` icon.
  static const HeroIconData personFill = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8 9c3.85 0 7 2.5 7 4.5a1.5 1.5 0 0 1-1.5 1.5h-11A1.5 1.5 0 0 1 1 13.5C1 11.5 4.15 9 8 9m0-8a3.5 3.5 0 1 1 0 7 3.5 3.5 0 0 1 0-7',
    ),
  ]);

  /// Gravity UI `printer` icon.
  static const HeroIconData printer = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10.75 2.5h-5.5a.75.75 0 0 0-.75.75V4h7v-.75a.75.75 0 0 0-.75-.75M13 4v-.75A2.25 2.25 0 0 0 10.75 1h-5.5A2.25 2.25 0 0 0 3 3.25V4a3 3 0 0 0-3 3v2a3 3 0 0 0 3 3h1v1a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2v-1h1a3 3 0 0 0 3-3V7a3 3 0 0 0-3-3m-9 6v.5H3A1.5 1.5 0 0 1 1.5 9V7A1.5 1.5 0 0 1 3 5.5h10A1.5 1.5 0 0 1 14.5 7v2a1.5 1.5 0 0 1-1.5 1.5h-1V10a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2m6-.5H6a.5.5 0 0 0-.5.5v3a.5.5 0 0 0 .5.5h4a.5.5 0 0 0 .5-.5v-3a.5.5 0 0 0-.5-.5m2.5-1a1 1 0 1 0 0-2 1 1 0 0 0 0 2',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `check-double` icon.
  static const HeroIconData checkDouble = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M13.97 5.223a.75.75 0 0 1 1.06 1.06l-5.5 5.5a.75.75 0 0 1-1.088-.028l-.5-.555a.75.75 0 0 1 1.084-1.034zm-4-1.008a.75.75 0 0 1 1.06 1.061l-5.5 5.5a.75.75 0 0 1-1.095-.036l-3.5-4a.75.75 0 0 1 1.13-.988l2.97 3.396z',
    ),
  ]);

  /// Gravity UI `chevron-up-wide` icon.
  static const HeroIconData chevronUpWide = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.867 9.903a.75.75 0 0 0 1.036.23L8 6.889l5.097 3.244a.75.75 0 0 0 .806-1.266l-5.5-3.5a.75.75 0 0 0-.806 0l-5.5 3.5a.75.75 0 0 0-.23 1.036',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `chevron-down-wide` icon.
  static const HeroIconData chevronDownWide = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M1.867 6.097a.75.75 0 0 1 1.036-.23L8 9.111l5.097-3.244a.75.75 0 0 1 .806 1.266l-5.5 3.5a.75.75 0 0 1-.806 0l-5.5-3.5a.75.75 0 0 1-.23-1.036',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `chevrons-left` icon.
  static const HeroIconData chevronsLeft = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M12.53 5.03a.75.75 0 0 0-1.06-1.06l-3.5 3.5a.75.75 0 0 0 0 1.06l3.5 3.5a.75.75 0 1 0 1.06-1.06L9.56 8zm-5 0a.75.75 0 0 0-1.06-1.06l-3.5 3.5a.75.75 0 0 0 0 1.06l3.5 3.5a.75.75 0 0 0 1.06-1.06L4.56 8z',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `chevrons-right` icon.
  static const HeroIconData chevronsRight = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M3.47 10.97a.75.75 0 1 0 1.06 1.06l3.5-3.5a.75.75 0 0 0 0-1.06l-3.5-3.5a.75.75 0 0 0-1.06 1.06L6.44 8zm5 0a.75.75 0 1 0 1.06 1.06l3.5-3.5a.75.75 0 0 0 0-1.06l-3.5-3.5a.75.75 0 0 0-1.06 1.06L11.44 8z',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `arrow-right-to-line` icon.
  static const HeroIconData arrowRightToLine = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M11.78 7.47a.75.75 0 0 1 0 1.06l-2.5 2.5a.75.75 0 1 1-1.06-1.06l1.22-1.22H1.75a.75.75 0 0 1 0-1.5h7.69L8.22 6.03a.75.75 0 0 1 1.06-1.06zm1.72 6.78a.75.75 0 0 0 1.5 0V1.75a.75.75 0 0 0-1.5 0z',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `arrow-left-to-line` icon.
  static const HeroIconData arrowLeftToLine = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4.22 8.53a.75.75 0 0 1 0-1.06l2.5-2.5a.75.75 0 0 1 1.06 1.06L6.56 7.25h7.69a.75.75 0 0 1 0 1.5H6.56l1.22 1.22a.75.75 0 1 1-1.06 1.06zM2.5 1.75a.75.75 0 1 0-1.5 0v12.5a.75.75 0 0 0 1.5 0z',
      evenOdd: true,
    ),
  ], matchTextDirection: true);

  /// Gravity UI `magnifier-plus` icon.
  static const HeroIconData magnifierPlus = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M6.75 11a4.25 4.25 0 1 0 0-8.5 4.25 4.25 0 0 0 0 8.5m0 1.5a5.73 5.73 0 0 0 3.501-1.188l2.719 2.718a.75.75 0 1 0 1.06-1.06l-2.718-2.719A5.75 5.75 0 1 0 6.75 12.5m.75-7.75a.75.75 0 0 0-1.5 0V6H4.75a.75.75 0 0 0 0 1.5H6v1.25a.75.75 0 0 0 1.5 0V7.5h1.25a.75.75 0 0 0 0-1.5H7.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `magnifier-minus` icon.
  static const HeroIconData magnifierMinus = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M6.75 11a4.25 4.25 0 1 0 0-8.5 4.25 4.25 0 0 0 0 8.5m0 1.5a5.73 5.73 0 0 0 3.501-1.188l2.719 2.718a.75.75 0 1 0 1.06-1.06l-2.718-2.719A5.75 5.75 0 1 0 6.75 12.5m-2-6.5a.75.75 0 0 0 0 1.5h4a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `sliders-vertical` icon.
  static const HeroIconData slidersVertical = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M10.999 8.499a1.5 1.5 0 1 0 0 3 1.5 1.5 0 0 0 0-3m-.75-1.406a3.001 3.001 0 0 0 0 5.811v1.347a.75.75 0 0 0 1.5 0v-1.347a3.001 3.001 0 0 0 0-5.811V1.748a.75.75 0 0 0-1.5 0zm-4.5 7.158V8.906a3.001 3.001 0 0 0 0-5.81V1.747a.75.75 0 1 0-1.5 0v1.347a3.001 3.001 0 0 0 0 5.811v5.345a.75.75 0 0 0 1.5 0M6.499 6a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `layout-columns` icon.
  static const HeroIconData layoutColumns = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M8.75 3.5H12A1.5 1.5 0 0 1 13.5 5v6a1.5 1.5 0 0 1-1.5 1.5H8.75zm-1.5 0H4A1.5 1.5 0 0 0 2.5 5v6A1.5 1.5 0 0 0 4 12.5h3.25zM1 5a3 3 0 0 1 3-3h8a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `layout-rows` icon.
  static const HeroIconData layoutRows = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M4 3.5h8A1.5 1.5 0 0 1 13.5 5v2.25h-11V5A1.5 1.5 0 0 1 4 3.5M2.5 8.75V11A1.5 1.5 0 0 0 4 12.5h8a1.5 1.5 0 0 0 1.5-1.5V8.75zM1 5a3 3 0 0 1 3-3h8a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3H4a3 3 0 0 1-3-3z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `briefcase` icon.
  static const HeroIconData briefcase = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M9 2.5H7a.5.5 0 0 0-.5.5v1h3V3a.5.5 0 0 0-.5-.5M5 3v1H4a3 3 0 0 0-3 3v4a3 3 0 0 0 3 3h8a3 3 0 0 0 3-3V7a3 3 0 0 0-3-3h-1V3a2 2 0 0 0-2-2H7a2 2 0 0 0-2 2m4.5 2.5H12A1.5 1.5 0 0 1 13.5 7v4a1.5 1.5 0 0 1-1.5 1.5H4A1.5 1.5 0 0 1 2.5 11V7A1.5 1.5 0 0 1 4 5.5zM4.75 7a.75.75 0 0 0 0 1.5h6.5a.75.75 0 0 0 0-1.5z',
      evenOdd: true,
    ),
  ]);

  /// Gravity UI `handset` icon.
  static const HeroIconData handset = HeroIconData(<HeroIconPath>[
    HeroIconPath(
      'M14.125 9.833a3.7 3.7 0 0 0-1.592-1.22l-.032-.012a2.88 2.88 0 0 0-2.795.37l-.36.269a.5.5 0 0 1-.653-.047L6.807 7.307a.5.5 0 0 1-.047-.654l.27-.36A2.88 2.88 0 0 0 7.4 3.5l-.013-.032a3.7 3.7 0 0 0-1.22-1.592l-.19-.143a2.33 2.33 0 0 0-2.135-.346l-.19.063A3.48 3.48 0 0 0 1.45 3.653a4.9 4.9 0 0 0-.105 2.725 9.76 9.76 0 0 0 2.567 4.533l1.178 1.178a9.76 9.76 0 0 0 4.533 2.566c.9.226 1.845.19 2.725-.104a3.48 3.48 0 0 0 2.204-2.203l.063-.19a2.33 2.33 0 0 0-.347-2.135zM5.159 3.219l-.19-.143a.65.65 0 0 0-.596-.096l-.19.063c-.538.18-.96.602-1.14 1.14a3.2 3.2 0 0 0-.069 1.788A8.1 8.1 0 0 0 5.1 9.723l1.178 1.178a8.1 8.1 0 0 0 3.752 2.125c.59.147 1.21.123 1.787-.069.539-.18.961-.602 1.141-1.14l.063-.19a.65.65 0 0 0-.096-.596l-.143-.19a2.03 2.03 0 0 0-.872-.668l-.032-.013a1.2 1.2 0 0 0-1.163.154l-.36.27a2.18 2.18 0 0 1-2.849-.203L5.62 8.495a2.18 2.18 0 0 1-.203-2.85l.27-.36c.25-.334.309-.774.154-1.162l-.013-.032a2.03 2.03 0 0 0-.668-.872',
      evenOdd: true,
    ),
  ]);
}
