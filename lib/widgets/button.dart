import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AppButton extends StatefulWidget {
  const AppButton(
      {Key key, this.color, this.text, this.textColor, this.onTap, this.width})
      : super(key: key);

  final Color color;
  final String text;
  final Color textColor;
  final Future<dynamic> Function() onTap;
  final double width;

  @override
  _AppButtonState createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  Future<dynamic> future;

  @override
  void initState() {
    super.initState();
    future = Future(() => null);
  }

  Widget _getTextWidget() {
    return AutoSizeText(widget.text.toUpperCase() ?? '',
        textAlign: TextAlign.center,
        minFontSize: 0,
        style: Theme.of(context)
            .textTheme
            .button
            .copyWith(fontWeight: FontWeight.w600));
  }

  @override
  Widget build(BuildContext context) {
    // Set default color if none is set
    final color = widget.color ?? Theme.of(context).backgroundColor;

    return InkWell(
      child: Container(
        width: widget.width ?? double.infinity,
        height: 36,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.1),
                offset: const Offset(0, 8),
                blurRadius: 10,
              )
            ]),
        child: InkWell(
          onTap: () => setState(() {
            future = widget.onTap();
          }),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: FutureBuilder(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              widget.textColor ??
                                  Theme.of(context).textTheme.button.color),
                        ));
                  } else {
                    return _getTextWidget();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
