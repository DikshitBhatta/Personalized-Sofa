import 'package:flutter/material.dart';
import 'package:timberr/constants.dart';

class PersonalizationProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<bool> stepCompletionStatus;
  final List<String>? stepLabels;
  
  const PersonalizationProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepCompletionStatus,
    this.stepLabels,
  });

  // Calculate visible window of 4 steps
  List<int> _getVisibleSteps() {
    const int windowSize = 4;
    int startIndex;
    
    if (currentStep <= 1) {
      // Show steps 0,1,2,3 when on step 0 or 1
      startIndex = 0;
    } else if (currentStep >= totalSteps - 2) {
      // Show last 4 steps when near the end
      startIndex = totalSteps - windowSize;
    } else {
      // Show current step in position 1 (second position)
      startIndex = currentStep - 1;
    }
    
    // Ensure we don't go out of bounds
    startIndex = startIndex.clamp(0, totalSteps - windowSize);
    
    return List.generate(windowSize, (i) => startIndex + i)
        .where((index) => index < totalSteps)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleSteps = _getVisibleSteps();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicators
          SizedBox(
            width: double.infinity,
            child: Row(
              children: List.generate(visibleSteps.length, (i) {
                final index = visibleSteps[i];
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
                      if (i < visibleSteps.length - 1) const SizedBox(width: 8),
                    ],
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: visibleSteps.map((index) {
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
            }).toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: visibleSteps.map((index) {
              final label = stepLabels != null && stepLabels!.length > index 
                  ? stepLabels![index] 
                  : 'Step ${index + 1}';
              return Flexible(
                child: Text(
                  label, 
                  style: const TextStyle(fontSize: 10, color: kTinGrey),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
