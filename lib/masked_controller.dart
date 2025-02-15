library masked_controller;

import 'package:flutter/material.dart';
import 'package:masked_controller/mask.dart';
import 'dart:io' show Platform;

class MaskedController extends TextEditingController {
  MaskedController({required Mask mask}) : _mask = mask {
    addListener(_listener);
  }

  Mask _mask;
  String? _previewsText = '';

  String get unmaskedText => _mask.removeMaskFrom(string: _previewsText) ?? '';

  Mask get mask => _mask;

  set mask(Mask mask) {
    _mask = mask;
    update(text: text);
  }

  @override
  set text(String? newText) {
    if (super.text != newText) {
      int cursorPosition;

      if (selection.baseOffset >= super.text.length) {
        cursorPosition = newText?.length ?? 0;
      } else {
        cursorPosition = selection.baseOffset;
      }

      final TextSelection textSelection = TextSelection.collapsed(offset: cursorPosition);

      value = value.copyWith(text: newText, selection: textSelection, composing: TextRange.empty);
    }
  }

  void _listener() {
    final currentText = text;
    final maskedText = mask.applyMaskTo(string: mask.removeMaskFrom(string: currentText));

    if (maskedText == null) {
      if (Platform.isAndroid) {
        update(text: mask.removeMaskFrom(string: _previewsText));
        _moveCursorToEnd();
      } else {
        _moveCursorToEnd();
        update(text: mask.removeMaskFrom(string: _previewsText));
      }

      return;
    }

    update(text: maskedText);
  }

  void _moveCursorToEnd() {
    final String text = this.text;
    _moveCursorTo(position: text.length);
  }

  void _moveCursorTo({required int position}) {
    final TextSelection textSelection = TextSelection.collapsed(offset: position);
    value = value.copyWith(text: text, selection: textSelection);
  }

  void update({required String? text}) {
    if (text != null) {
      this.text = mask.applyMaskTo(string: mask.removeMaskFrom(string: text));
    } else {
      this.text = _previewsText;
    }

    _previewsText = text;
  }

  @override
  void dispose() {
    removeListener(_listener);
    super.dispose();
  }
}
