import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
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
  double? _lastScrollOffset;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showSelectionDialog(BuildContext context) async {
    // Restore last scroll position if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastScrollOffset != null && _scrollController.hasClients) {
        _scrollController.jumpTo(_lastScrollOffset!);
      }
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: LivitColors.mainBlack,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: LivitContainerStyle.verticalPadding,
                  ),
                  decoration: LivitContainerStyle.decorationWithActiveShadow,
                  child: LivitText(
                    widget.defaultText,
                    textType: TextType.smallTitle,
                  ),
                ),
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
                        children: widget.entries.map((entry) {
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
                                textType: TextType.regular,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                LivitSpaces.s,
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Button.main(
                    text: 'Cancelar',
                    onPressed: () => Navigator.of(context).pop(),
                    isActive: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Button.secondary(
        rightIcon: CupertinoIcons.chevron_down,
        text: widget.selectedValue ?? widget.defaultText,
        isActive: widget.isActive,
        onPressed: () => _showSelectionDialog(context),
      ),
    );
  }
}
