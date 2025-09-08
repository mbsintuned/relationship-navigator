import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/assessment_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/empty_state.dart';

class AssessmentListScreen extends ConsumerWidget {
  const AssessmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personality Assessments'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAssessmentInfo(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(theme.customSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Text(
                'Discover Your Personality',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: theme.customSpacing.sm),
              Text(
                'Understanding your personality helps build better relationships. Complete these assessments to get personalized insights.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              SizedBox(height: theme.customSpacing.lg),
              
              // Assessment categories
              Expanded(
                child: _buildAssessmentList(context, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentList(BuildContext context, ThemeData theme) {
    // In a real app, this would come from a provider
    final assessments = _getMockAssessments();
    
    if (assessments.isEmpty) {
      return const EmptyState(
        title: 'No Assessments Available',
        description: 'Check back later for new personality assessments.',
      );
    }

    return ListView.separated(
      itemCount: assessments.length,
      separatorBuilder: (context, index) => SizedBox(height: theme.customSpacing.md),
      itemBuilder: (context, index) {
        final assessment = assessments[index];
        return _AssessmentCard(
          assessment: assessment,
          onTap: () => _startAssessment(context, assessment),
        );
      },
    );
  }

  void _startAssessment(BuildContext context, Assessment assessment) {
    context.push('/assessment/take/${assessment.id}');
  }

  void _showAssessmentInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Assessments'),
        content: const Text(
          'These scientifically-based assessments help you understand your personality, attachment style, and relationship patterns. '
          'All data is kept private and secure. You can retake assessments anytime to track changes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  List<Assessment> _getMockAssessments() {
    return [
      Assessment(
        id: 'big_five',
        name: 'Big Five Personality Assessment',
        category: 'personality',
        version: '1.0',
        description: 'Discover your personality across five major dimensions: Openness, Conscientiousness, Extraversion, Agreeableness, and Neuroticism.',
        instructions: 'Rate each statement based on how accurately it describes you.',
        timeLimitMinutes: 30,
        scoring: const AssessmentScoring(
          dimensions: ['openness', 'conscientiousness', 'extraversion', 'agreeableness', 'neuroticism'],
          scaleRange: [1, 5],
          questionsPerDimension: 10,
          reverseScoringEnabled: true,
        ),
        scaleLabels: const {
          '1': 'Very Inaccurate',
          '2': 'Moderately Inaccurate',
          '3': 'Neither Accurate nor Inaccurate',
          '4': 'Moderately Accurate',
          '5': 'Very Accurate',
        },
        questions: [], // Would be loaded from backend
        interpretationRanges: const {},
        dimensionDescriptions: const {},
      ),
      Assessment(
        id: 'attachment_styles',
        name: 'Adult Attachment Styles',
        category: 'relational',
        version: '1.0',
        description: 'Understand how you connect with others in close relationships. Discover your attachment pattern and how it affects your relationships.',
        instructions: 'Think about your close relationships and rate how much each statement describes you.',
        timeLimitMinutes: 15,
        scoring: const AssessmentScoring(
          dimensions: ['secure', 'anxious_preoccupied', 'dismissive_avoidant', 'fearful_avoidant'],
          scaleRange: [1, 7],
          resultType: 'primary_and_scores',
        ),
        scaleLabels: const {
          '1': 'Strongly Disagree',
          '2': 'Disagree',
          '3': 'Slightly Disagree',
          '4': 'Neither Agree nor Disagree',
          '5': 'Slightly Agree',
          '6': 'Agree',
          '7': 'Strongly Agree',
        },
        questions: [], // Would be loaded from backend
        interpretationRanges: const {},
        dimensionDescriptions: const {},
      ),
      Assessment(
        id: 'emotional_intelligence',
        name: 'Emotional Intelligence Assessment',
        category: 'emotional',
        version: '1.0',
        description: 'Measure your ability to recognize, understand, and manage emotions in yourself and others.',
        instructions: 'Consider how you typically handle emotions and social situations.',
        timeLimitMinutes: 25,
        scoring: const AssessmentScoring(
          dimensions: ['self_awareness', 'self_management', 'social_awareness', 'relationship_management'],
          scaleRange: [1, 5],
          questionsPerDimension: 15,
        ),
        scaleLabels: const {
          '1': 'Never',
          '2': 'Rarely',
          '3': 'Sometimes',
          '4': 'Often',
          '5': 'Always',
        },
        questions: [], // Would be loaded from backend
        interpretationRanges: const {},
        dimensionDescriptions: const {},
      ),
      Assessment(
        id: 'love_languages',
        name: 'Love Languages Assessment',
        category: 'relational',
        version: '1.0',
        description: 'Discover how you prefer to give and receive love. Understanding your love language improves relationship satisfaction.',
        instructions: 'Choose which scenario you would prefer in each situation.',
        timeLimitMinutes: 10,
        scoring: const AssessmentScoring(
          dimensions: ['words_of_affirmation', 'acts_of_service', 'receiving_gifts', 'quality_time', 'physical_touch'],
          resultType: 'ranking',
        ),
        scaleLabels: const {},
        questions: [], // Would be loaded from backend
        interpretationRanges: const {},
        dimensionDescriptions: const {},
      ),
    ];
  }
}

class _AssessmentCard extends StatelessWidget {
  final Assessment assessment;
  final VoidCallback onTap;

  const _AssessmentCard({
    required this.assessment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.customColors;
    
    return CustomCard(
      padding: EdgeInsets.all(theme.customSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category icon and color
              Container(
                padding: EdgeInsets.all(theme.customSpacing.sm),
                decoration: BoxDecoration(
                  color: ThemeHelpers.assessmentCategoryColor(context, assessment.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(assessment.category),
                  color: ThemeHelpers.assessmentCategoryColor(context, assessment.category),
                  size: 24,
                ),
              ),
              SizedBox(width: theme.customSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment.name,
                      style: theme.customTextStyles.insightTitle,
                    ),
                    SizedBox(height: theme.customSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        SizedBox(width: theme.customSpacing.xs),
                        Text(
                          '${assessment.timeLimitMinutes} minutes',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(width: theme.customSpacing.md),
                        _CategoryChip(category: assessment.category),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: theme.customSpacing.md),
          Text(
            assessment.description,
            style: theme.customTextStyles.insightDescription,
          ),
          SizedBox(height: theme.customSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onTap,
                  child: const Text('Start Assessment'),
                ),
              ),
              SizedBox(width: theme.customSpacing.sm),
              IconButton(
                onPressed: () => _showAssessmentDetails(context),
                icon: const Icon(Icons.info_outline),
                tooltip: 'More information',
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'personality':
        return Icons.psychology;
      case 'relational':
        return Icons.favorite;
      case 'emotional':
        return Icons.mood;
      case 'alternative':
        return Icons.auto_awesome;
      default:
        return Icons.quiz;
    }
  }

  void _showAssessmentDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return _AssessmentDetailsSheet(
            assessment: assessment,
            scrollController: scrollController,
            onStartAssessment: onTap,
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Chip(
      label: Text(
        _formatCategoryName(category),
        style: theme.textTheme.bodySmall?.copyWith(
          color: ThemeHelpers.assessmentCategoryColor(context, category),
          fontSize: 10,
        ),
      ),
      backgroundColor: ThemeHelpers.assessmentCategoryColor(context, category).withOpacity(0.1),
      side: BorderSide(
        color: ThemeHelpers.assessmentCategoryColor(context, category).withOpacity(0.3),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'personality':
        return 'PERSONALITY';
      case 'relational':
        return 'RELATIONSHIPS';
      case 'emotional':
        return 'EMOTIONAL';
      case 'alternative':
        return 'ALTERNATIVE';
      default:
        return category.toUpperCase();
    }
  }
}

class _AssessmentDetailsSheet extends StatelessWidget {
  final Assessment assessment;
  final ScrollController scrollController;
  final VoidCallback onStartAssessment;

  const _AssessmentDetailsSheet({
    required this.assessment,
    required this.scrollController,
    required this.onStartAssessment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: theme.customSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(theme.customSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(theme.customSpacing.md),
                        decoration: BoxDecoration(
                          color: ThemeHelpers.assessmentCategoryColor(context, assessment.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.psychology,
                          color: ThemeHelpers.assessmentCategoryColor(context, assessment.category),
                          size: 32,
                        ),
                      ),
                      SizedBox(width: theme.customSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assessment.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: theme.customSpacing.xs),
                            _CategoryChip(category: assessment.category),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: theme.customSpacing.lg),
                  
                  // Assessment info
                  _InfoSection(
                    title: 'Description',
                    content: assessment.description,
                  ),
                  
                  _InfoSection(
                    title: 'Instructions',
                    content: assessment.instructions,
                  ),
                  
                  _InfoSection(
                    title: 'Assessment Details',
                    content: 'Time limit: ${assessment.timeLimitMinutes} minutes\n'
                        'Questions: ${assessment.questions.length}\n'
                        'Category: ${_formatCategoryName(assessment.category)}',
                  ),
                  
                  if (assessment.scoring.dimensions?.isNotEmpty == true) ...[
                    _InfoSection(
                      title: 'What You\'ll Discover',
                      content: 'This assessment measures:\n${assessment.scoring.dimensions!.map((d) => '• ${_formatDimensionName(d)}').join('\n')}',
                    ),
                  ],
                  
                  SizedBox(height: theme.customSpacing.lg),
                  
                  // Privacy notice
                  Container(
                    padding: EdgeInsets.all(theme.customSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: theme.customSpacing.sm),
                        Expanded(
                          child: Text(
                            'Your responses are private and secure. Data is stored locally and encrypted.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: theme.customSpacing.xl),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Container(
            padding: EdgeInsets.all(theme.customSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: theme.customSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onStartAssessment();
                      },
                      child: const Text('Start Assessment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCategoryName(String category) {
    return category.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  String _formatDimensionName(String dimension) {
    return dimension.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;

  const _InfoSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: theme.customSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: theme.customSpacing.sm),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
