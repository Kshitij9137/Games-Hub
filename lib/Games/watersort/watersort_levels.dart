import 'package:flutter/material.dart';
import 'watersort_bottle.dart';

class WaterSortLevels {
  static List<WaterSortBottle> getLevel(int level) {
    switch (level) {
      case 1:
        return _createLevel1();
      case 2:
        return _createLevel2();
      case 3:
        return _createLevel3();
      case 4:
        return _createLevel4();
      case 5:
        return _createLevel5();
      default:
        return _createLevel1();
    }
  }

  static List<WaterSortBottle> _createLevel1() {
    return [
      WaterSortBottle([Colors.red, Colors.blue, Colors.blue, Colors.red]),
      WaterSortBottle([Colors.blue, Colors.red, Colors.red, Colors.blue]),
      WaterSortBottle([null, null, null, null]),
      WaterSortBottle([null, null, null, null]),
    ];
  }

  static List<WaterSortBottle> _createLevel2() {
    return [
      WaterSortBottle([Colors.red, Colors.green, Colors.blue, Colors.red]),
      WaterSortBottle([Colors.green, Colors.blue, Colors.red, Colors.blue]),
      WaterSortBottle([Colors.blue, Colors.red, Colors.green, Colors.green]),
      WaterSortBottle([null, null, null, null]),
      WaterSortBottle([null, null, null, null]),
    ];
  }

  static List<WaterSortBottle> _createLevel3() {
    return [
      WaterSortBottle([Colors.red, Colors.yellow, Colors.blue, Colors.green]),
      WaterSortBottle([Colors.yellow, Colors.blue, Colors.green, Colors.red]),
      WaterSortBottle([Colors.blue, Colors.green, Colors.red, Colors.yellow]),
      WaterSortBottle([Colors.green, Colors.red, Colors.yellow, Colors.blue]),
      WaterSortBottle([null, null, null, null]),
      WaterSortBottle([null, null, null, null]),
    ];
  }

  static List<WaterSortBottle> _createLevel4() {
    return [
      WaterSortBottle([Colors.purple, Colors.orange, Colors.pink, Colors.cyan]),
      WaterSortBottle([Colors.orange, Colors.pink, Colors.cyan, Colors.purple]),
      WaterSortBottle([Colors.pink, Colors.cyan, Colors.purple, Colors.orange]),
      WaterSortBottle([Colors.cyan, Colors.purple, Colors.orange, Colors.pink]),
      WaterSortBottle([null, null, null, null]),
      WaterSortBottle([null, null, null, null]),
    ];
  }

  static List<WaterSortBottle> _createLevel5() {
    return [
      WaterSortBottle([Colors.red, Colors.yellow, Colors.blue, Colors.purple]),
      WaterSortBottle([Colors.green, Colors.orange, Colors.pink, Colors.cyan]),
      WaterSortBottle([Colors.yellow, Colors.purple, Colors.cyan, Colors.red]),
      WaterSortBottle([Colors.orange, Colors.blue, Colors.pink, Colors.green]),
      WaterSortBottle([
        Colors.purple,
        Colors.cyan,
        Colors.green,
        Colors.yellow,
      ]),
      WaterSortBottle([Colors.blue, Colors.pink, Colors.red, Colors.orange]),
      WaterSortBottle([null, null, null, null]),
      WaterSortBottle([null, null, null, null]),
    ];
  }
}
