import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/button.dart';

class EventDateItem {
  String name;
  DateTime startDate;
  DateTime endDate;
  final Function(EventDateItem) onChanged;
  final Function(String)? onDelete;

  // Controllers
  final TextEditingController nameController;
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  // Date formatters
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _timeFormat = DateFormat('h:mm a'); // 12-hour format with AM/PM

  EventDateItem({
    required String initialName,
    required this.startDate,
    required this.endDate,
    required this.onChanged,
    this.onDelete,
  })  : name = initialName,
        nameController = TextEditingController(text: initialName) {
    _updateControllers();

    // Listen for name changes
    nameController.addListener(() {
      name = nameController.text;
      onChanged(this);
    });
  }

  void dispose() {
    nameController.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    endDateController.dispose();
    endTimeController.dispose();
  }

  void _updateControllers() {
    // Format dates using DateFormat
    startDateController.text = _dateFormat.format(startDate);
    endDateController.text = _dateFormat.format(endDate);

    // Format times in 12-hour format with AM/PM
    startTimeController.text = _timeFormat.format(startDate);
    endTimeController.text = _timeFormat.format(endDate);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: LivitColors.whiteActive,
              onPrimary: LivitColors.mainBlack,
              surface: LivitColors.mainBlack,
              onSurface: LivitColors.whiteActive,
            ),
            dialogBackgroundColor: LivitColors.mainBlack,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != startDate) {
      startDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        startDate.hour,
        startDate.minute,
      );

      // If end date is before start date, update end date
      if (endDate.isBefore(startDate)) {
        endDate = startDate.add(const Duration(hours: 4));
      }

      _updateControllers();
      onChanged(this);
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: startDate.hour, minute: startDate.minute),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: LivitColors.whiteActive,
              onPrimary: LivitColors.mainBlack,
              surface: LivitColors.mainBlack,
              onSurface: LivitColors.whiteActive,
              secondary: LivitColors.mainBlueActive,
            ),
            dialogBackgroundColor: LivitColors.mainBlack,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      startDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        picked.hour,
        picked.minute,
      );

      // If end time is before start time on the same day, update end time
      if (endDate.year == startDate.year &&
          endDate.month == startDate.month &&
          endDate.day == startDate.day &&
          (endDate.hour < startDate.hour || (endDate.hour == startDate.hour && endDate.minute < startDate.minute))) {
        endDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          startDate.hour + 2,
          startDate.minute,
        );
      }

      _updateControllers();
      onChanged(this);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: LivitColors.whiteActive,
              onPrimary: LivitColors.mainBlack,
              surface: LivitColors.mainBlack,
              onSurface: LivitColors.whiteActive,
            ),
            dialogBackgroundColor: LivitColors.mainBlack,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != endDate) {
      endDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        endDate.hour,
        endDate.minute,
      );

      _updateControllers();
      onChanged(this);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: endDate.hour, minute: endDate.minute),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: LivitColors.whiteActive,
              onPrimary: LivitColors.mainBlack,
              surface: LivitColors.mainBlack,
              onSurface: LivitColors.whiteActive,
            ),
            dialogBackgroundColor: LivitColors.mainBlack,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // If end time is on the same day as start time, validate it's after start time
      if (endDate.year == startDate.year &&
          endDate.month == startDate.month &&
          endDate.day == startDate.day &&
          (picked.hour < startDate.hour || (picked.hour == startDate.hour && picked.minute < startDate.minute))) {
        // Show error or set a default time after start time
        endDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          startDate.hour + 2,
          startDate.minute,
        );
      } else {
        endDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          picked.hour,
          picked.minute,
        );
      }

      _updateControllers();
      onChanged(this);
    }
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: LivitContainerStyle.padding(padding: [null, null, LivitSpaces.xsDouble, null]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: LivitTextField(
                  controller: nameController,
                  hint: 'Nombre de la fecha',
                  prefixIcon: CupertinoIcons.tag,
                ),
              ),
              if (onDelete != null) ...[
                LivitSpaces.s,
                Button.icon(
                  activeColor: LivitColors.red,
                  activeBackgroundColor: Colors.transparent,
                  isIconBig: false,
                  isActive: true,
                  onTap: () => onDelete!(name),
                  icon: CupertinoIcons.delete,
                ),
              ]
            ],
          ),
          LivitSpaces.s,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.door_front_door_outlined,
                          size: LivitButtonStyle.iconSize,
                          color: LivitColors.whiteActive,
                        ),
                        LivitSpaces.xs,
                        LivitText(
                          'Abren puertas',
                        ),
                      ],
                    ),
                    LivitSpaces.xs,
                    GestureDetector(
                      onTap: () => _selectStartDate(context),
                      child: LivitTextField(
                        controller: startDateController,
                        hint: 'Fecha inicio',
                        prefixIcon: CupertinoIcons.calendar,
                        isEnabled: false,
                        removeSuffixIcon: true,
                      ),
                    ),
                  ],
                ),
              ),
              LivitSpaces.s,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LivitText('', textType: LivitTextType.small),
                    LivitSpaces.xs,
                    GestureDetector(
                      onTap: () => _selectStartTime(context),
                      child: LivitTextField(
                        controller: startTimeController,
                        hint: 'Hora inicio',
                        prefixIcon: CupertinoIcons.time,
                        isEnabled: false,
                        removeSuffixIcon: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          LivitSpaces.s,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.door_back_door_outlined,
                          size: LivitButtonStyle.iconSize,
                          color: LivitColors.whiteActive,
                        ),
                        LivitSpaces.xs,
                        LivitText(
                          'Cierran puertas',
                        ),
                      ],
                    ),
                    LivitSpaces.xs,
                    GestureDetector(
                      onTap: () => _selectEndDate(context),
                      child: LivitTextField(
                        controller: endDateController,
                        hint: 'Fecha fin',
                        prefixIcon: CupertinoIcons.calendar,
                        isEnabled: false,
                        removeSuffixIcon: true,
                      ),
                    ),
                  ],
                ),
              ),
              LivitSpaces.s,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LivitText('', textType: LivitTextType.small),
                    LivitSpaces.xs,
                    GestureDetector(
                      onTap: () => _selectEndTime(context),
                      child: LivitTextField(
                        controller: endTimeController,
                        hint: 'Hora fin',
                        prefixIcon: CupertinoIcons.time,
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
