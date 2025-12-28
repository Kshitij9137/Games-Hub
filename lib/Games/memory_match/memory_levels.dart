class LevelConfig {
  final int level;
  final int rows;
  final int cols;
  final int pairs;
  final String difficulty;
  final String theme;
  final int timeLimit; // in seconds
  final int maxMoves; // for star rating
  final int maxTime; // for star rating

  LevelConfig({
    required this.level,
    required this.rows,
    required this.cols,
    required this.pairs,
    required this.difficulty,
    required this.theme,
    this.timeLimit = 0,
    this.maxMoves = 0,
    this.maxTime = 0,
  });
}

class MemoryLevels {
  static const Map<String, List<String>> themeSymbols = {
    'emoji': [
      '🌟',
      '🎮',
      '🎯',
      '🎨',
      '🎭',
      '🎪',
      '🚀',
      '🎡',
      '🎢',
      '🎠',
      '🏆',
      '🎼',
      '🎸',
      '🎹',
      '🎺',
      '🎻',
      '🥁',
      '🎤',
      '🏀',
      '⚽',
      '🎾',
      '🏐',
      '🏈',
      '⚾',
    ],
    'animals': [
      '🐱',
      '🐶',
      '🐼',
      '🐨',
      '🐯',
      '🐮',
      '🐰',
      '🐹',
      '🐻',
      '🐵',
      '🐸',
      '🐧',
      '🦁',
      '🐺',
      '🐗',
      '🐴',
      '🦄',
      '🐝',
      '🐛',
      '🦋',
      '🐌',
      '🐞',
      '🐢',
      '🐍',
    ],
    'food': [
      '🍎',
      '🍌',
      '🍇',
      '🍓',
      '🍉',
      '🍒',
      '🍕',
      '🍔',
      '🍟',
      '🌭',
      '🍦',
      '🍩',
      '🍪',
      '🎂',
      '🍫',
      '🍿',
      '🌮',
      '🍣',
      '🍜',
      '🍱',
      '🥐',
      '🥨',
      '🧀',
      '🥓',
    ],
    'sports': [
      '⚽',
      '🏀',
      '🎾',
      '🏐',
      '🏈',
      '⚾',
      '🎯',
      '🏸',
      '🏓',
      '🏒',
      '⛳',
      '🎱',
      '🏹',
      '🥊',
      '🛹',
      '🛼',
      '⛸️',
      '🎿',
      '🏂',
      '🏄',
      '🏊',
      '🤽',
      '🏇',
      '🚴',
    ],
    'travel': [
      '🚗',
      '✈️',
      '🚂',
      '🚢',
      '🚁',
      '🚀',
      '🏰',
      '🏝️',
      '🏔️',
      '🌋',
      '🏕️',
      '🎪',
      '🗽',
      '🗼',
      '🌉',
      '🎡',
      '🛳️',
      '🚞',
      '🚲',
      '🛵',
      '🚁',
      '🛸',
      '🚤',
      '⛵',
    ],
    'music': [
      '🎸',
      '🎹',
      '🎺',
      '🎻',
      '🥁',
      '🎤',
      '🎧',
      '🎼',
      '🎵',
      '🎶',
      '📻',
      '🎷',
      '🪕',
      '🎻',
      '🪗',
      '📯',
      '🥁',
      '🪘',
      '🎚️',
      '🎛️',
      '📱',
      '💿',
      '📀',
      '🎹',
    ],
    'weather': [
      '☀️',
      '🌧️',
      '⛄',
      '🌈',
      '🌪️',
      '🌩️',
      '💨',
      '❄️',
      '🌞',
      '🌜',
      '⭐',
      '☁️',
      '🌦️',
      '🌤️',
      '⛅',
      '🌨️',
      '⚡',
      '🌀',
      '🌫️',
      '🌡️',
      '💧',
      '💦',
      '☔',
      '🌊',
    ],
    'holidays': [
      '🎄',
      '🎁',
      '🎅',
      '🤶',
      '🍪',
      '🥛',
      '🌟',
      '🔔',
      '🕯️',
      '❄️',
      '⛄',
      '🎶',
      '🦃',
      '🥧',
      '🍗',
      '🕎',
      '✨',
      '🕍',
      '🌟',
      '🕌',
      '🎆',
      '🎇',
      '🧨',
      '🪅',
    ],
    'ocean': [
      '🐠',
      '🐟',
      '🐡',
      '🐬',
      '🐳',
      '🦈',
      '🐙',
      '🦀',
      '🦐',
      '🐚',
      '🌊',
      '⚓',
      '🦑',
      '🐋',
      '🦞',
      '🦭',
      '🐊',
      '🏝️',
      '🚤',
      '⛵',
      '🤿',
      '🐚',
      '🧜',
      '🌅',
    ],
    'space': [
      '🚀',
      '🛸',
      '👽',
      '🌟',
      '🪐',
      '☄️',
      '🌙',
      '⭐',
      '🔭',
      '🛰️',
      '🌍',
      '🌌',
      '🪐',
      '🌠',
      '⚡',
      '🌀',
      '💫',
      '✨',
      '🪐',
      '🌑',
      '🌒',
      '🌓',
      '🌔',
      '🌕',
    ],
  };

