import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/classes/service/class_provider.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:time_machine/time_machine.dart';

class GradingChart extends StatefulWidget {
  const GradingChart(
      {Key key,
      this.grading,
      this.withHeader = true,
      this.onSave,
      this.lastUpdated})
      : super(key: key);

  final Map<String, double> grading;
  final bool withHeader;
  final void Function(Map<String, double>) onSave;
  final LocalDateTime lastUpdated;

  @override
  _GradingChartState createState() => _GradingChartState();
}

class _GradingChartState extends State<GradingChart> {
  Map<String, double> get gradingDataMap => widget.grading?.map((name, value) =>
      MapEntry('${name ?? ''}\n${value ?? 0.0}p', value ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            if (widget.withHeader)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).sectionGrading,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      if (widget.grading != null)
                        Text(
                          '${S.of(context).labelLastUpdated}: ${widget.lastUpdated?.toString('dd/MM/yyyy') ?? '?'}',
                          textAlign: TextAlign.left,
                        ),
                    ],
                  ),
                  GestureDetector(
                    onTap: authProvider.currentUserFromCache.canEditClassInfo
                        ? () {}
                        : () => AppToast.show(
                            S.of(context).warningNoPermissionToEditClassInfo),
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed:
                          authProvider.currentUserFromCache.canEditClassInfo
                              ? () => Navigator.of(context).push(
                                      MaterialPageRoute<ChangeNotifierProvider>(
                                    builder: (context) =>
                                        ChangeNotifierProvider.value(
                                      value: classProvider,
                                      child: GradingView(
                                        grading: widget.grading,
                                        onSave: widget.onSave,
                                      ),
                                    ),
                                  ))
                              : null,
                    ),
                  ),
                ],
              ),
            if (gradingDataMap != null && gradingDataMap.isNotEmpty)
              PieChart(
                dataMap: gradingDataMap,
                legendPosition: LegendPosition.left,
                legendStyle: Theme.of(context).textTheme.subtitle2,
                chartRadius: 250,
                chartValueStyle: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                decimalPlaces: 1,
              )
            else
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    S.of(context).labelUnknown,
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GradingView extends StatefulWidget {
  const GradingView({Key key, this.grading, this.onSave}) : super(key: key);

  final Map<String, double> grading;
  final void Function(Map<String, double>) onSave;

  @override
  _GradingViewState createState() => _GradingViewState();
}

class _GradingViewState extends State<GradingView> {
  Map<String, double> grading;
  final formKey = GlobalKey<FormState>();
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> valueControllers = [];
  List<FocusNode> focusNodes = [];
  TextEditingController totalController = TextEditingController(text: '0.0');

  @override
  void initState() {
    super.initState();
    grading = widget.grading;
    widget.grading?.forEach((name, value) {
      nameControllers.add(TextEditingController(text: name));
      focusNodes.add(FocusNode());
      valueControllers.add(TextEditingController(text: value.toString()));
      focusNodes.add(FocusNode());
    });
    nameControllers.add(TextEditingController());
    focusNodes.add(FocusNode());
    valueControllers.add(TextEditingController());
    focusNodes.add(FocusNode());
    updateTotal();
  }

  Future<void> updateTotal() async {
    double total = 0;
    for (final controller in valueControllers) {
      if (controller.text != '' && controller.text != null) {
        total += double.parse(controller.text);
      }
    }
    totalController.text = total.toString();
  }

  Future<void> updateChart() async {
    grading = {};
    nameControllers.asMap().forEach((i, nameController) {
      if (nameController.text != '' && nameController.text != null) {
        if (valueControllers[i].text == '' ||
            valueControllers[i].text == null) {
          grading[nameController.text] = 0.0;
        } else {
          grading[nameController.text] = double.parse(valueControllers[i].text);
        }
      }
    });
    setState(() {});
  }

  Future<void> updateTextFields() async {
    // Add new entry if last one is filled out
    if (nameControllers.last.text != '' &&
        nameControllers.last.text != null &&
        valueControllers.last.text != '' &&
        valueControllers.last.text != null &&
        double.parse(valueControllers.last.text) != 0) {
      nameControllers.add(TextEditingController());
      focusNodes.add(FocusNode());
      valueControllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    }

    for (final i in range(nameControllers.length - 1)) {
      // Remove empty entries
      if ((nameControllers[i].text == '' || nameControllers[i].text == null) &&
          (valueControllers[i].text == '' ||
              valueControllers[i].text == null ||
              double.parse(valueControllers[i].text) == 0)) {
        // Remove focus
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }

        // Remove fields
        nameControllers.removeAt(i);
        focusNodes.removeAt(i);
        valueControllers.removeAt(i);
        focusNodes.removeAt(i);

        break;
      }
    }
    setState(() {});
  }

  List<Widget> buildTextFields() {
    final widgets = <Widget>[];

    for (var i = 0; i < focusNodes.length - 1; i += 2) {
      final nameController = nameControllers[i ~/ 2];
      final valueController = valueControllers[i ~/ 2];

      widgets.add(Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              focusNode: focusNodes[i],
              controller: nameController,
              decoration: InputDecoration(
                hintText: S.of(context).hintEvaluation,
                prefixIcon: const Icon(Icons.label_outlined),
              ),
              validator: (value) {
                if (i == focusNodes.length - 2) {
                  // Ignore the last row
                  return null;
                }
                if (value == '' || value == null) {
                  return S.of(context).warningFieldCannotBeEmpty;
                }
                return null;
              },
              onChanged: (_) {
                updateChart();
                updateTextFields();
              },
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(focusNodes[i + 1]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              focusNode: focusNodes[i + 1],
              controller: valueController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: S.of(context).hintPoints,
              ),
              validator: (value) {
                if (i == focusNodes.length - 2) {
                  // Ignore the last row
                  return null;
                }
                if (value == '' || value == null) {
                  return S.of(context).warningFieldCannotBeEmpty;
                }
                if (double.parse(value) == 0) {
                  return S.of(context).warningFieldCannotBeZero;
                }
                return null;
              },
              onChanged: (_) {
                updateChart();
                updateTotal();
                updateTextFields();
              },
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(focusNodes[i + 2]),
            ),
          )
        ],
      ));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: AppScaffold(
        title: Text(S.of(context).actionEditGrading),
        actions: [
          AppScaffoldAction(
              text: S.of(context).buttonSave,
              onPressed: () {
                if (formKey.currentState.validate()) {
                  widget.onSave(grading);
                  Navigator.of(context).pop();
                }
              })
        ],
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: GradingChart(
                grading: grading,
                withHeader: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  S.of(context).labelEvaluation,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  S.of(context).labelPoints,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      ] +
                      buildTextFields() +
                      [
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Text(
                                  'Total:',
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: totalController,
                                readOnly: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
