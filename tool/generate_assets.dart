// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  Directory('assets/icons').createSync(recursive: true);
  Directory('assets/images').createSync(recursive: true);

  print('Generating NexusHome assets...');

  // 1. App Icon (512x512)
  generatePng('assets/icons/app_icon.png', 512, 512, renderAppIcon);

  // 2. Room Renders (400x240)
  generatePng(
    'assets/images/living_room.png',
    400,
    240,
    (w, h) => renderRoom(w, h, 0x1E, 0x24, 0x30, 0x10, 0xB9, 0x81),
  );
  generatePng(
    'assets/images/master_suite.png',
    400,
    240,
    (w, h) => renderRoom(w, h, 0x1E, 0x1B, 0x2E, 0x8B, 0x5C, 0xF6),
  );
  generatePng(
    'assets/images/kitchen.png',
    400,
    240,
    (w, h) => renderRoom(w, h, 0x2A, 0x22, 0x1A, 0xF5, 0x9E, 0x0B),
  );
  generatePng(
    'assets/images/home_office.png',
    400,
    240,
    (w, h) => renderRoom(w, h, 0x14, 0x26, 0x2E, 0x06, 0xB6, 0xD4),
  );
  generatePng(
    'assets/images/solar_garage.png',
    400,
    240,
    (w, h) => renderRoom(w, h, 0x19, 0x2C, 0x20, 0x10, 0xB9, 0x81),
  );

  // 3. IoT Hardware Icons (256x256)
  generatePng(
    'assets/images/matter_border_router.png',
    256,
    256,
    (w, h) => renderHardware(w, h, 'ROUTER', 0x3B, 0x82, 0xF6),
  );
  generatePng(
    'assets/images/smart_thermostat.png',
    256,
    256,
    (w, h) => renderHardware(w, h, 'THERMOSTAT', 0xEF, 0x44, 0x44),
  );
  generatePng(
    'assets/images/rgb_ambient_light.png',
    256,
    256,
    (w, h) => renderHardware(w, h, 'LIGHT', 0xA8, 0x55, 0xF7),
  );
  generatePng(
    'assets/images/smart_deadbolt.png',
    256,
    256,
    (w, h) => renderHardware(w, h, 'LOCK', 0x10, 0xB9, 0x81),
  );
  generatePng(
    'assets/images/solar_inverter.png',
    256,
    256,
    (w, h) => renderHardware(w, h, 'INVERTER', 0xF5, 0x9E, 0x0B),
  );
  generatePng(
    'assets/images/security_camera.png',
    256,
    256,
    (w, h) => renderHardware(w, h, 'CAMERA', 0x06, 0xB6, 0xD4),
  );

  print('Asset generation complete.');
}

void generatePng(
  String path,
  int width,
  int height,
  Uint8List Function(int width, int height) painter,
) {
  final rawRgba = painter(width, height);
  final pngBytes = encodePngRgba(width, height, rawRgba);
  File(path).writeAsBytesSync(pngBytes);
  print('Generated: $path (${pngBytes.length} bytes)');
}

Uint8List renderAppIcon(int width, int height) {
  final buffer = Uint8List(width * height * 4);
  final cx = width / 2;
  final cy = height / 2;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final idx = (y * width + x) * 4;
      final dx = x - cx;
      final dy = y - cy;
      final dist = sqrt(dx * dx + dy * dy);

      // Dark obsidian background gradient
      final bgGrad = (y / height * 30).toInt();
      int r = 13 + bgGrad ~/ 2;
      int g = 17 + bgGrad ~/ 2;
      int b = 23 + bgGrad;
      int a = 255;

      // Outer glowing ring
      if (dist >= 180 && dist <= 200) {
        final t = (1 - (dist - 190).abs() / 10).clamp(0.0, 1.0);
        r = (r * (1 - t) + 16 * t).toInt();
        g = (g * (1 - t) + 185 * t).toInt();
        b = (b * (1 - t) + 129 * t).toInt();
      }

      // Geometric roofline (triangular peak at cx, cy - 80)
      final roofY = cy - 80 + (dx.abs() * 0.85);
      if ((y - roofY).abs() <= 12 && dx.abs() <= 140) {
        r = 245;
        g = 158;
        b = 11;
      }

      // Matter/Thread central hub node (circle around cx, cy + 30)
      final hubDist = sqrt(dx * dx + (y - (cy + 30)) * (y - (cy + 30)));
      if (hubDist <= 45) {
        final glow = (1 - hubDist / 45);
        r = (16 + glow * 50).toInt();
        g = (185 + glow * 70).clamp(0, 255).toInt();
        b = (129 + glow * 100).clamp(0, 255).toInt();
      } else if (hubDist <= 55) {
        r = 59;
        g = 130;
        b = 246;
      }

      // Diagonal connector mesh lines
      if ((dx + (y - cy)).abs() <= 3 && dist <= 120) {
        r = 139;
        g = 92;
        b = 246;
      }
      if ((dx - (y - cy)).abs() <= 3 && dist <= 120) {
        r = 6;
        g = 182;
        b = 212;
      }

      buffer[idx] = r.clamp(0, 255);
      buffer[idx + 1] = g.clamp(0, 255);
      buffer[idx + 2] = b.clamp(0, 255);
      buffer[idx + 3] = a;
    }
  }
  return buffer;
}

