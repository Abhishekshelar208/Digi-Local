import 'shop_candidate_model.dart';

enum AutoShopperAction {
  confirm,      // Show top candidate for confirmation
  clarify,      // Ask clarifying question
  noResults,    // No matches found
  error,        // Error occurred
}

class AutoShopperResult {
  final AutoShopperAction action;
  final ShopCandidate? topCandidate;
  final List<ShopCandidate> candidates;
  final String? clarificationQuestion;
  final String? errorMessage;
  final String? suggestionMessage;

  AutoShopperResult({
    required this.action,
    this.topCandidate,
    this.candidates = const [],
    this.clarificationQuestion,
    this.errorMessage,
    this.suggestionMessage,
  });

  factory AutoShopperResult.confirm(ShopCandidate candidate) {
    return AutoShopperResult(
      action: AutoShopperAction.confirm,
      topCandidate: candidate,
      candidates: [candidate],
    );
  }

  factory AutoShopperResult.clarify({
    required String question,
    required List<ShopCandidate> candidates,
  }) {
    return AutoShopperResult(
      action: AutoShopperAction.clarify,
      clarificationQuestion: question,
      candidates: candidates,
    );
  }

  factory AutoShopperResult.noResults({String? suggestion}) {
    return AutoShopperResult(
      action: AutoShopperAction.noResults,
      suggestionMessage: suggestion ?? 'No products found matching your criteria.',
    );
  }

  factory AutoShopperResult.error(String message) {
    return AutoShopperResult(
      action: AutoShopperAction.error,
      errorMessage: message,
    );
  }

  bool get hasTopCandidate => topCandidate != null;
  bool get hasCandidates => candidates.isNotEmpty;
  bool get needsClarification => action == AutoShopperAction.clarify;
}
