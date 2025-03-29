import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/models/price/price.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class TicketTypeField extends StatefulWidget {
  final EventTicketType ticketType;
  final List<EventDate> availableDates;
  final Function(EventTicketType) onDelete;
  final Function(EventTicketType, EventTicketType) onUpdate;

  const TicketTypeField({
    super.key,
    required this.ticketType,
    required this.onDelete,
    required this.onUpdate,
    required this.availableDates,
  });

  @override
  State<TicketTypeField> createState() => _TicketTypeFieldState();
}

class _TicketTypeFieldState extends State<TicketTypeField> {
  bool isExpanded = false;
  final LivitDebugger _debugger = const LivitDebugger('ticket_type_field', isDebugEnabled: false);

  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController quantityController;
  late final TextEditingController descriptionController;

  List<EventDateTimeSlot> selectedTimeSlots = [];

  @override
  void initState() {
    super.initState();

    for (final timeSlot in widget.ticketType.validTimeSlots) {
      selectedTimeSlots.add(EventDateTimeSlot(
        dateName: timeSlot.dateName, // Force new string
        startTime: timeSlot.startTime, // Timestamp should be immutable
        endTime: timeSlot.endTime, // Timestamp should be immutable
      ));
    }

    // Initialize controllers with current ticket values
    nameController = TextEditingController(text: widget.ticketType.name);
    descriptionController = TextEditingController(text: widget.ticketType.description);
    quantityController = TextEditingController(text: (widget.ticketType.totalQuantity ?? '').toString());
    priceController = TextEditingController(text: (widget.ticketType.price.amount ?? '').toString());

    nameController.addListener(_updateTicketType);
    priceController.addListener(_updateTicketType);
    quantityController.addListener(_updateTicketType);
    descriptionController.addListener(_updateTicketType);

    priceController.addListener(_validateNumberInput);
    quantityController.addListener(_validateNumberInput);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _validateNumberInput() {
    if (priceController.text.isNotEmpty) {
      try {
        double.parse(priceController.text);
      } catch (e) {
        priceController.text = '';
      }
    }
    if (quantityController.text.isNotEmpty) {
      try {
        int.parse(quantityController.text);
      } catch (e) {
        quantityController.text = '';
      }
    }
  }

  void _updateTicketType({bool forceUpdate = false}) {
    _debugger.debPrint('Updating ticket type', DebugMessageType.updating);
    // Parse price
    double? priceAmount;
    try {
      if (priceController.text.isNotEmpty) {
        priceAmount = double.parse(priceController.text);
      }
    } catch (e) {
      // Use default value if parsing fails
    }

    // Parse quantity
    int? quantity;
    try {
      if (quantityController.text.isNotEmpty) {
        quantity = int.parse(quantityController.text);
      }
    } catch (e) {
      // Use default value if parsing fails
    }

    final updatedTicket = EventTicketType(
      name: nameController.text,
      totalQuantity: quantity,
      validTimeSlots: selectedTimeSlots,
      description: descriptionController.text,
      price: LivitPrice(
        amount: priceAmount,
        currency: widget.ticketType.price.currency,
      ),
    );

    final List<EventDateTimeSlot> widgetTicketTypeValidTimeSlots = widget.availableDates
        .map((date) => EventDateTimeSlot(dateName: date.name, startTime: date.startTime, endTime: date.endTime))
        .toList();

    final bool isTicketNameChanged = widget.ticketType.name != updatedTicket.name;
    final bool isTicketQuantityChanged = widget.ticketType.totalQuantity != updatedTicket.totalQuantity;
    final bool isTicketTimeSlotsChanged =
        widgetTicketTypeValidTimeSlots.any((e) => !updatedTicket.validTimeSlots.any((t) => t.dateName == e.dateName));
    final bool isTicketDescriptionChanged = widget.ticketType.description != updatedTicket.description;
    final bool isTicketPriceChanged = widget.ticketType.price.amount != updatedTicket.price.amount;

    // Only update if there's an actual change
    if (isTicketNameChanged ||
        isTicketQuantityChanged ||
        isTicketTimeSlotsChanged ||
        isTicketDescriptionChanged ||
        isTicketPriceChanged ||
        forceUpdate) {
      _debugger.debPrint('Updated ticket: $updatedTicket', DebugMessageType.done);
      widget.onUpdate(widget.ticketType, updatedTicket);
    } else {
      _debugger.debPrint('No changes in ticket, skipping update', DebugMessageType.info);
    }
  }

  Widget _buildDateSelector() {
    // Ensure the selectedDateName exists in available dates
    bool dateNameExists = widget.availableDates.any((date) => selectedTimeSlots.any((timeSlot) => timeSlot.dateName == date.name));
    if (!dateNameExists && selectedTimeSlots.isNotEmpty) {
      _debugger.debPrint('No date name exists, picking first available date', DebugMessageType.info);
      if (widget.availableDates.isNotEmpty) {
        final firstAvailableDate = widget.availableDates.first;
        selectedTimeSlots = [
          EventDateTimeSlot(
            dateName: firstAvailableDate.name,
            startTime: firstAvailableDate.startTime,
            endTime: firstAvailableDate.endTime,
          )
        ];
      } else {
        selectedTimeSlots = [];
      }
    }

    return LivitBar(
      noPadding: true,
      shadowType: ShadowType.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LivitBar(
            shadowType: ShadowType.weak,
            child: Center(
              child: LivitText(
                'Ticket valido para las siguientes fechas',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          LivitSpaces.xs,
          LivitText(
            'Presiona para seleccionar o eliminar las fechas que quieres que el tiquete sea valido.',
            color: LivitColors.whiteInactive,
            textType: LivitTextType.small,
          ),
          LivitSpaces.s,
          if (widget.availableDates.isEmpty)
            LivitBar(
              shadowType: ShadowType.weak,
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: LivitColors.whiteActive,
                    size: LivitButtonStyle.iconSize,
                  ),
                  LivitSpaces.xs,
                  LivitText('Agrega primero una fecha'),
                ],
              )),
            )
          else
            ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => _buildDateSelectorItem(index),
              separatorBuilder: (context, index) => LivitSpaces.s,
              itemCount: widget.availableDates.length,
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelectorItem(int index) {
    final bool isSelected = selectedTimeSlots.any((timeSlot) => timeSlot.dateName == widget.availableDates[index].name);

    final TextEditingController startDateController = TextEditingController();
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();

    if (isSelected) {
      startDateController.text = DateFormat('dd/MM/yyyy')
          .format(selectedTimeSlots.firstWhere((timeSlot) => timeSlot.dateName == widget.availableDates[index].name).startTime.toDate());
      startTimeController.text = DateFormat('h:mm a')
          .format(selectedTimeSlots.firstWhere((timeSlot) => timeSlot.dateName == widget.availableDates[index].name).startTime.toDate());
      endDateController.text = DateFormat('dd/MM/yyyy')
          .format(selectedTimeSlots.firstWhere((timeSlot) => timeSlot.dateName == widget.availableDates[index].name).endTime.toDate());
      endTimeController.text = DateFormat('h:mm a')
          .format(selectedTimeSlots.firstWhere((timeSlot) => timeSlot.dateName == widget.availableDates[index].name).endTime.toDate());
    }

    return LivitBar.touchable(
      key: ValueKey('ticket_type_field_item_${index}_${isSelected ? 'selected' : 'not_selected'}'),
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedTimeSlots.removeWhere((timeSlot) => timeSlot.dateName == widget.availableDates[index].name);
          } else {
            selectedTimeSlots.add(EventDateTimeSlot(
                dateName: widget.availableDates[index].name.toString(),
                startTime: widget.availableDates[index].startTime,
                endTime: widget.availableDates[index].endTime));
          }
        });
        _updateTicketType(forceUpdate: true);
      },
      shadowType: isSelected ? ShadowType.normal : ShadowType.weak,
      child: Padding(
        padding: LivitContainerStyle.padding(padding: [null, null, null, null]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LivitText(widget.availableDates[index].name,
                    color: isSelected ? LivitColors.whiteActive : LivitColors.whiteInactive, fontWeight: FontWeight.bold),
                LivitSpaces.xs,
                Icon(
                  isSelected ? CupertinoIcons.checkmark_alt_circle : CupertinoIcons.multiply_circle,
                  color: isSelected ? LivitColors.whiteActive : LivitColors.whiteInactive,
                  size: LivitButtonStyle.iconSize,
                ),
              ],
            ),
            if (isSelected) ...[
              LivitSpaces.s,
              LivitText('Valido desde:', color: LivitColors.whiteInactive),
              LivitSpaces.xs,
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      onTap: () =>
                          _selectStartDate(context, widget.availableDates[index].startTime.toDate(), widget.availableDates[index].name),
                      child: Container(
                        color: Colors.transparent,
                        child: IgnorePointer(
                          ignoring: true,
                          child: LivitTextField(
                            controller: startDateController,
                            hint: 'Fecha',
                            removeSuffixIcon: true,
                            disableCheckValidity: true,
                            prefixIcon: CupertinoIcons.calendar,
                          ),
                        ),
                      ),
                    ),
                  ),
                  LivitSpaces.s,
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      onTap: () =>
                          _selectStartTime(context, widget.availableDates[index].startTime.toDate(), widget.availableDates[index].name),
                      child: Container(
                        color: Colors.transparent,
                        child: IgnorePointer(
                          ignoring: true,
                          child: LivitTextField(
                            controller: startTimeController,
                            hint: 'Hora',
                            removeSuffixIcon: true,
                            disableCheckValidity: true,
                            prefixIcon: CupertinoIcons.clock,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              LivitSpaces.s,
              LivitText('Valido hasta:', color: LivitColors.whiteInactive),
              LivitSpaces.xs,
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      onTap: () =>
                          _selectEndDate(context, widget.availableDates[index].endTime.toDate(), widget.availableDates[index].name),
                      child: Container(
                        color: Colors.transparent,
                        child: IgnorePointer(
                          ignoring: true,
                          child: LivitTextField(
                            controller: endDateController,
                            hint: 'Fecha',
                            removeSuffixIcon: true,
                            disableCheckValidity: true,
                            prefixIcon: CupertinoIcons.calendar,
                          ),
                        ),
                      ),
                    ),
                  ),
                  LivitSpaces.s,
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      onTap: () =>
                          _selectEndTime(context, widget.availableDates[index].endTime.toDate(), widget.availableDates[index].name),
                      child: Container(
                        color: Colors.transparent,
                        child: IgnorePointer(
                          ignoring: true,
                          child: LivitTextField(
                            controller: endTimeController,
                            hint: 'Hora',
                            removeSuffixIcon: true,
                            disableCheckValidity: true,
                            prefixIcon: CupertinoIcons.clock,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _selectStartDate(BuildContext context, DateTime startDate, String dateName) async {
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
    if (picked != null) {
      final newSelectedTimeSlot = selectedTimeSlots.firstWhere((timeSlot) => timeSlot.dateName == dateName).copyWith(startTime: picked);
      setState(() {
        selectedTimeSlots.removeWhere((timeSlot) => timeSlot.dateName == dateName);
        selectedTimeSlots.add(newSelectedTimeSlot);
      });
      _updateTicketType(forceUpdate: true);
    }
  }

  void _selectStartTime(BuildContext context, DateTime startTime, String dateName) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: startTime.hour, minute: startTime.minute),
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
      final newStartTime = DateTime(startTime.year, startTime.month, startTime.day, picked.hour, picked.minute);
      final newSelectedTimeSlot =
          selectedTimeSlots.firstWhere((timeSlot) => timeSlot.dateName == dateName).copyWith(startTime: newStartTime);
      setState(() {
        selectedTimeSlots.removeWhere((timeSlot) => timeSlot.dateName == dateName);
        selectedTimeSlots.add(newSelectedTimeSlot);
      });
      _updateTicketType(forceUpdate: true);
    }
  }

  void _selectEndDate(BuildContext context, DateTime endDate, String dateName) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
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
    if (picked != null) {
      final newSelectedTimeSlot = selectedTimeSlots.firstWhere((timeSlot) => timeSlot.dateName == dateName).copyWith(endTime: picked);
      setState(() {
        selectedTimeSlots.removeWhere((timeSlot) => timeSlot.dateName == dateName);
        selectedTimeSlots.add(newSelectedTimeSlot);
      });
      _updateTicketType(forceUpdate: true);
    }
  }

  void _selectEndTime(BuildContext context, DateTime endTime, String dateName) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: endTime.hour, minute: endTime.minute),
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
      final newEndTime = DateTime(endTime.year, endTime.month, endTime.day, picked.hour, picked.minute);
      final newSelectedTimeSlot = selectedTimeSlots.firstWhere((timeSlot) => timeSlot.dateName == dateName).copyWith(endTime: newEndTime);
      setState(() {
        selectedTimeSlots.removeWhere((timeSlot) => timeSlot.dateName == dateName);
        selectedTimeSlots.add(newSelectedTimeSlot);
      });
      _updateTicketType(forceUpdate: true);
    }
  }

  bool _isTicketValid() {
    _debugger.debPrint('Starting ticket validation', DebugMessageType.verifying);

    // Check name
    final bool isNameValid = _isNameValid();
    _debugger.debPrint('Name valid: $isNameValid', DebugMessageType.info);

    // Check price amount exists
    final bool isPriceAmountExists = widget.ticketType.price.amount != null;
    _debugger.debPrint('Price amount exists: $isPriceAmountExists', DebugMessageType.info);

    // Check price is not zero
    final bool isPriceNonNegative = widget.ticketType.price.amount != null && widget.ticketType.price.amount! >= 0;
    _debugger.debPrint('Price is non-negative: $isPriceNonNegative', DebugMessageType.info);

    // Check price is double
    final bool isPriceDouble = widget.ticketType.price.amount is double;
    _debugger.debPrint('Price is double: $isPriceDouble', DebugMessageType.info);

    // Check currency exists
    final bool isCurrencyExists = widget.ticketType.price.currency != null;
    _debugger.debPrint('Currency exists: $isCurrencyExists', DebugMessageType.info);

    // Check quantity exists
    final bool isQuantityExists = widget.ticketType.totalQuantity != null && widget.ticketType.totalQuantity! > 0;
    _debugger.debPrint('Quantity exists: $isQuantityExists', DebugMessageType.info);

    // Check quantity is int
    final bool isQuantityInt = widget.ticketType.totalQuantity is int;
    _debugger.debPrint('Quantity is int: $isQuantityInt', DebugMessageType.info);

    // Check description
    final bool isDescriptionValid = _isDescriptionValid();
    _debugger.debPrint('Description valid: $isDescriptionValid', DebugMessageType.info);

    // Check time slots
    final bool hasTimeSlots = selectedTimeSlots.isNotEmpty;
    _debugger.debPrint('Has time slots: $hasTimeSlots', DebugMessageType.info);

    // Overall validation
    final bool isValid = isNameValid &&
        isPriceAmountExists &&
        isPriceNonNegative &&
        isPriceDouble &&
        isCurrencyExists &&
        isQuantityExists &&
        isQuantityInt &&
        isDescriptionValid &&
        hasTimeSlots;

    _debugger.debPrint('Final validation result: $isValid', DebugMessageType.done);

    // Provide additional debug info for failures
    if (!isValid) {
      _debugger.debPrint('Ticket validation failed. Details:', DebugMessageType.error);

      if (!isNameValid) {
        _debugger.debPrint('- Name is invalid or empty', DebugMessageType.error);
      }
      if (!isPriceAmountExists) {
        _debugger.debPrint('- Price amount is null', DebugMessageType.error);
      }
      if (!isPriceNonNegative) {
        _debugger.debPrint('- Price amount is negative', DebugMessageType.error);
      }
      if (!isPriceDouble) {
        _debugger.debPrint('- Price amount is not a double: ${widget.ticketType.price.amount.runtimeType}', DebugMessageType.error);
      }
      if (!isCurrencyExists) {
        _debugger.debPrint('- Currency is null', DebugMessageType.error);
      }
      if (!isQuantityExists) {
        _debugger.debPrint('- Total quantity is null', DebugMessageType.error);
      }
      if (!isQuantityInt) {
        _debugger.debPrint('- Total quantity is not an int: ${widget.ticketType.totalQuantity.runtimeType}', DebugMessageType.error);
      }
      if (!isDescriptionValid) {
        _debugger.debPrint('- Description is invalid', DebugMessageType.error);
      }
      if (!hasTimeSlots) {
        _debugger.debPrint('- No time slots selected', DebugMessageType.error);
      }
    }

    return isValid;
  }

  bool _isDescriptionValid() {
    return widget.ticketType.description != null &&
        widget.ticketType.description != '' &&
        (widget.ticketType.description?.length ?? 0) <= 200;
  }

  bool _isNameValid() {
    return widget.ticketType.name != null && widget.ticketType.name != '' && (widget.ticketType.name?.length ?? 0) <= 100;
  }

  Widget _buildDescriptionCharCount() {
    int charCount = descriptionController.text.trim().length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitSpaces.s,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LivitText('$charCount/200 caracteres',
                textType: LivitTextType.regular, color: charCount > 200 ? LivitColors.yellowError : LivitColors.whiteInactive),
          ],
        ),
      ],
    );
  }

  Widget _buildNameCharCount() {
    int charCount = nameController.text.trim().length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitSpaces.s,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LivitText('$charCount/100 caracteres',
                textType: LivitTextType.regular, color: charCount > 200 ? LivitColors.yellowError : LivitColors.whiteInactive),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LivitBar(
      key: ValueKey('ticket_bar_$isExpanded'),
      shadowType: isExpanded ? ShadowType.weak : ShadowType.none,
      noPadding: true,
      child: Column(
        children: [
          LivitBar.touchable(
            shadowType: ShadowType.weak,
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            noPadding: true,
            child: Padding(
              padding: LivitContainerStyle.padding(padding: [null, null, 0, null]),
              child: Column(
                children: [
                  LivitText(
                    (widget.ticketType.name == '' || widget.ticketType.name == null) ? 'Ticket sin nombre' : widget.ticketType.name!,
                    textType: LivitTextType.smallTitle,
                  ),
                  LivitSpaces.xs,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.money_dollar_circle,
                                color: LivitColors.whiteActive,
                                size: LivitButtonStyle.iconSize,
                              ),
                              LivitSpaces.xs,
                              if (widget.ticketType.price.amount != null && widget.ticketType.price.currency != null)
                                LivitText('${widget.ticketType.price.formatPrice()} ${widget.ticketType.price.currency}',
                                    textType: LivitTextType.small)
                              else
                                LivitText('Sin precio', textType: LivitTextType.small),
                            ],
                          ),
                          LivitSpaces.xs,
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.tickets,
                                color: LivitColors.whiteActive,
                                size: LivitButtonStyle.iconSize,
                              ),
                              LivitSpaces.xs,
                              if (widget.ticketType.totalQuantity != null)
                                LivitText('${widget.ticketType.totalQuantity} entradas disponibles', textType: LivitTextType.small)
                              else
                                LivitText('Sin cantidad disponible', textType: LivitTextType.small),
                            ],
                          ),
                          LivitSpaces.xs,
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.calendar,
                                color: LivitColors.whiteActive,
                                size: LivitButtonStyle.iconSize,
                              ),
                              LivitSpaces.xs,
                              if (selectedTimeSlots.isNotEmpty)
                                LivitText(selectedTimeSlots.map((timeSlot) => timeSlot.dateName).join(', '), textType: LivitTextType.small)
                              else
                                LivitText('Sin fecha', textType: LivitTextType.small),
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        CupertinoIcons.circle_filled,
                        color: _isTicketValid() ? LivitColors.mainBlueActive : LivitColors.red,
                        size: LivitButtonStyle.iconSize / 2,
                      ),
                    ],
                  ),
                  IgnorePointer(
                    ignoring: true,
                    child: Button.whiteText(
                      bold: false,
                      text: isExpanded ? 'Ocultar' : 'Editar',
                      rightIcon: isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                      isActive: true,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child: Padding(
              padding: LivitContainerStyle.padding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LivitTextField(
                    controller: nameController,
                    hint: 'Nombre',
                    bottomCaptionWidget: _buildNameCharCount(),
                    externalIsValid: _isNameValid(),
                  ),
                  LivitSpaces.xs,
                  LivitText('Define un precio por tiquete y la cantidad maxima disponible de este',
                      textType: LivitTextType.small, color: LivitColors.whiteInactive),
                  LivitSpaces.xs,
                  Row(
                    children: [
                      Expanded(
                        child: LivitTextField(
                          prefixIcon: CupertinoIcons.money_dollar_circle,
                          controller: priceController,
                          hint: 'Precio (COP)',
                          disableCheckValidity: true,
                          removeSuffixIcon: true,
                          inputType: TextInputType.number,
                        ),
                      ),
                      LivitSpaces.s,
                      Expanded(
                        child: LivitTextField(
                          controller: quantityController,
                          hint: 'Cantidad',
                          prefixIcon: CupertinoIcons.tickets,
                          disableCheckValidity: true,
                          removeSuffixIcon: true,
                          inputType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  LivitSpaces.s,
                  LivitTextField(
                    controller: descriptionController,
                    hint: 'Describe los detalles y beneficios del tiquete',
                    isMultiline: true,
                    bottomCaptionWidget: _buildDescriptionCharCount(),
                    externalIsValid: _isDescriptionValid(),
                  ),
                  LivitSpaces.s,
                  _buildDateSelector(),
                  LivitSpaces.m,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Button.redText(
                        text: 'Eliminar tiquete',
                        rightIcon: CupertinoIcons.delete,
                        onTap: () => widget.onDelete(widget.ticketType),
                        isActive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
