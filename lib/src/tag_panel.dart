import 'package:flutter/material.dart';

import '../flutter_tags.dart';
import 'util/custom_wrap.dart';
import 'package:flutter_tags/src/suggestions_textfield.dart';

///ItemBuilder
typedef Widget ItemBuilder(int index);

class TagPanel extends StatefulWidget {
  TagPanel(
      {this.columns,
      this.itemCount = 0,
      this.symmetry = false,
      this.horizontalScroll = false,
      this.heightHorizontalScroll = 60,
      this.spacing = 6,
      this.runSpacing = 14,
      this.alignment = WrapAlignment.center,
      this.runAlignment = WrapAlignment.center,
      this.direction = Axis.horizontal,
      this.verticalDirection = VerticalDirection.down,
      this.textDirection = TextDirection.ltr,
      this.itemBuilder,
      this.textField,
      Key key})
      : assert(itemCount >= 0),
        assert(alignment != null),
        assert(runAlignment != null),
        assert(direction != null),
        assert(verticalDirection != null),
        assert(textDirection != null),
        super(key: key);

  ///specific number of columns
  final int columns;

  ///numer of item List
  final int itemCount;

  /// imposes the same width and the same number of columns for each row
  final bool symmetry;

  /// ability to scroll tags horizontally
  final bool horizontalScroll;

  /// horizontal spacing of  the [TagItem]
  final double heightHorizontalScroll;

  /// horizontal spacing of  the [TagItem]
  final double spacing;

  /// vertical spacing of  the [TagItem]
  final double runSpacing;

  /// horizontal alignment of  the [TagItem]
  final WrapAlignment alignment;

  /// vertical alignment of  the [TagItem]
  final WrapAlignment runAlignment;

  /// direction of  the [TagItem]
  final Axis direction;

  /// Iterate [TagItemData] from the lower to the upper direction or vice versa
  final VerticalDirection verticalDirection;

  /// Text direction of  the [TagItem]
  final TextDirection textDirection;

  /// Generates a list of [TagItem].
  ///
  /// Creates a list with [length] positions and fills it with values created by
  /// calling [generator] for each index in the range `0` .. `length - 1`
  /// in increasing order.
  final ItemBuilder itemBuilder;

  /// custom TextField
  final TagsTextField textField;

  @override
  TagPanelState createState() => TagPanelState();
}

class TagPanelState extends State<TagPanel> {
  final GlobalKey _containerKey = GlobalKey();
  Orientation _orientation = Orientation.portrait;
  double _width = 0;

  final List<TagItemContext> _cxtList = [];

  // 返回标签数据 TagItemData 列表，以便遍历标签状态
  List<TagItemData> get getAllItemData => _cxtList.toList();

  //get the current width of the screen
  void _getWidthContext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _containerKey.currentContext;
      if (keyContext != null) {
        final RenderBox box = keyContext.findRenderObject();
        final size = box.size;
        setState(() {
          _width = size.width;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // essential to avoid infinite loop of addPostFrameCallback
    if (widget.symmetry &&
        (MediaQuery.of(context).orientation != _orientation || _width == 0)) {
      _orientation = MediaQuery.of(context).orientation;
      _getWidthContext();
    }

    Widget child;
    if (widget.horizontalScroll && !widget.symmetry)
      child = Container(
        height: widget.heightHorizontalScroll,
        color: Colors.transparent,
        child: ListView(
          padding: EdgeInsets.all(0),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: _buildItems(),
        ),
      );
    else
      child = CustomWrap(
        key: _containerKey,
        alignment: widget.alignment,
        runAlignment: widget.runAlignment,
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        column: widget.columns,
        symmetry: widget.symmetry,
        textDirection: widget.textDirection,
        direction: widget.direction,
        verticalDirection: widget.verticalDirection,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: _buildItems(),
      );

    return TagPanelInherited(
      cxtList: _cxtList,
      symmetry: widget.symmetry,
      itemCount: widget.itemCount,
      child: child,
    );
  }

  List<Widget> _buildItems() {
    /*if(_list.length < widget.itemCount)
            _list.clear();*/

    final Widget textField = widget.textField != null
        ? Container(
            alignment: Alignment.center,
            width: widget.symmetry ? _widthCalc() : widget.textField.width,
            padding: widget.textField.padding,
            child: SuggestionsTextField(
              tagsTextField: widget.textField,
              onSubmitted: (String str) {
                if (!widget.textField.duplicates) {
                  // 遍历现有标签，查找出重复的
                  final List<TagItemContext> lst =
                      _cxtList.where((l) => l.title == str).toList();
                  // 将已有标签标记为重复
                  if (lst.isNotEmpty) {
                    lst.forEach((d) => d.duplicated = true);
                    return;
                  }
                }

                if (widget.textField.onSubmitted != null)
                  widget.textField.onSubmitted(str);
              },
            ),
          )
        : null;

    List<Widget> finalList = [];

    List<Widget> itemList = List.generate(widget.itemCount, (i) {
      final Widget item = widget.itemBuilder(i);
      if (widget.symmetry)
        return Container(
          width: _widthCalc(),
          child: item,
        );
      else if (widget.horizontalScroll)
        return Container(
          margin: EdgeInsets.symmetric(horizontal: widget.spacing),
          alignment: Alignment.center,
          child: item,
        );
      return item;
    });

    if (widget.horizontalScroll && widget.textDirection == TextDirection.rtl)
      itemList = itemList.reversed.toList();

    if (textField == null) {
      finalList.addAll(itemList);
      return finalList;
    }

    if (widget.horizontalScroll &&
        widget.verticalDirection == VerticalDirection.up) {
      finalList.add(textField);
      finalList.addAll(itemList);
    } else {
      finalList.addAll(itemList);
      finalList.add(textField);
    }

    return finalList;
  }

  //Container width divided by the number of columns when symmetry is active
  double _widthCalc() {
    int columns = widget.columns ?? 0;
    int margin = widget.spacing.round();

    int subtraction = columns * (margin);
    double width = (_width > 1) ? (_width - subtraction) / columns : _width;

    return width;
  }
}

/// Inherited Widget
class TagPanelInherited extends InheritedWidget {
  TagPanelInherited(
      {Key key, this.cxtList, this.symmetry, this.itemCount, Widget child})
      : super(key: key, child: child);

  final List<TagItemContext> cxtList;
  final bool symmetry;
  final int itemCount;

  @override
  bool updateShouldNotify(TagPanelInherited old) {
    //print("inherited");
    return false;
  }

  /*static TagPanelProxy of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(TagPanelProxy);*/
  static TagPanelInherited of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType();
}

/// Data List
class TagItemContext extends ValueNotifier implements TagItemData {
  TagItemContext(
      {@required this.title,
      this.index,
      bool highlights = false,
      bool active = true,
      this.customData})
      : _duplicated = highlights,
        _active = active,
        super(active);

  final String title;
  final dynamic customData;
  final int index;

  /// 红色高亮显示已有重复标签
  bool _duplicated;

  get duplicated {
    final val = _duplicated;
    _duplicated = false;
    return val;
  }

  set duplicated(bool a) {
    _duplicated = a;
    // rebuild only the specific Item that changes its value
    notifyListeners();
  }

  /// 是否为被选中状态
  bool _active;
  get active => _active;
  set active(bool a) {
    _active = a;
    // rebuild only the specific Item that changes its value
    notifyListeners();
  }
}
