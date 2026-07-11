import 'package:flutter/services.dart';

import 'input.dart';

/// A multiline [MonoInput] with textarea-friendly defaults.
///
/// It keeps the same `EditableText` implementation, focus ring, semantics,
/// validation state, and controller behavior as [MonoInput].
class MonoTextarea extends MonoInput {
  const MonoTextarea({
    super.key,
    super.controller,
    super.focusNode,
    super.initialValue,
    super.placeholder,
    super.semanticLabel,
    super.enabled,
    super.readOnly,
    super.invalid,
    super.autofocus,
    super.textCapitalization,
    super.inputFormatters,
    super.autofillHints,
    super.maxLength,
    super.minLines = 3,
    super.maxLines = 5,
    super.enableSuggestions,
    super.autocorrect,
    super.enableInteractiveSelection,
    super.textAlign,
    super.style,
    super.placeholderStyle,
    super.cursorColor,
    super.selectionColor,
    super.padding,
    super.prefix,
    super.suffix,
    super.mouseCursor,
    super.scrollController,
    super.scrollPhysics,
    super.onChanged,
    super.onSubmitted,
    super.onEditingComplete,
    super.onTap,
    super.onFocusChanged,
    super.statesController,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) : assert(minLines != null && minLines > 0),
       assert(maxLines == null || (minLines != null && maxLines >= minLines)),
       super(
         keyboardType: keyboardType ?? TextInputType.multiline,
         textInputAction: textInputAction ?? TextInputAction.newline,
       );
}
