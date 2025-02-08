import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/buttons/livit_dropdown_button.dart';

class LivitDatePicker extends StatefulWidget {
  final Function(List<DateTime>?) onSelected;
  final DateTime? defaultDate;
  final bool isActive;
  final List<DateTime>? selectedDateRange;

  const LivitDatePicker({
    super.key,
    required this.onSelected,
    required this.defaultDate,
    required this.isActive,
    this.selectedDateRange,
  });

  @override
  State<LivitDatePicker> createState() => _LivitDatePickerState();
}

class _LivitDatePickerState extends State<LivitDatePicker> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;

  int _selectedIndex = 0;

  String _selectedDropdown = 'semana';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showSelectionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LivitBar(
                    shadowType: ShadowType.normal,
                    child: LivitText(
                      'Selecciona una fecha para ver los tickets vendidos',
                      textType: LivitTextType.smallTitle,
                    ),
                  ),
                  LivitSpaces.m,
                  Container(
                    decoration: LivitContainerStyle.decoration,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollUpdateNotification) {}
                              return true;
                            },
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LivitBar.touchable(
                                    isTransparent: _selectedIndex != 0,
                                    noPadding: true,
                                    shadowType: _selectedIndex == 0 ? ShadowType.normal : ShadowType.none,
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = 0;
                                      });
                                      widget.onSelected([
                                        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
                                      ]);
                                      Navigator.of(context).pop();
                                    },
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          LivitText(
                                            'Hoy',
                                            textType: LivitTextType.regular,
                                            fontWeight: _selectedIndex == 0 ? FontWeight.bold : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  LivitSpaces.xs,
                                  LivitBar.touchable(
                                    isTransparent: _selectedIndex != 1,
                                    noPadding: true,
                                    shadowType: _selectedIndex == 1 ? ShadowType.normal : ShadowType.none,
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = 1;
                                      });
                                      widget.onSelected([
                                        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1),
                                        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2),
                                      ]);
                                      Navigator.of(context).pop();
                                    },
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          LivitText(
                                            'Mañana',
                                            textType: LivitTextType.regular,
                                            fontWeight: _selectedIndex == 1 ? FontWeight.bold : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  LivitSpaces.xs,
                                  LivitBar.touchable(
                                    isTransparent: _selectedIndex != 2,
                                    noPadding: true,
                                    shadowType: _selectedIndex == 2 ? ShadowType.normal : ShadowType.none,
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = 2;
                                      });
                                      if (_selectedDropdown == 'semana') {
                                        final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
                                        final weekEnd = weekStart.add(const Duration(days: 6));
                                        widget.onSelected([weekStart, weekEnd]);
                                      } else if (_selectedDropdown == 'mes') {
                                        final monthStart = DateTime(DateTime.now().year, DateTime.now().month, 1);
                                        final monthEnd = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
                                        widget.onSelected([monthStart, monthEnd]);
                                      } else if (_selectedDropdown == 'año') {
                                        final yearStart = DateTime(DateTime.now().year, 1, 1);
                                        final yearEnd = DateTime(DateTime.now().year + 1, 1, 0);
                                        widget.onSelected([yearStart, yearEnd]);
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          LivitText(
                                            'Este/a',
                                            textType: LivitTextType.regular,
                                            fontWeight: _selectedIndex == 2 ? FontWeight.bold : null,
                                          ),
                                          LivitSpaces.s,
                                          LivitDropdownButton(
                                            activeBoxShadow: LivitShadows.inactiveWhiteShadow,
                                            inactiveBoxShadow: LivitShadows.inactiveWhiteShadow,
                                            entries: [
                                              DropdownMenuEntry(value: 'semana', label: 'Semana'),
                                              DropdownMenuEntry(value: 'mes', label: 'Mes'),
                                              DropdownMenuEntry(value: 'año', label: 'Año'),
                                            ],
                                            onSelected: (value) {
                                              debugPrint('🎨 [LivitDatePicker] Selected dropdown: $value');
                                              dialogSetState(() {
                                                _selectedDropdown = value!;
                                              });
                                            },
                                            defaultText: 'semana',
                                            isActive: true,
                                            isSearchable: false,
                                            selectedValue: _selectedDropdown,
                                          ),
                                          LivitSpaces.xs,
                                        ],
                                      ),
                                    ),
                                  ),
                                  LivitSpaces.xs,
                                  LivitBar.touchable(
                                    isTransparent: _selectedIndex != 3,
                                    noPadding: true,
                                    shadowType: _selectedIndex == 3 ? ShadowType.normal : ShadowType.none,
                                    onTap: () async {
                                      final DateTimeRange? range = await showDateRangePicker(
                                        context: context,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.dark(
                                                primary: LivitColors.mainBlueActive,
                                                onPrimary: LivitColors.whiteActive,
                                                surface: LivitColors.mainBlack,
                                                onSurface: LivitColors.whiteActive,
                                              ),
                                              dialogBackgroundColor: LivitColors.mainBlack,
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (range != null) {
                                        if (range.start == range.end) {
                                          widget.onSelected([range.start]);
                                        } else {
                                          widget.onSelected([range.start, range.end]);
                                        }
                                        setState(() {
                                          _selectedIndex = 3;
                                        });
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            LivitText(
                                              'Rango personalizado',
                                              textType: LivitTextType.regular,
                                              fontWeight: _selectedIndex == 3 ? FontWeight.bold : null,
                                            ),
                                            LivitSpaces.s,
                                            Icon(
                                              CupertinoIcons.calendar,
                                              size: LivitButtonStyle.iconSize,
                                              color: LivitColors.whiteActive,
                                            ),
                                          ],
                                        ),
                                        if ((widget.selectedDateRange ?? []).length > 1) ...[
                                          LivitSpaces.xs,
                                          LivitText(
                                            '${widget.selectedDateRange?.first.day}/${widget.selectedDateRange?.first.month}/${widget.selectedDateRange?.first.year} - ${widget.selectedDateRange?.last.day}/${widget.selectedDateRange?.last.month}/${widget.selectedDateRange?.last.year}',
                                            textType: LivitTextType.regular,
                                            fontWeight: _selectedIndex == 3 ? FontWeight.bold : null,
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        LivitSpaces.m,
                        Button.main(
                          text: 'Cancelar',
                          onTap: () => Navigator.of(context).pop(),
                          isActive: true,
                        ),
                        LivitSpaces.m,
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> selectedDate = widget.selectedDateRange ?? [widget.defaultDate ?? DateTime.now()];
    final DateTime startDate = selectedDate.first;
    final DateTime endDate = selectedDate.last;
    String startDateString = startDate.toString();
    String endDateString = endDate.toString();
    if (startDate.year == DateTime.now().year && startDate.month == DateTime.now().month && startDate.day == DateTime.now().day) {
      startDateString = 'Hoy';
    } else {
      startDateString = '${startDate.day}/${startDate.month}/${startDate.year}';
    }
    if (endDate.year == DateTime.now().year && endDate.month == DateTime.now().month && endDate.day == DateTime.now().day) {
      endDateString = 'Hoy';
    } else {
      endDateString = '${endDate.day}/${endDate.month}/${endDate.year}';
    }
    late final String dateString;
    if (startDate.year == endDate.year && startDate.month == endDate.month && startDate.day == endDate.day || _selectedIndex == 0) {
      dateString = startDateString;
    } else if (_selectedIndex == 1) {
      dateString = 'Mañana';
    } else {
      dateString = '$startDateString - $endDateString';
    }
    return Button.secondary(
      rightIcon: CupertinoIcons.chevron_down,
      text: dateString,
      isActive: widget.isActive,
      onTap: () => _showSelectionDialog(context),
      boxShadow: [LivitShadows.inactiveWhiteShadow],
    );
  }
}
