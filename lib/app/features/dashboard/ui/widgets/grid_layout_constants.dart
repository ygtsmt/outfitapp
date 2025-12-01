class GridLayoutConstants {
  static const int minColumns = 2;
  static const int defaultColumns = 3;
  static const int maxColumns = 4;

  static int getNextColumnCount(int currentCount) {
    if (currentCount == minColumns) {
      return defaultColumns;
    } else if (currentCount == defaultColumns) {
      return maxColumns;
    } else {
      return minColumns;
    }
  }

  static String getLayoutIcon(int columnCount) {
    switch (columnCount) {
      case minColumns:
        return 'grid_view';
      case defaultColumns:
        return 'view_column';
      case maxColumns:
        return 'view_agenda';
      default:
        return 'grid_view';
    }
  }
}
