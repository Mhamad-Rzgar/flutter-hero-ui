import 'dart:ui';

/// Parses SVG path data (the `d` attribute) into a Flutter [Path].
///
/// Supports every path command (`M L H V C S Q T A Z`, absolute and
/// relative), implicit command repetition and compact number syntax such as
/// `.75.75` or packed arc flags (`a1 1 0 011 1`).
Path parseSvgPathData(
  String data, {
  PathFillType fillType = PathFillType.nonZero,
}) {
  final _SvgPathParser parser = _SvgPathParser(data);
  final Path path = Path()..fillType = fillType;
  parser.parseInto(path);
  return path;
}

class _SvgPathParser {
  _SvgPathParser(this._source);

  final String _source;
  int _index = 0;

  double _x = 0;
  double _y = 0;
  double _startX = 0;
  double _startY = 0;
  double? _lastCubicX;
  double? _lastCubicY;
  double? _lastQuadX;
  double? _lastQuadY;

  bool get _done => _index >= _source.length;

  void _skipSeparators() {
    while (!_done) {
      final int c = _source.codeUnitAt(_index);
      if (c == 0x20 || c == 0x2C || c == 0x09 || c == 0x0A || c == 0x0D) {
        _index++;
      } else {
        break;
      }
    }
  }

  bool _isCommand(int c) {
    switch (c) {
      case 0x4D: // M
      case 0x6D:
      case 0x4C: // L
      case 0x6C:
      case 0x48: // H
      case 0x68:
      case 0x56: // V
      case 0x76:
      case 0x43: // C
      case 0x63:
      case 0x53: // S
      case 0x73:
      case 0x51: // Q
      case 0x71:
      case 0x54: // T
      case 0x74:
      case 0x41: // A
      case 0x61:
      case 0x5A: // Z
      case 0x7A:
        return true;
    }
    return false;
  }

  bool _hasNumber() {
    _skipSeparators();
    if (_done) return false;
    final int c = _source.codeUnitAt(_index);
    return (c >= 0x30 && c <= 0x39) || c == 0x2D || c == 0x2B || c == 0x2E;
  }

  double _number() {
    _skipSeparators();
    final int start = _index;
    if (!_done) {
      final int c = _source.codeUnitAt(_index);
      if (c == 0x2D || c == 0x2B) _index++;
    }
    bool seenDot = false;
    bool seenExp = false;
    while (!_done) {
      final int c = _source.codeUnitAt(_index);
      if (c >= 0x30 && c <= 0x39) {
        _index++;
      } else if (c == 0x2E && !seenDot && !seenExp) {
        seenDot = true;
        _index++;
      } else if ((c == 0x65 || c == 0x45) && !seenExp) {
        seenExp = true;
        _index++;
        if (!_done) {
          final int s = _source.codeUnitAt(_index);
          if (s == 0x2D || s == 0x2B) _index++;
        }
      } else {
        break;
      }
    }
    return double.parse(_source.substring(start, _index));
  }

  bool _flag() {
    _skipSeparators();
    final int c = _source.codeUnitAt(_index);
    _index++;
    return c == 0x31;
  }

  void parseInto(Path path) {
    int? command;
    while (true) {
      _skipSeparators();
      if (_done) break;
      final int c = _source.codeUnitAt(_index);
      if (_isCommand(c)) {
        command = c;
        _index++;
      } else if (command == null) {
        throw FormatException('Invalid SVG path data', _source, _index);
      } else if (command == 0x4D) {
        command = 0x4C; // Implicit lineto after moveto.
      } else if (command == 0x6D) {
        command = 0x6C;
      }
      _execute(path, command);
    }
  }

