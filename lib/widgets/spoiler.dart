import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const Duration _kExpand = Duration(milliseconds: 200);

class AppSpoiler extends StatefulWidget {
  AppSpoiler({
    Key key,
    this.title = '',
    Widget content,
    this.initiallyExpanded = true,
    this.level = 0,
  })  : content = content ?? Container(),
        super(key: key);

  final String title;
  final Widget content;
  final bool initiallyExpanded;

  /// Level for nested spoilers; the higher the level, the smaller the font size
  final int level;

  @override
  _AppSpoilerState createState() => _AppSpoilerState();
}

class _AppSpoilerState extends State<AppSpoiler>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0, end: 0.5);

  AnimationController _controller;
  Animation<double> _iconTurns;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));

    _isExpanded = widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  void _handleTap() {
    setState(() {
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        visualDensity: const VisualDensity(
          horizontal: VisualDensity.minimumDensity,
          vertical: VisualDensity.minimumDensity,
        ),
      ),
      child: ListTileTheme(
        dense: true,
        child: ExpansionTile(
          key: PageStorageKey(widget.title),
          title: Transform.translate(
            offset: const Offset(-20, 0),
            child: Text(widget.title,
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .apply(fontSizeDelta: -widget.level.toDouble())),
          ),
          initiallyExpanded: widget.initiallyExpanded,
          children: [widget.content],
          leading: RotationTransition(
            turns: _iconTurns,
            child: const Icon(Icons.expand_more_outlined),
          ),
          trailing: Container(width: 0, height: 0),
          tilePadding: EdgeInsets.zero,
          onExpansionChanged: (expansion) {
            _isExpanded = expansion;
            _handleTap();
          },
        ),
      ),
    );
  }
}
