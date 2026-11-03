abstract final class MoodAnalysisPayloadKeys {
  /// Identifies the selected analysis period.
  static const String timeframe = 'timeframe';

  /// Gives the number of entries analyzed.
  static const String totalEntries = 'total_entries';

  /// Groups the summary mood statistics.
  static const String metrics = 'metrics';

  /// Provides the mean mood score.
  static const String averageMood = 'average_mood';

  /// Describes the mood direction and daily slope.
  static const String trend = 'trend';

  /// Describes mood variability and standard deviation.
  static const String volatility = 'volatility';

  /// Groups trigger impact results.
  static const String correlations = 'correlations';

  /// Lists triggers with strongly positive mood impact.
  static const String positiveTriggers = 'positive_triggers';

  /// Lists triggers with strongly negative mood impact.
  static const String negativeTriggers = 'negative_triggers';

  /// Identifies a trigger name.
  static const String trigger = 'trigger';

  /// Gives how often a trigger appears.
  static const String frequency = 'frequency';

  /// Gives mood difference from the overall average.
  static const String delta = 'delta';

  /// Lists the most frequent feelings.
  static const String topFeelings = 'top_feelings';

  /// Groups the highest and lowest mood samples.
  static const String outlierSamples = 'outlier_samples';

  /// Gives the sample's calendar date.
  static const String date = 'date';

  /// Gives the sample's mood score.
  static const String mood = 'mood';

  /// Gives the sample's recorded feelings.
  static const String feelings = 'feelings';

  /// Gives the sample's optional journal note.
  static const String note = 'note';
}

abstract final class MoodAnalysisPayloadLabels {
  /// Indicates that the available entries cannot support a metric.
  static const String insufficientData = 'insufficient data';

  /// Labels a positive mood slope.
  static const String upward = 'upward';

  /// Labels a negative mood slope.
  static const String downward = 'downward';

  /// Labels a near-zero mood slope.
  static const String flat = 'flat';

  /// Labels higher mood variability.
  static const String high = 'high';

  /// Labels moderate mood variability.
  static const String moderate = 'moderate';

  /// Labels lower mood variability.
  static const String low = 'low';
}
