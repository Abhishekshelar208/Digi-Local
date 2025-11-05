import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/navigation_step_model.dart';

/// Visual overlay that shows AI navigation journey in real-time
class AIJourneyOverlay extends StatefulWidget {
  final NavigationStep currentStep;
  final int currentIndex;
  final int totalSteps;
  final VoidCallback? onStop;

  const AIJourneyOverlay({
    super.key,
    required this.currentStep,
    required this.currentIndex,
    required this.totalSteps,
    this.onStop,
  });

  @override
  State<AIJourneyOverlay> createState() => _AIJourneyOverlayState();
}

class _AIJourneyOverlayState extends State<AIJourneyOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStepColor() {
    switch (widget.currentStep.type) {
      case NavigationStepType.thinking:
        return Colors.purple;
      case NavigationStepType.navigate:
        return Colors.blue;
      case NavigationStepType.tap:
        return Colors.green;
      case NavigationStepType.scroll:
        return Colors.orange;
      case NavigationStepType.complete:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent dark overlay
        Container(
          color: Colors.black.withValues(alpha: 0.7),
        ),
        
        // Main content
        SafeArea(
          child: Column(
            children: [
              // Top bar with progress
              _buildTopBar(),
              
              const Spacer(),
              
              // Center animation and step info
              _buildCenterContent(),
              
              const Spacer(),
              
              // Bottom step indicator
              _buildBottomIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    final progress = (widget.currentIndex + 1) / widget.totalSteps;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Auto-Shopper',
                    style: GoogleFonts.blinker(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (widget.onStop != null)
                IconButton(
                  onPressed: widget.onStop,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getStepColor()),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${widget.currentIndex + 1} of ${widget.totalSteps}',
            style: GoogleFonts.blinker(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with glow effect
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _getStepColor().withValues(alpha: 0.4),
                        _getStepColor().withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getStepColor(),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getStepColor().withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.currentStep.icon,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Step title
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _getStepColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _getStepColor().withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    widget.currentStep.title,
                    style: GoogleFonts.blinker(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                // Step description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.currentStep.description,
                    style: GoogleFonts.blinker(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24),
                // Loading indicator for non-complete steps
                if (!widget.currentStep.isComplete)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(_getStepColor()),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomIndicator() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withValues(alpha: 0.8),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Sit back and watch AI shop for you',
            style: GoogleFonts.blinker(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simplified version for showing AI is working
class AIThinkingIndicator extends StatelessWidget {
  final String message;

  const AIThinkingIndicator({
    super.key,
    this.message = 'AI is thinking...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withValues(alpha: 0.8), Colors.blue.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: GoogleFonts.blinker(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
