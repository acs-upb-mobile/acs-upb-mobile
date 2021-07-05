import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/pages/filter/view/filter_page.dart';
import 'package:acs_upb_mobile/resources/theme.dart';
import 'package:acs_upb_mobile/widgets/chip_form_field.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';

class RelevanceFormField extends ChipFormField<List<String>> {
  RelevanceFormField({
    @required this.controller,
    this.canBePrivate = true,
    this.canBeForEveryone = true,
    this.defaultPrivate = false,
    Key key,
  }) : super(
          key: key,
          icon: FeatherIcons.filter,
          label: S.current.labelRelevance,
          validator: (_) {
            if (canBeForEveryone) {
              // When the relevance can be for everyone, it's selected automatically
              // if no custom relevance is selected; no error is possible.
              return null;
            }
            if (controller.customRelevance?.isEmpty ?? true) {
              return S.current.warningYouNeedToSelectAtLeastOne;
            }
            return null;
          },
          trailingBuilder: (FormFieldState<List<String>> state) {
            return _customRelevanceButton(
                state.context, controller, canBeForEveryone);
          },
          contentBuilder: (FormFieldState<List<String>> state) {
            controller.onChanged = () {
              state.didChange(controller.customRelevance);
            };
            return _RelevancePicker(
              defaultPrivate: defaultPrivate,
              canBePrivate: canBePrivate,
              canBeForEveryone: canBeForEveryone,
              controller: controller,
            );
          },
        );

  final RelevanceController controller;
  final bool canBePrivate;
  final bool canBeForEveryone;
  final bool defaultPrivate;

  static Widget _customRelevanceButton(BuildContext context,
      RelevanceController controller, bool canBeForEveryone) {
    final User user = Provider.of<AuthProvider>(context).currentUserFromCache;
    final buttonColor = user?.canAddPublicInfo ?? false
        ? Theme.of(context).accentColor
        : Theme.of(context).hintColor;

    return IntrinsicWidth(
      child: GestureDetector(
        onTap: () {
          if (user?.canAddPublicInfo ?? false) {
            Navigator.of(context)
                .push(MaterialPageRoute<ChangeNotifierProvider>(
              builder: (_) => ChangeNotifierProvider.value(
                value: Provider.of<FilterProvider>(context),
                child: FilterPage(
                  title: S.current.labelRelevance,
                  buttonText: S.current.buttonSet,
                  canBeForEveryone: canBeForEveryone,
                  info:
                      '${S.current.infoRelevanceNothingSelected} ${S.current.infoRelevance}',
                  hint: S.current.infoRelevanceExample,
                  onSubmit: () async {
                    // Deselect all other options
                    controller._state._onlyMeSelected = false;
                    controller._state._anyoneSelected = false;

                    // Select the new options
                    await controller._state._fetchFilter();
                    if (controller._state._filter.relevantLeaves
                        .contains('All')) {
                      controller._state._anyoneSelected = true;
                    } else {
                      for (final node
                          in controller._state._customSelected.keys) {
                        controller._state._customSelected[node] = true;
                      }
                    }
                  },
                ),
              ),
            ));
          } else {
            AppToast.show(S.current.warningNoPermissionToAddPublicWebsite);
          }
        },
        child: Row(
          children: <Widget>[
            Text(
              S.current.labelCustom,
              style: Theme.of(context)
                  .accentTextTheme
                  .subtitle2
                  .copyWith(color: buttonColor),
            ),
            Icon(
              Icons.arrow_forward_ios_outlined,
              color: buttonColor,
              size: Theme.of(context).textTheme.subtitle2.fontSize,
            )
          ],
        ),
      ),
    );
  }
}

class RelevanceController {
  RelevanceController({this.onChanged});

  _RelevancePickerState _state;
  void Function() onChanged;

  String get degree => _state?._filter?.baseNode;

  bool get private =>
      _state?._onlyMeSelected ?? _state?.widget?.defaultPrivate ?? true;

  bool get anyone =>
      _state?._anyoneSelected ??
      _state?.widget != null &&
          Provider.of<FilterProvider>(_state.context).defaultRelevance == null;

  List<String> get customRelevance {
    final relevance = <String>[];
    if (_state?._customSelected != null) {
      _state._customSelected.forEach((node, selected) {
        if (selected) {
          relevance.add(node);
        }
      });
    }

    return relevance.isEmpty ? null : relevance;
  }
}

class _RelevancePicker extends StatefulWidget {
  const _RelevancePicker({
    this.canBePrivate = true,
    this.canBeForEveryone = true,
    bool defaultPrivate = false,
    this.controller,
  }) : defaultPrivate = (defaultPrivate ?? true) && canBePrivate;

  /// Whether 'Only me' is an option (this overrides [defaultPrivate])
  final bool canBePrivate;

  /// Whether 'Anyone' is an option
  final bool canBeForEveryone;

  /// Whether the 'Only me' option should be enabled by default
  final bool defaultPrivate;

  final RelevanceController controller;

  @override
  _RelevancePickerState createState() => _RelevancePickerState();
}

class _RelevancePickerState extends State<_RelevancePicker> {
  // The three relevance options ("Only me", "Anyone" or an arbitrary list of nodes) are mutually exclusive
  bool _onlyMeSelected, _anyoneSelected;
  Map<String, bool> _customSelected;

