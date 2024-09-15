import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';

class LivitTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hint;
  final bool? blurInput;
  final TextInputType? inputType;
  final RegExp? regExp;
  final Icon? icon;
  final ValueChanged<bool>? onChanged;
  final bool phoneNumberField;
  final ValueChanged<String>? onCountryCodeChanged;
  final Country? initialCountry;
  final String? bottomCaptionText;
  final TextStyle? bottomCaptionStyle;
  final bool? externalIsValid;

  const LivitTextField({
    super.key,
    required this.controller,
    this.hint,
    this.blurInput,
    this.inputType,
    this.regExp,
    this.icon,
    this.onChanged,
    this.phoneNumberField = false,
    this.onCountryCodeChanged,
    this.initialCountry,
    this.bottomCaptionStyle,
    this.bottomCaptionText,
    this.externalIsValid,
  });

  @override
  State<LivitTextField> createState() => _LivitTextFieldState();
}

class _LivitTextFieldState extends State<LivitTextField> {
  bool isFocused = false;
  bool isValid = false;
  late Country selectedCountry;

  @override
  void initState() {
    super.initState();
    selectedCountry = widget.initialCountry ??
        Country(
          phoneCode: '57',
          countryCode: 'CO',
          e164Sc: 0,
          geographic: true,
          level: 1,
          name: 'COLOMBIA',
          example: 'COLOMBIA',
          displayName: 'COLOMBIA',
          displayNameNoCountryCode: 'CO',
          e164Key: '',
          capital: 'Bogota',
          language: 'Spanish',
        );
  }

  @override
  Widget build(BuildContext context) {
    final RegExp regExp = widget.phoneNumberField ? RegExp(r'^\d{4,15}$') : (widget.regExp ?? RegExp(r'.+'));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        FocusScope(
          child: Focus(
            onFocusChange: (value) {
              setState(() => isFocused = value);
            },
            child: Container(
              decoration: isFocused ? LivitBarStyle.strongShadowDecoration : LivitBarStyle.shadowDecoration,
              height: LivitBarStyle.height,
              child: TextFormField(
                textAlignVertical: TextAlignVertical.center,
                controller: widget.controller,
                keyboardType: widget.inputType ?? (widget.phoneNumberField ? TextInputType.number : null),
                onChanged: (value) {
                  setState(() {
                    isValid = regExp.hasMatch(widget.controller.text);
                  });
                  widget.onChanged?.call(isValid);
                },
                decoration: InputDecoration(
                  //isDense: true,
                  //contentPadding: EdgeInsets.zero,
                  hintText: widget.hint,
                  hintStyle: LivitTextStyle.regularWhiteInactiveText,
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                  suffixIcon: _buildSuffixIcon(),
                  prefixIcon: widget.phoneNumberField ? _buildCountryCodePicker() : null,
                  // suffixIconConstraints: const BoxConstraints(maxHeight: 20),
                  // prefixIconConstraints: const BoxConstraints(maxHeight: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  isCollapsed: true,
                ),
                style: LivitTextStyle.regularWhiteActiveText,
                obscureText: widget.blurInput ?? false,
                enableSuggestions: !(widget.blurInput ?? true),
                autocorrect: !(widget.blurInput ?? true),
              ),
            ),
          ),
        ),
        if (widget.bottomCaptionText != null) ...[
          LivitSpaces.s,
          Text(
            widget.bottomCaptionText!,
            style: widget.bottomCaptionStyle ?? LivitTextStyle.regularWhiteActiveBoldText,
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((widget.externalIsValid == null && isValid) || (widget.externalIsValid ?? false))
            widget.icon ??
                const Icon(
                  Icons.done,
                  color: Color.fromARGB(255, 255, 255, 255),
                  size: 16,
                ),
          if (isFocused) ...[
            LivitSpaces.s,
            GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: const Icon(
                CupertinoIcons.clear_circled_solid,
                color: LivitColors.gray,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountryCodePicker() {
    return IntrinsicWidth(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Center(
          child: GestureDetector(
            onTap: () {
              showCountryListView(
                appBarFontSize: 20,
                countryTitleSize: 13,
                countryFontStyle: FontStyle.normal,
                appBarFontStyle: FontStyle.normal,
                searchBarOuterBackgroundColor: LivitColors.mainBlack,
                searchBarBackgroundColor: LivitColors.mainBlack,
                appBarBackgroundColour: LivitColors.mainBlack,
                backgroundColour: LivitColors.mainBlack,
                countryTextColour: LivitColors.whiteActive,
                searchBarBorderColor: LivitColors.gray,
                searchBarHintColor: LivitColors.gray,
                searchBarTextColor: LivitColors.whiteActive,
                context: context,
                onSelect: (value) {
                  setState(() {
                    selectedCountry = value;
                    widget.onCountryCodeChanged?.call(selectedCountry.phoneCode);
                  });
                },
              );
            },
            child: Text(
              '+${selectedCountry.phoneCode}',
              style: LivitTextStyle.regularWhiteActiveText,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
