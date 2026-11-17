import 'dart:math' as math;

enum CircadianPhase {
  solarNight,
  astronomicalDawn,
  sunrise,
  morningAscent,
  solarNoon,
  afternoonDescent,
  sunset,
  eveningAmber,
}

class CircadianState {
  final int targetKelvin;
  final int targetBrightness;
  final double solarElevation;
  final CircadianPhase phase;
  final String phaseTitle;
  final DateTime calculatedAt;
  final double solarHour;

  const CircadianState({
    required this.targetKelvin,
    required this.targetBrightness,
    required this.solarElevation,
    required this.phase,
    required this.phaseTitle,
    required this.calculatedAt,
    required this.solarHour,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CircadianState &&
        other.targetKelvin == targetKelvin &&
        other.targetBrightness == targetBrightness &&
        other.solarElevation == solarElevation &&
        other.phase == phase &&
        other.phaseTitle == phaseTitle &&
        other.calculatedAt == calculatedAt &&
        other.solarHour == solarHour;
  }

  @override
  int get hashCode => Object.hash(
    targetKelvin,
    targetBrightness,
    solarElevation,
    phase,
    phaseTitle,
    calculatedAt,
    solarHour,
  );
}

class AstronomicalSolarCalculator {
  // Default coordinates: 37.7749 N, -122.4194 W (San Francisco standard)
  static const double defaultLatitude = 37.7749;
  static const double defaultLongitude = -122.4194;

  static const int minKelvin =
      2700; // Warm amber for night and melatonin protection
  static const int maxKelvin =
      5500; // Crisp architectural daylight for alertness
  static const int minBrightness = 30; // Night restful brightness
  static const int maxBrightness = 100; // Full noon brightness

  /// Computes the exact astronomical solar elevation and circadian lighting state.
  static CircadianState calculate({
    DateTime? time,
    double latitude = defaultLatitude,
    double longitude = defaultLongitude,
  }) {
    final now = time ?? DateTime.now();

    // 1. Calculate Day of Year (1 - 366)
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays + 1;

    // 2. Solar declination angle delta (in radians)
    // delta = 23.45 * sin(2 * pi / 365 * (N - 81))
    final double bRad = (2.0 * math.pi / 365.0) * (dayOfYear - 81);
    final double declinationRad = (23.45 * math.pi / 180.0) * math.sin(bRad);

    // 3. Equation of Time (EoT) in minutes
    // EoT = 9.87 * sin(2B) - 7.53 * cos(B) - 1.5 * sin(B)
    final double eotMinutes =
        9.87 * math.sin(2.0 * bRad) -
        7.53 * math.cos(bRad) -
        1.5 * math.sin(bRad);

    // 4. Local Solar Time (LST) derived from UTC and Longitude
    final utc = now.toUtc();
    final double utcDecimalHours =
        utc.hour + (utc.minute / 60.0) + (utc.second / 3600.0);
    final double timeCorrectionMinutes = (4.0 * longitude) + eotMinutes;
    double solarHour = utcDecimalHours + (timeCorrectionMinutes / 60.0);

    // Normalize solar hour to [0, 24)
    while (solarHour < 0.0) {
      solarHour += 24.0;
    }
    while (solarHour >= 24.0) {
      solarHour -= 24.0;
    }

    // 5. Hour angle omega (in radians)
    // omega = 15 deg * (solarHour - 12)
    final double hourAngleDeg = 15.0 * (solarHour - 12.0);
    final double hourAngleRad = hourAngleDeg * (math.pi / 180.0);

    // 6. Solar elevation angle alpha (in degrees)
    // sin(alpha) = sin(lat) * sin(delta) + cos(lat) * cos(delta) * cos(omega)
    final double latRad = latitude * (math.pi / 180.0);
    final double sinAlpha =
        math.sin(latRad) * math.sin(declinationRad) +
        math.cos(latRad) * math.cos(declinationRad) * math.cos(hourAngleRad);

    // Clamp to valid arcsin range [-1.0, 1.0]
    final double clampedSin = sinAlpha.clamp(-1.0, 1.0);
    final double elevationRad = math.asin(clampedSin);
    final double elevationDeg = elevationRad * (180.0 / math.pi);

    // 7. Determine Circadian Phase and Human-Readable Title
    final isMorning = solarHour < 12.0;
    final CircadianPhase phase;
    final String phaseTitle;

    if (elevationDeg <= -18.0) {
      phase = CircadianPhase.solarNight;
      phaseTitle = 'Solar Night (2700K Amber Rest)';
    } else if (elevationDeg <= 0.0) {
      if (isMorning) {
        phase = CircadianPhase.astronomicalDawn;
        phaseTitle = 'Astronomical Dawn (Circadian Awakening)';
      } else {
        phase = CircadianPhase.eveningAmber;
        phaseTitle = 'Evening Rest (2700K Melatonin Protection)';
      }
    } else if (elevationDeg <= 12.0) {
      if (isMorning) {
        phase = CircadianPhase.sunrise;
        phaseTitle = 'Sunrise Golden Hour';
      } else {
        phase = CircadianPhase.sunset;
        phaseTitle = 'Sunset Golden Hour';
      }
    } else if (elevationDeg <= 40.0) {
      if (isMorning) {
        phase = CircadianPhase.morningAscent;
        phaseTitle = 'Morning Circadian Ascent';
      } else {
        phase = CircadianPhase.afternoonDescent;
        phaseTitle = 'Afternoon Circadian Descent';
      }
    } else {
      phase = CircadianPhase.solarNoon;
      phaseTitle = 'Solar Zenith (5500K Crisp Daylight)';
    }

    // 8. Calculate Smooth Curve for Target Kelvin
    // Map elevation from [-6.0 deg, 50.0 deg] to [2700K, 5500K]
    final double normalizedElev = ((elevationDeg - (-6.0)) / (50.0 - (-6.0)))
        .clamp(0.0, 1.0);

    // Hermite cubic smoothstep: 3x^2 - 2x^3
    final double smoothFactor =
        normalizedElev * normalizedElev * (3.0 - 2.0 * normalizedElev);

    final int targetKelvin =
        minKelvin + ((maxKelvin - minKelvin) * smoothFactor).round();

    // Smooth brightness modulation (30% to 100%)
    final int targetBrightness =
        minBrightness +
        ((maxBrightness - minBrightness) * smoothFactor).round();

    return CircadianState(
      targetKelvin: targetKelvin,
      targetBrightness: targetBrightness,
      solarElevation: elevationDeg,
      phase: phase,
      phaseTitle: phaseTitle,
      calculatedAt: now,
      solarHour: solarHour,
    );
  }
}
