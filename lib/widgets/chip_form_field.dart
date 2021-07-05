import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/resources/theme.dart';
import 'package:flutter/material.dart';

class FilterChipFormField extends ChipFormField<Map<Localizable, bool>> {
  FilterChipFormField({
    @required Map<Localizable, bool> initialValues,
    @required IconData icon,
    @required String label,
    Key key,
  }) : super(
          key: key,
          icon: icon,
          label: label,
          initialValues: initialValues,
          validator: (selection) {
            if (selection.values.where((e) => e != false).isEmpty) {
              return S.current.warningYouNeedToSelectAtLeastOne;
            }
            return null;
          },
          contentBuilder: (state) {
            final labels = state.value.keys.toList();
            return ListView.builder(
              itemCount: labels.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    FilterChip(
                      label: Text(
                        labels[index].toLocalizedString(),
                        style: Theme.of(context).chipTextStyle(
                            selected: state.value[labels[index]]),
                      ),
                      selected: state.value[labels[index]],
                      onSelected: (selected) {
                        state.value[labels[index]] = selected;
                        state.didChange(state.value);
                      },
                    ),
                    const SizedBox(width: 10),
                  ],
                );
              },
            );
          },
        );
}

class ChipFormField<T> extends FormField<T> {
  ChipFormField({
    @required IconData icon,
    @required String label,
    @required Widget Function(FormFieldState<T> state) contentBuilder,
    Widget Function(FormFieldState<T>) trailingBuilder,
    T initialValues,
    String Function(T) validator,
    Key key,
  }) : super(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: initialValues,
          key: key,
          validator: validator,
          builder: (state) {
            final context = state.context;
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(icon, color: Theme.of(context).formIconColor),
                          const SizedBox(width: 12),
                          Text(
                            label,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(fontWeight: FontWeight.w400),
                          ),
                          Expanded(child: Container()),
                          if (trailingBuilder != null) trailingBuilder(state),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 40,
                            child: contentBuilder(state),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Divider(
                        thickness: 0.7,
                        color: state.hasError
                            ? Theme.of(context).errorColor
                            : Theme.of(context).hintColor),
                    if (state.hasError)
                      Text(
                        state.errorText,
                        style: Theme.of(context).textTheme.caption.copyWith(
                            color: Theme.of(context).errorColor.withOpacity(1)),
                      ),
                  ],
                ),
              ),
            );
          },
        );
}
