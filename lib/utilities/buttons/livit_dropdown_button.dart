import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/shadows.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/buttons/button.dart';

class LivitDropdownButton extends StatefulWidget {
  final List<DropdownMenuEntry<String>> entries;
  final Function(String?) onSelected;
  final String defaultText;
  final bool isActive;
  final String? selectedValue;

  const LivitDropdownButton({
    super.key,
    required this.entries,
    required this.onSelected,
    required this.defaultText,
    required this.isActive,
    this.selectedValue,
  });

  @override
  State<LivitDropdownButton> createState() => _LivitDropdownButtonState();
}

class _LivitDropdownButtonState extends State<LivitDropdownButton> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  double? _lastScrollOffset;
  List<DropdownMenuEntry<String>> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _filteredEntries = widget.entries;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterEntries(String query, StateSetter dialogSetState) {
    dialogSetState(() {
      if (query.isEmpty) {
        _filteredEntries = widget.entries;
      } else {
        final normalizedQuery = _normalizeString(query);
        _filteredEntries = widget.entries.where((entry) {
          final normalizedLabel = _normalizeString(entry.label);

          // Check if it starts with the query
          if (normalizedLabel.startsWith(normalizedQuery)) {
            return true;
          }

          // Check if any word in the label starts with the query
          final words = normalizedLabel.split(' ');
          return words.any((word) => word.startsWith(normalizedQuery));
        }).toList();

        // Sort results: exact matches first, then starts with, then contains
        _filteredEntries.sort((a, b) {
          final normalizedA = _normalizeString(a.label);
          final normalizedB = _normalizeString(b.label);

          // Exact matches come first
          if (normalizedA == normalizedQuery && normalizedB != normalizedQuery) {
            return -1;
          }
          if (normalizedB == normalizedQuery && normalizedA != normalizedQuery) {
            return 1;
          }

          // Then entries that start with the query
          if (normalizedA.startsWith(normalizedQuery) && !normalizedB.startsWith(normalizedQuery)) {
            return -1;
          }
          if (normalizedB.startsWith(normalizedQuery) && !normalizedA.startsWith(normalizedQuery)) {
            return 1;
          }

          // Finally, alphabetical order
          return normalizedA.compareTo(normalizedB);
        });
      }
    });
  }

  String _normalizeString(String input) {
    return input
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();
  }

  Future<void> _showSelectionDialog(BuildContext context) async {
    // Reset filtered entries and search controller
    _filteredEntries = widget.entries;
    _searchController.clear();

    // Restore last scroll position if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastScrollOffset != null && _scrollController.hasClients) {
        _scrollController.jumpTo(_lastScrollOffset!);
      }
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: LivitContainerStyle.decoration,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LivitTextField(
                      prefixIcon: CupertinoIcons.search,
                      controller: _searchController,
                      hint: widget.defaultText,
                      onChanged: (value) => _filterEntries(_searchController.text, dialogSetState),
                    ),
                    LivitSpaces.xs,
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification) {
                          _lastScrollOffset = _scrollController.offset;
                        }
                        return true;
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _filteredEntries.map((entry) {
                              final isSelected = entry.value == widget.selectedValue;
                              return InkWell(
                                onTap: () {
                                  widget.onSelected(entry.value);
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  color: isSelected ? LivitColors.whiteActive.withOpacity(0.1) : null,
                                  child: LivitText(
                                    entry.label,
                                    textType: LivitTextType.regular,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    LivitSpaces.s,
                    Button.main(
                      text: 'Cancelar',
                      onPressed: () => Navigator.of(context).pop(),
                      isActive: true,
                    ),
                    LivitSpaces.m,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: widget.selectedValue == null
          ? Button.secondary(
              rightIcon: CupertinoIcons.chevron_down,
              text: widget.defaultText,
              isActive: widget.isActive,
              onPressed: () => _showSelectionDialog(context),
            )
          : Button(
              rightIcon: CupertinoIcons.chevron_down,
              text: widget.selectedValue ?? widget.defaultText,
              isActive: widget.isActive,
              onPressed: () => _showSelectionDialog(context),
              boxShadow: [LivitShadows.inactiveWhiteShadow],
            ),
    );
  }
}
