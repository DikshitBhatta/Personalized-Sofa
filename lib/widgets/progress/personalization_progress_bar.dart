import 'package:flutter/material.dart';
import 'package:timberr/constants.dart';

class PersonalizationProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<bool> stepCompletionStatus;
  
  const PersonalizationProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepCompletionStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Progress indicators
          Row(
            children: List.generate(totalSteps, (index) {
              final isCompleted = stepCompletionStatus.length > index && stepCompletionStatus[index];
              final isPast = currentStep > index;
              
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCompleted || isPast ? kSeaGreen : kChristmasSilver,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < totalSteps - 1) const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isCompleted = stepCompletionStatus.length > index && stepCompletionStatus[index];
              final isCurrent = currentStep == index;
              final isPast = currentStep > index;
              
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? kSeaGreen : (isCurrent ? kOffBlack : kChristmasSilver),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '${index + 1}',
                          style: kNunitoSans14.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? Colors.white : (isPast ? Colors.white : kTinGrey),
                          ),
                        ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 8),
          
          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Audience', style: TextStyle(fontSize: 10, color: kTinGrey)),
              Text('Health', style: TextStyle(fontSize: 10, color: kTinGrey)),
              Text('Style', style: TextStyle(fontSize: 10, color: kTinGrey)),
              Text('Details', style: TextStyle(fontSize: 10, color: kTinGrey)),
            ],
          ),
        ],
      ),
    );
  }
}
