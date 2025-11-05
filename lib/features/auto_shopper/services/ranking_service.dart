import 'dart:math';
import '../models/shop_candidate_model.dart';
import '../models/parsed_query_model.dart';

class RankingWeights {
  final double price;
  final double rating;
  final double distance;
  final double delivery;

  const RankingWeights({
    this.price = 0.4,
    this.rating = 0.3,
    this.distance = 0.2,
    this.delivery = 0.1,
  });

  // Preset weights based on user preference
  factory RankingWeights.fromPreference(String? preference) {
    switch (preference?.toLowerCase()) {
      case 'cheap':
        return const RankingWeights(
          price: 0.6,
          rating: 0.2,
          distance: 0.1,
          delivery: 0.1,
        );
      case 'quality':
        return const RankingWeights(
          price: 0.2,
          rating: 0.5,
          distance: 0.2,
          delivery: 0.1,
        );
      case 'fast':
        return const RankingWeights(
          price: 0.2,
          rating: 0.2,
          distance: 0.3,
          delivery: 0.3,
        );
      default:
        return const RankingWeights();
    }
  }
}

class RankingService {
  /// Rank and score candidates based on query preferences
  List<ShopCandidate> rankCandidates(
    List<ShopCandidate> candidates,
    ParsedQuery query,
  ) {
    if (candidates.isEmpty) {
      return [];
    }

    // Get weights based on preference
    final weights = RankingWeights.fromPreference(query.preference);

    // Find min/max values for normalization
    final priceRange = _findRange(candidates.map((c) => c.price).toList());
    final ratingRange = _findRange(
      candidates.where((c) => c.rating != null).map((c) => c.rating!).toList(),
      defaultMin: 0,
      defaultMax: 5,
    );
    final distanceRange = _findRange(
      candidates.where((c) => c.distanceKm != null).map((c) => c.distanceKm!).toList(),
    );
    final deliveryRange = _findRange(
      candidates.where((c) => c.deliveryMinutes != null).map((c) => c.deliveryMinutes!.toDouble()).toList(),
    );

    // Score each candidate
    for (final candidate in candidates) {
      double score = 0.0;

      // Price score (lower is better, so invert)
      final priceNorm = _normalize(
        candidate.price,
        priceRange['min']!,
        priceRange['max']!,
      );
      score += weights.price * (1 - priceNorm);

      // Rating score (higher is better)
      if (candidate.rating != null) {
        final ratingNorm = _normalize(
          candidate.rating!,
          ratingRange['min']!,
          ratingRange['max']!,
        );
        score += weights.rating * ratingNorm;
      }

      // Distance score (closer is better, so invert)
      if (candidate.distanceKm != null) {
        final distanceNorm = _normalize(
          candidate.distanceKm!,
          distanceRange['min']!,
          distanceRange['max']!,
        );
        score += weights.distance * (1 - distanceNorm);
      }

      // Delivery time score (faster is better, so invert)
      if (candidate.deliveryMinutes != null) {
        final deliveryNorm = _normalize(
          candidate.deliveryMinutes!.toDouble(),
          deliveryRange['min']!,
          deliveryRange['max']!,
        );
        score += weights.delivery * (1 - deliveryNorm);
      }

      candidate.score = score;
    }

    // Sort by score (descending)
    candidates.sort((a, b) => b.score.compareTo(a.score));

    return candidates;
  }

  /// Check if top candidates are too close in score (ambiguous)
  bool isAmbiguous(List<ShopCandidate> rankedCandidates, {double threshold = 0.05}) {
    if (rankedCandidates.length < 2) {
      return false;
    }

    final topScore = rankedCandidates[0].score;
    final secondScore = rankedCandidates[1].score;

    // If top 2 scores are within threshold, it's ambiguous
    return (topScore - secondScore).abs() < threshold;
  }

  /// Get clarifying question based on close candidates
  String? getClarifyingQuestion(List<ShopCandidate> topCandidates) {
    if (topCandidates.length < 2) {
      return null;
    }

    final first = topCandidates[0];
    final second = topCandidates[1];

    // Compare attributes to determine best question
    
    // If price difference is significant
    if ((first.price - second.price).abs() > 50) {
      return 'I found options at ₹${first.price.toInt()} and ₹${second.price.toInt()}. Do you prefer cheaper or better quality?';
    }

    // If delivery time is different
    if (first.deliveryMinutes != null && 
        second.deliveryMinutes != null && 
        (first.deliveryMinutes! - second.deliveryMinutes!).abs() > 15) {
      return 'I found options with ${first.displayDelivery} and ${second.displayDelivery} delivery. Do you prefer faster delivery?';
    }

    // If distance is different
    if (first.distanceKm != null && 
        second.distanceKm != null && 
        (first.distanceKm! - second.distanceKm!).abs() > 1) {
      return 'I found options at ${first.displayDistance} and ${second.displayDistance} away. Do you prefer nearest?';
    }

    // Default question
    return 'I found multiple options. Would you prefer fastest delivery or best quality?';
  }

  Map<String, double> _findRange(
    List<double> values, {
    double? defaultMin,
    double? defaultMax,
  }) {
    if (values.isEmpty) {
      return {
        'min': defaultMin ?? 0.0,
        'max': defaultMax ?? 1.0,
      };
    }

    return {
      'min': values.reduce(min),
      'max': values.reduce(max),
    };
  }

  double _normalize(double value, double min, double max) {
    if (max == min) return 0.5; // All values same
    return (value - min) / (max - min);
  }
}
