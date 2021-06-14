import 'package:flutter/material.dart';

import '../flutter_tags.dart';
export 'tag_data.dart';
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
  /// 后续考虑追加+按钮，调起showTextInputDialog输入新增标签
  final TagsTextField textField;

  @override
  TagPanelState createState() => TagPanelState();
}

class TagPanelState extends State<TagPanel> {
  final GlobalKey _containerKey = GlobalKey();
  Orientation _orientation = Orientation.portrait;
  double _width = 0;

  // 内部继承扩展 TagItemData，支持 KVO 通知单个标签刷新
  final List<TagItemContext> _cxtList = [];

  // 向外暴露基类状态数据 TagItemData 列表，以便遍历标签状态
  List<TagItemData> get getAllItemData => _cxtList.toList();

  void appendATag(String title) {
    int index = _cxtList.length;
    _cxtList.add(TagItemContext(title: title, index: index));
  }

  void removeATag(int index) {
    _cxtList.removeAt(index);
  }

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
          children: _buildTagItems(),
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
        children: _buildTagItems(),
      );

    // TagPanelState._cxtList 传入 TagPanelInherited
    return TagPanelInherited(
      cxtList: _cxtList,
      symmetry: widget.symmetry,
      itemCount: widget.itemCount,
      child: child,
    );
  }

  List<Widget> _buildTagItems() {
    /*if(_list.length < widget.itemCount)
            _list.clear();*/

    final Widget textField = widget.textField != null
        ? Container(
            alignment: Alignment.center,
            width: widget.symmetry ? _calcWidth() : widget.textField.width,
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
          width: _calcWidth(),
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
  double _calcWidth() {
    int columns = widget.columns ?? 0;
    int margin = widget.spacing.round();

    int subtraction = columns * (margin);
    double width = (_width > 1) ? (_width - subtraction) / columns : _width;

    return width;
  }
}
