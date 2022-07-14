class ByteToPercentage {
  static double remap(double value, double originalMinValue, double originalMaxValue,
      double translatedMinValue, double translatedMaxValue) {
    if (originalMaxValue - originalMinValue == 0) return 0;

    return (value - originalMinValue) /
            (originalMaxValue - originalMinValue) *
            (translatedMaxValue - translatedMinValue) +
        translatedMinValue;
  }
}

double uploadProgressPercentage(int sentBytes, int totalBytes) {
  double __progressValue =
      ByteToPercentage.remap(sentBytes.toDouble(), 0, totalBytes.toDouble(), 0, 1);

  __progressValue = double.parse(__progressValue.toStringAsFixed(2));
  // this __progressValue value is the percentage
  // if we do (_progressValue * 100).toInt() then we can get the percentage
  // we can show the loader while doing this or a ciruclar bar

  return __progressValue;
}

class APIResponse<T> {
  T? data;
  bool error;
  String? errorMessage;

  APIResponse({this.data, this.error = false, this.errorMessage});
}