  void _execute(Path path, int command) {
    final bool relative = command >= 0x61;
    switch (command) {
      case 0x4D:
      case 0x6D:
        double x = _number();
        double y = _number();
        if (relative) {
          x += _x;
          y += _y;
        }
        path.moveTo(x, y);
        _set(x, y);
        _startX = x;
        _startY = y;
        _resetControl();
      case 0x4C:
      case 0x6C:
        double x = _number();
        double y = _number();
        if (relative) {
          x += _x;
          y += _y;
        }
        path.lineTo(x, y);
        _set(x, y);
        _resetControl();
      case 0x48:
      case 0x68:
        double x = _number();
        if (relative) x += _x;
        path.lineTo(x, _y);
        _set(x, _y);
        _resetControl();
      case 0x56:
      case 0x76:
        double y = _number();
        if (relative) y += _y;
        path.lineTo(_x, y);
        _set(_x, y);
        _resetControl();
      case 0x43:
      case 0x63:
        double x1 = _number();
        double y1 = _number();
        double x2 = _number();
        double y2 = _number();
        double x = _number();
        double y = _number();
        if (relative) {
          x1 += _x;
          y1 += _y;
          x2 += _x;
          y2 += _y;
          x += _x;
          y += _y;
        }
        path.cubicTo(x1, y1, x2, y2, x, y);
        _set(x, y);
        _lastCubicX = x2;
        _lastCubicY = y2;
        _lastQuadX = null;
        _lastQuadY = null;
      case 0x53:
      case 0x73:
        final double x1 = _lastCubicX != null ? 2 * _x - _lastCubicX! : _x;
        final double y1 = _lastCubicY != null ? 2 * _y - _lastCubicY! : _y;
        double x2 = _number();
        double y2 = _number();
        double x = _number();
        double y = _number();
        if (relative) {
          x2 += _x;
          y2 += _y;
          x += _x;
          y += _y;
        }
        path.cubicTo(x1, y1, x2, y2, x, y);
        _set(x, y);
        _lastCubicX = x2;
        _lastCubicY = y2;
        _lastQuadX = null;
        _lastQuadY = null;
      case 0x51:
      case 0x71:
        double x1 = _number();
        double y1 = _number();
        double x = _number();
        double y = _number();
        if (relative) {
          x1 += _x;
          y1 += _y;
          x += _x;
          y += _y;
        }
        path.quadraticBezierTo(x1, y1, x, y);
        _set(x, y);
        _lastQuadX = x1;
        _lastQuadY = y1;
        _lastCubicX = null;
        _lastCubicY = null;
      case 0x54:
      case 0x74:
        final double x1 = _lastQuadX != null ? 2 * _x - _lastQuadX! : _x;
        final double y1 = _lastQuadY != null ? 2 * _y - _lastQuadY! : _y;
        double x = _number();
        double y = _number();
        if (relative) {
          x += _x;
          y += _y;
        }
        path.quadraticBezierTo(x1, y1, x, y);
        _set(x, y);
        _lastQuadX = x1;
        _lastQuadY = y1;
        _lastCubicX = null;
        _lastCubicY = null;
      case 0x41:
      case 0x61:
        final double rx = _number().abs();
        final double ry = _number().abs();
        final double rotation = _number();
        final bool largeArc = _flag();
        final bool sweep = _flag();
        double x = _number();
        double y = _number();
        if (relative) {
          x += _x;
          y += _y;
        }
        if (rx == 0 || ry == 0) {
          path.lineTo(x, y);
        } else {
          path.arcToPoint(
            Offset(x, y),
            radius: Radius.elliptical(rx, ry),
            rotation: rotation,
            largeArc: largeArc,
            clockwise: sweep,
          );
        }
        _set(x, y);
        _resetControl();
      case 0x5A:
      case 0x7A:
        path.close();
        _set(_startX, _startY);
        _resetControl();
    }
    // Consume further implicit parameter groups for the same command.
    if (command != 0x5A && command != 0x7A && _hasNumber()) {
      final int next = switch (command) {
        0x4D => 0x4C,
        0x6D => 0x6C,
        _ => command,
      };
      _execute(path, next);
    }
  }

  void _set(double x, double y) {
    _x = x;
    _y = y;
  }

  void _resetControl() {
    _lastCubicX = null;
    _lastCubicY = null;
    _lastQuadX = null;
    _lastQuadY = null;
  }
}