Uint8List renderRoom(
  int width,
  int height,
  int rBase,
  int gBase,
  int bBase,
  int rAccent,
  int gAccent,
  int bAccent,
) {
  final buffer = Uint8List(width * height * 4);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final idx = (y * width + x) * 4;
      final xNorm = x / width;
      final yNorm = y / height;

      // Architectural perspective room floor/ceiling lines
      final isFloorLine =
          (y - (height * 0.75 + (x - width / 2).abs() * 0.15)).abs() < 2.0;
      final isWallCorner =
          (x == (width * 0.25).toInt() || x == (width * 0.75).toInt()) &&
          yNorm > 0.3;

      int r = (rBase + (xNorm * 15)).toInt();
      int g = (gBase + (yNorm * 20)).toInt();
      int b = (bBase + (xNorm * 25)).toInt();

      if (isFloorLine || isWallCorner) {
        r = rAccent;
        g = gAccent;
        b = bAccent;
      }

      // Ambient lighting glow at center top
      final lightDist = sqrt(pow(x - width / 2, 2) + pow(y - 30, 2));
      if (lightDist < 100) {
        final factor = (1 - lightDist / 100) * 0.35;
        r = (r * (1 - factor) + rAccent * factor).toInt();
        g = (g * (1 - factor) + gAccent * factor).toInt();
        b = (b * (1 - factor) + bAccent * factor).toInt();
      }

      buffer[idx] = r.clamp(0, 255);
      buffer[idx + 1] = g.clamp(0, 255);
      buffer[idx + 2] = b.clamp(0, 255);
      buffer[idx + 3] = 255;
    }
  }
  return buffer;
}

Uint8List renderHardware(
  int width,
  int height,
  String type,
  int rColor,
  int gColor,
  int bColor,
) {
  final buffer = Uint8List(width * height * 4);
  final cx = width / 2;
  final cy = height / 2;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final idx = (y * width + x) * 4;
      final dx = x - cx;
      final dy = y - cy;
      final dist = sqrt(dx * dx + dy * dy);

      int r = 18;
      int g = 24;
      int b = 38;

      // Circular disc or device body
      if (dist <= 85) {
        r = 30;
        g = 41;
        b = 59;
      }
      if ((dist - 85).abs() <= 4) {
        r = rColor;
        g = gColor;
        b = bColor;
      }
      // Inner geometric accent
      if (dist <= 35) {
        r = rColor;
        g = gColor;
        b = bColor;
      }

      buffer[idx] = r.clamp(0, 255);
      buffer[idx + 1] = g.clamp(0, 255);
      buffer[idx + 2] = b.clamp(0, 255);
      buffer[idx + 3] = 255;
    }
  }
  return buffer;
}

Uint8List encodePngRgba(int width, int height, Uint8List rgbaBytes) {
  final scanlineLength = width * 4 + 1;
  final rawData = Uint8List(scanlineLength * height);

  for (int y = 0; y < height; y++) {
    final rowOffset = y * scanlineLength;
    rawData[rowOffset] = 0; // Filter type: None
    final srcOffset = y * width * 4;
    for (int i = 0; i < width * 4; i++) {
      rawData[rowOffset + 1 + i] = rgbaBytes[srcOffset + i];
    }
  }

  final compressed = zlib.encode(rawData);

  final builder = BytesBuilder();
  // PNG Signature
  builder.add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

  // IHDR chunk
  final ihdr = ByteData(13);
  ihdr.setUint32(0, width, Endian.big);
  ihdr.setUint32(4, height, Endian.big);
  ihdr.setUint8(8, 8); // 8-bit depth
  ihdr.setUint8(9, 6); // RGBA
  ihdr.setUint8(10, 0); // compression
  ihdr.setUint8(11, 0); // filter
  ihdr.setUint8(12, 0); // interlace
  writeChunk(builder, 'IHDR', ihdr.buffer.asUint8List());

  // IDAT chunk
  writeChunk(builder, 'IDAT', Uint8List.fromList(compressed));

  // IEND chunk
  writeChunk(builder, 'IEND', Uint8List(0));

  return builder.toBytes();
}

void writeChunk(BytesBuilder builder, String type, Uint8List data) {
  final length = ByteData(4)..setUint32(0, data.length, Endian.big);
  builder.add(length.buffer.asUint8List());

  final typeBytes = type.codeUnits;
  builder.add(typeBytes);
  builder.add(data);

  final crcData = Uint8List(typeBytes.length + data.length);
  crcData.setRange(0, typeBytes.length, typeBytes);
  crcData.setRange(typeBytes.length, crcData.length, data);

  final crc = calculateCrc32(crcData);
  final crcBytes = ByteData(4)..setUint32(0, crc, Endian.big);
  builder.add(crcBytes.buffer.asUint8List());
}

int calculateCrc32(Uint8List data) {
  int crc = 0xFFFFFFFF;
  for (final byte in data) {
    crc ^= byte;
    for (int i = 0; i < 8; i++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc = crc >> 1;
      }
    }
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