  static LevelConfig getLevelConfig(int level) {
    switch (level) {
      case 1:
        return LevelConfig(
          level: 1,
          rows: 3,
          cols: 4,
          pairs: 6,
          difficulty: 'Beginner',
          theme: 'emoji',
          maxMoves: 20,
          maxTime: 120,
        );
      case 2:
        return LevelConfig(
          level: 2,
          rows: 4,
          cols: 4,
          pairs: 8,
          difficulty: 'Easy',
          theme: 'animals',
          maxMoves: 30,
          maxTime: 180,
        );
      case 3:
        return LevelConfig(
          level: 3,
          rows: 4,
          cols: 5,
          pairs: 10,
          difficulty: 'Medium',
          theme: 'food',
          maxMoves: 40,
          maxTime: 240,
        );
      case 4:
        return LevelConfig(
          level: 4,
          rows: 4,
          cols: 6,
          pairs: 12,
          difficulty: 'Medium',
          theme: 'sports',
          maxMoves: 50,
          maxTime: 300,
        );
      case 5:
        return LevelConfig(
          level: 5,
          rows: 5,
          cols: 6,
          pairs: 15,
          difficulty: 'Hard',
          theme: 'travel',
          timeLimit: 300,
          maxMoves: 60,
          maxTime: 300,
        );
      case 6:
        return LevelConfig(
          level: 6,
          rows: 5,
          cols: 6,
          pairs: 15,
          difficulty: 'Hard',
          theme: 'music',
          timeLimit: 270,
          maxMoves: 55,
          maxTime: 270,
        );
      case 7:
        return LevelConfig(
          level: 7,
          rows: 6,
          cols: 6,
          pairs: 18,
          difficulty: 'Expert',
          theme: 'weather',
          timeLimit: 360,
          maxMoves: 70,
          maxTime: 360,
        );
      case 8:
        return LevelConfig(
          level: 8,
          rows: 6,
          cols: 6,
          pairs: 18,
          difficulty: 'Expert',
          theme: 'holidays',
          timeLimit: 330,
          maxMoves: 65,
          maxTime: 330,
        );
      case 9:
        return LevelConfig(
          level: 9,
          rows: 6,
          cols: 7,
          pairs: 21,
          difficulty: 'Master',
          theme: 'ocean',
          timeLimit: 420,
          maxMoves: 80,
          maxTime: 420,
        );
      case 10:
        return LevelConfig(
          level: 10,
          rows: 6,
          cols: 7,
          pairs: 21,
          difficulty: 'Master',
          theme: 'space',
          timeLimit: 390,
          maxMoves: 75,
          maxTime: 390,
        );
      default:
        return getLevelConfig(1);
    }
  }

  static List<String> generateSymbols(String theme, int pairs) {
    final themeSet = themeSymbols[theme] ?? themeSymbols['emoji']!;

    // Make sure we don't request more pairs than available symbols
    if (pairs > themeSet.length) {
      // If we need more symbols than available, duplicate some
      List<String> extendedSymbols = [];
      int index = 0;
      while (extendedSymbols.length < pairs) {
        extendedSymbols.add(themeSet[index % themeSet.length]);
        index++;
      }
      final selectedSymbols = extendedSymbols.sublist(0, pairs);

      // Create pairs
      final List<String> result = [];
      for (String symbol in selectedSymbols) {
        result.add(symbol);
        result.add(symbol);
      }
      return result;
    } else {
      // Normal case - we have enough symbols
      final selectedSymbols = themeSet.sublist(0, pairs);

      // Create pairs
      final List<String> result = [];
      for (String symbol in selectedSymbols) {
        result.add(symbol);
        result.add(symbol);
      }
      return result;
    }
  }

  static int calculateStars(int moves, int time, LevelConfig config) {
    int stars = 3;

    // Check moves
    if (moves > config.maxMoves * 1.2) {
      stars--;
    } else if (moves > config.maxMoves * 1.5) {
      stars -= 2;
    }

    // Check time (for timed levels)
    if (config.timeLimit > 0 && time > config.maxTime * 1.2) {
      stars--;
    } else if (config.timeLimit > 0 && time > config.maxTime * 1.5) {
      stars -= 2;
    }

    return stars.clamp(1, 3);
  }
}