  User _user;
  Filter _filter;

  Future<void> _fetchUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _user = await authProvider.currentUser;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetchFilter() async {
    _filter =
        await Provider.of<FilterProvider>(context, listen: false).fetchFilter();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchFilter();
    _onlyMeSelected = widget.defaultPrivate ?? true;
    _anyoneSelected = !widget.defaultPrivate &&
        Provider.of<FilterProvider>(context, listen: false).defaultRelevance ==
            null;
    _customSelected = {};
  }

  bool get _canAddPublicInfo => _user?.canAddPublicInfo ?? false;

  bool get _somethingSelected {
    if (_onlyMeSelected || _anyoneSelected) {
      return true;
    }

    for (final node in _customSelected.keys) {
      if (_customSelected[node]) {
        return true;
      }
    }
    return false;
  }

  Widget _customRelevanceChips() {
    final widgets = <Widget>[];

    // Add strings from the filter options
    for (final node in _filter?.relevantLocalizedLeaves(context) ?? []) {
      // The "All" case (when nothing is selected in the filter) is handled
      // separately using [_anyoneSelected]
      if (node != 'All') {
        if (!_customSelected.containsKey(node)) {
          _customSelected[node] =
              (!(_onlyMeSelected ?? false) && !(_anyoneSelected ?? false)) ||
                  (!widget.canBePrivate && !widget.canBeForEveryone);
        }

        widgets
          ..add(GestureDetector(
            onTap: () {
              if (!_canAddPublicInfo) {
                AppToast.show(S.current.warningNoPermissionToAddPublicWebsite);
              }
            },
            child: FilterChip(
              label: Text(
                node,
                style: Theme.of(context)
                    .chipTextStyle(selected: _customSelected[node]),
              ),
              selected: _customSelected[node],
              onSelected: !_canAddPublicInfo
                  ? null
                  : (selected) => setState(() {
                        _customSelected[node] = selected;
                        if (selected) {
                          _onlyMeSelected = false;
                          _anyoneSelected = false;
                        }

                        if (widget.controller?.onChanged != null) {
                          widget.controller.onChanged();
                        }
                      }),
            ),
          ))
          ..add(const SizedBox(width: 10));
      }
    }

    // Add the provided website relevance strings, if applicable
    // These are selected by default
    final filterProvider = Provider.of<FilterProvider>(context);
    for (final node in filterProvider.defaultRelevance ?? []) {
      if (!_customSelected.containsKey(node)) {
        _customSelected[node] = true;

        widgets
          ..add(const SizedBox(width: 10))
          ..add(
            GestureDetector(
              onTap: () {
                if (!_canAddPublicInfo) {
                  AppToast.show(
                      S.current.warningNoPermissionToAddPublicWebsite);
                }
              },
              child: FilterChip(
                label: Text(
                  node,
                  style: Theme.of(context)
                      .chipTextStyle(selected: _customSelected[node]),
                ),
                selected: _customSelected[node],
                onSelected: !_canAddPublicInfo
                    ? null
                    : (bool selected) => setState(() {
                          _customSelected[node] = selected;
                          if (selected) {
                            _onlyMeSelected = false;
                            _anyoneSelected = false;
                            widget.controller?.onChanged();
                          }

                          if (widget.controller?.onChanged != null) {
                            widget.controller.onChanged();
                          }
                        }),
              ),
            ),
          );
      }
    }

    return Row(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller != null) {
      widget.controller._state = this;
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        if (widget.canBePrivate)
          Row(
            children: [
              ChoiceChip(
                label: Text(
                  S.current.relevanceOnlyMe,
                  style: Theme.of(context)
                      .chipTextStyle(selected: _onlyMeSelected),
                ),
                selected: _onlyMeSelected,
                onSelected: (selected) => setState(() {
                  if (_user?.canAddPublicInfo ?? false) {
                    _onlyMeSelected = selected;
                    if (selected) {
                      _anyoneSelected = false;
                      for (final node in _customSelected.keys) {
                        _customSelected[node] = false;
                      }
                    } else {
                      _anyoneSelected = true;
                    }
                  } else {
                    _onlyMeSelected = true;
                  }

                  if (widget.controller?.onChanged != null) {
                    widget.controller.onChanged();
                  }
                }),
              ),
              const SizedBox(width: 10),
            ],
          ),
        if (widget.canBeForEveryone)
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (!_canAddPublicInfo) {
                    AppToast.show(
                        S.current.warningNoPermissionToAddPublicWebsite);
                  }
                },
                child: ChoiceChip(
                  label: Text(
                    S.current.relevanceAnyone,
                    style: Theme.of(context).chipTextStyle(
                        selected: !_somethingSelected || _anyoneSelected),
                  ),
                  selected: !_somethingSelected || _anyoneSelected,
                  onSelected: !_canAddPublicInfo
                      ? null
                      : (selected) => setState(() {
                            _anyoneSelected = selected;
                            if (selected) {
                              // Deselect all other options
                              _onlyMeSelected = false;
                              for (final node in _customSelected.keys) {
                                _customSelected[node] = false;
                              }
                            } else {
                              _onlyMeSelected = true;
                            }

                            if (widget.controller?.onChanged != null) {
                              widget.controller.onChanged();
                            }
                          }),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        _customRelevanceChips(),
      ],
    );
  }
}
