import 'package:asnan_hub/models/case.dart';
import 'package:flutter/material.dart';

class CaseTypesGrid extends StatefulWidget {
  CaseTypesGrid({
    super.key,
    required this.onSelected,
    this.selectedType,
  });

  final void Function(CaseType type) onSelected;
  final CaseType? selectedType;

  @override
  State<CaseTypesGrid> createState() => _CaseTypesGridState();
}

class _CaseTypesGridState extends State<CaseTypesGrid> {

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // allow it inside Column
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 buttons per row
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 4, // width/height ratio of button
      ),
      itemCount: CaseType.values.length,
      itemBuilder: (context, index) {
        final type = CaseType.values[index];
        final isSelected = type == widget.selectedType;

        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: isSelected ? 2 : 0,
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[200],
            foregroundColor: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            widget.onSelected(type);
          },
          child: Text(
            type.label,
            textAlign: TextAlign.center,
            style:Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
    );
  }
}
