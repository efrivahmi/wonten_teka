import 'dart:math';

class FaceMatcherService {
  /// Calculates the cosine similarity between two face embeddings (vectors).
  /// Returns a value between -1.0 and 1.0, where 1.0 is identical.
  static double calculateCosineSimilarity(List<double> vecA, List<double> vecB) {
    if (vecA.isEmpty || vecB.isEmpty || vecA.length != vecB.length) {
      return 0.0;
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < vecA.length; i++) {
      dotProduct += vecA[i] * vecB[i];
      normA += vecA[i] * vecA[i];
      normB += vecB[i] * vecB[i];
    }

    if (normA == 0 || normB == 0) return 0.0;
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  /// Checks if two embeddings match based on a threshold.
  static bool isMatch(List<double> liveEmbedding, List<double> registeredEmbedding, {double threshold = 0.75}) {
    final similarity = calculateCosineSimilarity(liveEmbedding, registeredEmbedding);
    return similarity >= threshold;
  }
}
