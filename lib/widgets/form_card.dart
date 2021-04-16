import 'package:acs_upb_mobile/resources/custom_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recase/recase.dart';

class FormCardField {
  FormCardField({
    this.label,
    this.additionalHint,
    this.hint,
    TextEditingController controller,
    FocusNode focusNode,
    void Function(String) onSubmitted,
    void Function(String) onChanged,
    this.check,
    this.obscureText = false,
    this.suffix,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.keyboardType = TextInputType.text,
    this.autofillHints,
  })  : onSubmitted = onSubmitted ?? ((_) {}),
        onChanged = onChanged ?? ((_) {}),
        controller = controller ?? TextEditingController(),
        focusNode = focusNode ?? FocusNode();

  final String label;
  final String additionalHint;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onSubmitted;
  final void Function(String) onChanged;
  final Future<bool> Function(String, {BuildContext context}) check;
  final bool obscureText;
  final String suffix;
  final bool autocorrect;
  final bool enableSuggestions;
  final TextInputType keyboardType;
  final List<String> autofillHints;
}

class FormCard extends StatefulWidget {
  FormCard(
      {this.title,
      this.fields,
      this.onSubmitted,
      List<Widget> trailing,
      this.submitOnEnter = true})
      : trailing = trailing ?? <Widget>[];

  final String title;
  final List<FormCardField> fields;
  final bool submitOnEnter;

  /// Map from [FormCardField.label] to corresponding input
  final dynamic Function(Map<String, dynamic>) onSubmitted;

  /// Widgets to be added at the end of the form
  final List<Widget> trailing;

  @override
  _FormCardState createState() => _FormCardState();

  dynamic submit() {
    return onSubmitted(
        {for (var field in fields) field.label: field.controller.text});
  }
}

class _FormCardState extends State<FormCard> {
  @override
  Widget build(BuildContext context) {
    final children = widget.fields
        .asMap()
        .map((index, field) => MapEntry(
            index,
            _FormCardTextField(
              field: field,
              onSubmitted: (input) {
                if (index < widget.fields.length - 1) {
                  FocusScope.of(context)
                      .requestFocus(widget.fields[index + 1].focusNode);
                  field.onSubmitted(input);
                } else {
                  if (widget.submitOnEnter) {
                    widget.submit();
                  } else {
                    // Just remove focus
                    final currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  }
                }
              },
            )))
        .values
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          const BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 15),
            blurRadius: 15,
          ),
          const BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(widget.title,
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .copyWith(fontWeight: FontWeight.w600)),
                  )
                ] +
                children +
                widget.trailing,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final field in widget.fields) {
      field.controller.dispose();
      field.focusNode.dispose();
    }
    super.dispose();
  }
}

class _FormCardTextField extends StatefulWidget {
  const _FormCardTextField({Key key, this.field, this.onSubmitted})
      : super(key: key);

  final FormCardField field;
  final void Function(String) onSubmitted;

  @override
  _FormCardTextFieldState createState() => _FormCardTextFieldState();
}

class _FormCardTextFieldState extends State<_FormCardTextField> {
  Future<bool> valid;
  bool showCursor = false;

  @override
  void initState() {
    super.initState();
    valid = Future.value(null);
    // Only show cursor when field is in focus; that way, we can change the text
    // in a controller without having the TextField scroll into view.
    // See issue here: https://github.com/flutter/flutter/issues/50713
    widget.field.focusNode.addListener(() {
      if (showCursor != widget.field.focusNode.hasFocus) {
        setState(() => showCursor = widget.field.focusNode.hasFocus);
      }
    });
  }

  Widget buildSuffixIcon() => widget.field.check == null
      ? null
      : IntrinsicWidth(
          child: FutureBuilder(
            future: valid,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data == null) {
                // No icon
                return Container();
              } else {
                return GestureDetector(
                  onTap: () {
                    widget.field
                        .check(widget.field.controller.text, context: context);
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: snapshot.data
                          ? CustomIcons.valid
                          : CustomIcons.invalid),
                );
              }
            },
          ),
        );

  @override
  Widget build(BuildContext context) {
    final Widget suffixIcon = buildSuffixIcon();

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(widget.field.label,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .apply(fontSizeFactor: 1.1)),
          ),
          if (widget.field.additionalHint != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.field.additionalHint,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    key: ValueKey('${widget.field.label.snakeCase}_text_field'),
                    keyboardType: widget.field.keyboardType,
                    autocorrect: widget.field.autocorrect,
                    enableSuggestions: widget.field.enableSuggestions,
                    obscureText: widget.field.obscureText,
                    controller: widget.field.controller,
                    focusNode: widget.field.focusNode,
                    showCursor: showCursor,
                    onChanged: (text) => setState(() {
                      if (widget.field.onChanged != null) {
                        widget.field.onChanged(text);
                      }
                      if (text == null || text == '') {
                        valid = Future<bool>(() => null);
                      } else {
                        if (widget.field.check != null) {
                          valid = widget.field.check(text);
                        }
                      }
                    }),
                    onSubmitted: widget.onSubmitted,
                    autofillHints: widget.field.autofillHints,
                    // Only show verification icon within text widget.field if it exists
                    // and there no suffix text set
                    decoration:
                        widget.field.suffix == null && suffixIcon != null
                            ? InputDecoration(
                                hintText: widget.field.hint ??
                                    widget.field.label.toLowerCase(),
                                suffixIcon: suffixIcon,
                              )
                            : InputDecoration(
                                hintText: widget.field.hint ??
                                    widget.field.label.toLowerCase(),
                              ),
                  ),
                ),
                if (widget.field.suffix != null)
                  Row(
                    children: <Widget>[
                      const SizedBox(width: 4),
                      Text(widget.field.suffix,
                          style: Theme.of(context)
                              .inputDecorationTheme
                              .suffixStyle),
                      suffixIcon,
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
