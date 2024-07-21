import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/text_style.dart';

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final RegExp? regExp;
    if (widget.phoneNumberField) {
      regExp = RegExp(r'^\d{4,15}$');
    } else {
      regExp = widget.regExp;
    }
    return FocusScope(
      child: Focus(
        onFocusChange: (value) {
          setState(
            () {
              isFocused = value;
            },
          );
        },
        child: Container(
          decoration: isFocused
              ? LivitBarStyle.strongShadowDecoration
              : LivitBarStyle.shadowDecoration,
          height: LivitBarStyle.height,
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.inputType,
            onChanged: (value) {
              setState(
                () {
                  if (regExp != null) {
                    if (!regExp.hasMatch(widget.controller.text)) {
                      isValid = false;
                    } else {
                      isValid = true;
                    }
                  } else {
                    isValid = true;
                  }
                },
              );
              if (widget.onChanged != null) {
                widget.onChanged!(isValid);
              }
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: LivitTextStyle(
                textColor: LivitColors.gray,
              ).smallTextStyle,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              suffixIcon: isValid & (regExp != null)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: widget.icon ??
                          const Icon(
                            Icons.done,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 18,
                          ),
                    )
                  : null,
              prefixIcon: widget.phoneNumberField
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: GestureDetector(
                        onTap: () {
                          showCountryListView(
                            appBarFontSize: 20,
                            countryTitleSize: 13,
                            countryFontStyle: FontStyle.normal,
                            appBarFontStyle: FontStyle.normal,
                            searchBarOuterBackgroundColor:
                                LivitColors.mainBlack,
                            searchBarBackgroundColor: LivitColors.mainBlack,
                            appBarBackgroundColour: LivitColors.mainBlack,
                            backgroundColour: LivitColors.mainBlack,
                            countryTextColour: LivitColors.whiteActive,
                            searchBarBorderColor: LivitColors.gray,
                            searchBarHintColor: LivitColors.gray,
                            searchBarTextColor: LivitColors.whiteActive,
                            context: context,
                            onSelect: (value) {
                              setState(
                                () {
                                  selectedCountry = value;
                                  if (widget.onCountryCodeChanged != null) {
                                    widget.onCountryCodeChanged!(
                                        selectedCountry.phoneCode);
                                  }
                                },
                              );
                            },
                          );
                        },
                        // ignore: sized_box_for_whitespace
                        child: Container(
                          height: LivitBarStyle.height,
                          child: Text(
                            '${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}',
                            style: LivitTextStyle(
                              textColor: LivitColors.whiteActive,
                            ).regularTextStyle,
                          ),
                        ),
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(maxHeight: 20),
              prefixIconConstraints: const BoxConstraints(maxHeight: 20),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 16,
              ),
              isCollapsed: true,
            ),
            style: LivitTextStyle(
              textColor: LivitColors.whiteActive,
            ).regularTextStyle,
            obscureText: widget.blurInput ?? false,
            enableSuggestions: !(widget.blurInput ?? true),
            autocorrect: !(widget.blurInput ?? true),
          ),
        ),
      ),
    );
  }
}
