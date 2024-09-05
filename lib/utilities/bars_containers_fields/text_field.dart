import 'package:country_picker_pro/country_picker_pro.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/spaces.dart';
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final RegExp regExp;
    if (widget.phoneNumberField) {
      regExp = RegExp(r'^\d{4,15}$');
    } else {
      regExp = widget.regExp ?? RegExp(r'.+');
    }
    if (widget.bottomCaptionText == null) {
      return NoBottomCaption(
        controller: widget.controller,
        hint: widget.hint,
        blurInput: widget.blurInput,
        inputType: widget.inputType,
        regExp: regExp,
        icon: widget.icon,
        onChanged: widget.onChanged,
        phoneNumberField: widget.phoneNumberField,
        onCountryCodeChanged: widget.onCountryCodeChanged,
        initialCountry: selectedCountry,
        externalIsValid: widget.externalIsValid,
      );
    } else {
      return WithBottomCaption(
        controller: widget.controller,
        hint: widget.hint,
        blurInput: widget.blurInput,
        inputType: widget.inputType,
        regExp: regExp,
        icon: widget.icon,
        onChanged: widget.onChanged,
        phoneNumberField: widget.phoneNumberField,
        onCountryCodeChanged: widget.onCountryCodeChanged,
        initialCountry: selectedCountry,
        bottomCaptionStyle: widget.bottomCaptionStyle ?? LivitTextStyle.smallWhiteActiveBoldText,
        bottomCaptionText: widget.bottomCaptionText ?? '',
        externalIsValid: widget.externalIsValid,
      );
    }
  }
}

class NoBottomCaption extends StatefulWidget {
  final TextEditingController controller;
  final String? hint;
  final bool? blurInput;
  final TextInputType? inputType;
  final RegExp regExp;
  final Icon? icon;
  final ValueChanged<bool>? onChanged;
  final bool phoneNumberField;
  final ValueChanged<String>? onCountryCodeChanged;
  final Country initialCountry;
  final bool? externalIsValid;

  const NoBottomCaption({
    super.key,
    required this.controller,
    this.hint,
    this.blurInput,
    this.inputType,
    required this.regExp,
    this.icon,
    this.onChanged,
    this.phoneNumberField = false,
    this.onCountryCodeChanged,
    required this.initialCountry,
    this.externalIsValid,
  });

  @override
  State<NoBottomCaption> createState() => _NoBottomCaptionState();
}

class _NoBottomCaptionState extends State<NoBottomCaption> {
  bool isFocused = false;
  bool isValid = false;

  late Country selectedCountry;

  @override
  void initState() {
    super.initState();

    selectedCountry = widget.initialCountry;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          decoration: isFocused ? LivitBarStyle.strongShadowDecoration : LivitBarStyle.shadowDecoration,
          height: LivitBarStyle.height,
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.inputType ?? (widget.phoneNumberField ? TextInputType.number : null),
            onChanged: (value) {
              setState(
                () {
                  if (widget.regExp.hasMatch(widget.controller.text)) {
                    isValid = true;
                  } else {
                    isValid = false;
                  }
                },
              );
              if (widget.onChanged != null) {
                widget.onChanged!(isValid);
              }
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: LivitTextStyle.regularWhiteInactiveText,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              suffixIcon: (widget.externalIsValid == null && isValid) || (widget.externalIsValid ?? false)
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
                              setState(
                                () {
                                  selectedCountry = value;
                                  if (widget.onCountryCodeChanged != null) {
                                    widget.onCountryCodeChanged!(selectedCountry.phoneCode);
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
                            style: LivitTextStyle.regularWhiteActiveText,
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
            style: LivitTextStyle.regularWhiteActiveText,
            obscureText: widget.blurInput ?? false,
            enableSuggestions: !(widget.blurInput ?? true),
            autocorrect: !(widget.blurInput ?? true),
          ),
        ),
      ),
    );
  }
}

class WithBottomCaption extends StatefulWidget {
  final TextEditingController controller;
  final String? hint;
  final bool? blurInput;
  final TextInputType? inputType;
  final RegExp regExp;
  final Icon? icon;
  final ValueChanged<bool>? onChanged;
  final bool phoneNumberField;
  final ValueChanged<String>? onCountryCodeChanged;
  final Country initialCountry;
  final String bottomCaptionText;
  final TextStyle bottomCaptionStyle;
  final bool? externalIsValid;

  const WithBottomCaption({
    super.key,
    required this.controller,
    this.hint,
    this.blurInput,
    this.inputType,
    required this.regExp,
    this.icon,
    this.onChanged,
    this.phoneNumberField = false,
    this.onCountryCodeChanged,
    required this.initialCountry,
    required this.bottomCaptionStyle,
    required this.bottomCaptionText,
    this.externalIsValid,
  });

  @override
  State<WithBottomCaption> createState() => _WithBottomCaptionState();
}

class _WithBottomCaptionState extends State<WithBottomCaption> {
  bool isFocused = false;
  bool isValid = false;

  late Country selectedCountry;

  @override
  void initState() {
    super.initState();

    selectedCountry = widget.initialCountry;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        FocusScope(
          child: Focus(
            onFocusChange: (value) {
              setState(
                () {
                  isFocused = value;
                },
              );
            },
            child: Container(
              decoration: isFocused ? LivitBarStyle.strongShadowDecoration : LivitBarStyle.shadowDecoration,
              height: LivitBarStyle.height,
              child: TextFormField(
                controller: widget.controller,
                keyboardType: widget.inputType ?? (widget.phoneNumberField ? TextInputType.number : null),
                onChanged: (value) {
                  setState(
                    () {
                      if (widget.regExp.hasMatch(widget.controller.text)) {
                        isValid = true;
                      } else {
                        isValid = false;
                      }
                    },
                  );
                  if (widget.onChanged != null) {
                    widget.onChanged!(isValid);
                  }
                },
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: LivitTextStyle.regularWhiteInactiveText,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: isValid
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
                                  setState(
                                    () {
                                      selectedCountry = value;
                                      if (widget.onCountryCodeChanged != null) {
                                        widget.onCountryCodeChanged!(selectedCountry.phoneCode);
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
                                style: LivitTextStyle.regularWhiteActiveText,
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
                style: LivitTextStyle.regularWhiteActiveText,
                obscureText: widget.blurInput ?? false,
                enableSuggestions: !(widget.blurInput ?? true),
                autocorrect: !(widget.blurInput ?? true),
              ),
            ),
          ),
        ),
        LivitSpaces.s,
        Text(
          widget.bottomCaptionText,
          style: widget.bottomCaptionStyle,
        ),
      ],
    );
  }
}
