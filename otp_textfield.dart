import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpTextField extends StatefulWidget {
  /// Callback function, called when pin is completed.
  final ValueChanged<String>? onCompleted;
  const OtpTextField({Key? key, this.onCompleted}) : super(key: key);

  @override
  _OtpTextFieldState createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  final List<FocusNode?> _focusNodes =
      List<FocusNode?>.filled(6, null, growable: false);
  final List<TextEditingController?> _textControllers =
      List<TextEditingController?>.filled(6, null, growable: false);
  final List<String> _pin = List.generate(6, (int i) {
    return '';
  });

  @override
  void dispose() {
    _textControllers
        .forEach((TextEditingController? controller) => controller!.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(6, (i) {
        if (_focusNodes[i] == null) _focusNodes[i] = FocusNode();

        if (_textControllers[i] == null) {
          _textControllers[i] = TextEditingController();
        }
        return SizedBox(
          width: MediaQuery.of(context).size.width / 8,
          height: MediaQuery.of(context).size.width / 8,
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (value) {
              if (value.character != null) {
                if (value.logicalKey == LogicalKeyboardKey.backspace) {
                  if (i == 0) return;
                  _focusNodes[i]!.unfocus();
                  _focusNodes[i - 1]!.requestFocus();
                }
              }
            },
            child: TextField(
              controller: _textControllers[i],
              keyboardType: TextInputType.number,
              focusNode: _focusNodes[i],
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xff262A34),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (String str) {
                if (str.length > 1) {
                  _handlePaste(str);
                  return;
                }

                setState(() {
                  _pin[i] = str;
                });
                // Set focus to the next field if available
                if (i + 1 != 6 && str.isNotEmpty) {
                  FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
                }
                String currentPin = _getCurrentPin();

                // if there are no null values that means otp is completed
                // Call the `onCompleted` callback function provided
                if (!_pin.contains(null) &&
                    !_pin.contains('') &&
                    currentPin.length == 6) {
                  widget.onCompleted!(currentPin);
                }
                if (i + 1 == 6 && str.isNotEmpty) {
                  _focusNodes[i]!.unfocus();
                }
                // Call the `onChanged` callback function
              },
            ),
          ),
        );
      }),
    );
  }

  String _getCurrentPin() {
    String currentPin = "";
    _pin.forEach((String value) {
      currentPin += value;
    });
    return currentPin;
  }

  void _handlePaste(String str) {
    if (str.length > 6) {
      str = str.substring(0, 6);
    }

    for (int i = 0; i < str.length; i++) {
      String digit = str.substring(i, i + 1);
      _textControllers[i]!.text = digit;
      _pin[i] = digit;
    }

    FocusScope.of(context).requestFocus(_focusNodes[6 - 1]);
    String currentPin = _getCurrentPin();

    // if there are no null values that means otp is completed
    // Call the `onCompleted` callback function provided
    if (!_pin.contains(null) && !_pin.contains('') && currentPin.length == 6) {
      FocusScope.of(context).unfocus();
      widget.onCompleted!(currentPin);
    }
  }
}
