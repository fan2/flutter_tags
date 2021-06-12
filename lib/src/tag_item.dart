import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tags/src/tag_panel.dart';

/// Used by [TagItem.onPressed].
typedef OnPressedCallback = void Function(TagItemData i);

/// Used by [TagItem.OnLongPressed].
typedef OnLongPressedCallback = void Function(TagItemData i);

/// Used by [TagItem.removeButton.onRemoved].
typedef OnRemovedCallback = bool Function();

/// combines icon text or image
enum TagItemCombine {
  onlyText,
  onlyIcon,
  onlyImage,
  imageOrIconOrText,
  withTextBefore,
  withTextAfter
}

class TagItem extends StatefulWidget {
  TagItem(
      {@required this.index,
      @required this.title,
      this.textScaleFactor,
      this.active = true,
      this.pressEnabled = true,
      this.customData,
      this.textStyle = const TextStyle(fontSize: 14),
      this.alignment = MainAxisAlignment.center,
      this.combine = TagItemCombine.imageOrIconOrText,
      this.icon,
      this.image,
      this.removeButton,
      this.borderRadius,
      this.border,
      this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      this.elevation = 5,
      this.singleSelection = false,
      this.textOverflow = TextOverflow.fade,
      this.textColor = Colors.black,
      this.textActiveColor = Colors.white,
      this.color = Colors.white,
      this.activeColor = Colors.blueGrey,
      this.highlightColor,
      this.splashColor,
      this.duplicatedColor = Colors.red,
      this.onPressed,
      this.onLongPressed,
      Key key})
      : assert(index != null),
        assert(title != null),
        super(key: key);

  /// Id of [TagItem] - required
  final int index;

  /// Title of [TagItem] - required
  final String title;

  /// Scale Factor of [TagItem] - double
  final double textScaleFactor;

  /// Initial bool value
  final bool active;

  /// Initial bool value
  final bool pressEnabled;

  /// Possibility to add any custom value in customData field, you can retrieve this later. A good example: store an id from Firestore document.
  final dynamic customData;

  /// TagItemCombine (text,icon,textIcon,textImage) of [TagItem]
  final TagItemCombine combine;

  /// Icon of [TagItem]
  final TagItemIcon icon;

  /// Image of [TagItem]
  final TagItemImage image;

  /// Custom Remove Button of [TagItem]
  final TagItemRemoveButton removeButton;

  /// TextStyle of the [TagItem]
  final TextStyle textStyle;

  /// TextStyle of the [TagItem]
  final MainAxisAlignment alignment;

  /// border-radius of [TagItem]
  final BorderRadius borderRadius;

  /// custom border-side of [TagItem]
  final BoxBorder border;

  /// padding of the [TagItem]
  final EdgeInsets padding;

  /// BoxShadow of the [TagItem]
  final double elevation;

  /// when you want only one tag selected. same radio-button
  final bool singleSelection;

  /// type of text overflow within the [TagItem]
  final TextOverflow textOverflow;

  /// text color of the [TagItem]
  final Color textColor;

  /// color of the [TagItem] text activated
  final Color textActiveColor;

  /// background color [TagItem]
  final Color color;

  /// background color [TagItem] activated
  final Color activeColor;

  /// highlight Color [TagItem]
  final Color highlightColor;

  /// Splash color [TagItem]
  final Color splashColor;

  /// Color show duplicate [TagItem]
  final Color duplicatedColor;

  /// callback
  final OnPressedCallback onPressed;

  /// callback
  final OnLongPressedCallback onLongPressed;

  @override
  _TagItemState createState() => _TagItemState();
}

class _TagItemState extends State<TagItem> {
  final double _initBorderRadius = 50;

  TagPanelInherited _tagPanelIn;
  TagItemContext _tagItemCxt;

  void _setItemContext() {
    // Get TagPanelInherited of current context
    // 当前标签向上寻找最近的 InheritedWidget 基类
    _tagPanelIn = TagPanelInherited.of(context);

    // set List length
    if (_tagPanelIn.cxtList.length < _tagPanelIn.itemCount)
      _tagPanelIn.cxtList.length = _tagPanelIn.itemCount;

    if (_tagPanelIn.cxtList.length > (widget.index + 1) &&
        _tagPanelIn.cxtList.elementAt(widget.index) != null &&
        _tagPanelIn.cxtList.elementAt(widget.index).title != widget.title) {
      // when an element is removed from the data source
      _tagPanelIn.cxtList.removeAt(widget.index);

      // when all item list changed in data source
      if (_tagPanelIn.cxtList.elementAt(widget.index) != null &&
          _tagPanelIn.cxtList.elementAt(widget.index).title != widget.title)
        _tagPanelIn.cxtList
            .removeRange(widget.index, _tagPanelIn.cxtList.length);
    }

    // add new Item in the List
    if (_tagPanelIn.cxtList.length < (widget.index + 1)) {
      //print("add");
      _tagPanelIn.cxtList.insert(
          widget.index,
          TagItemContext(
              title: widget.title,
              index: widget.index,
              active: widget.singleSelection ? false : widget.active,
              customData: widget.customData));
    } else if (_tagPanelIn.cxtList.elementAt(widget.index) == null) {
      //print("replace");
      _tagPanelIn.cxtList[widget.index] = TagItemContext(
          title: widget.title,
          index: widget.index,
          active: widget.singleSelection ? false : widget.active,
          customData: widget.customData);
    }

    // removes items that have been orphaned
    if (_tagPanelIn.itemCount == widget.index + 1 &&
        _tagPanelIn.cxtList.length > _tagPanelIn.itemCount)
      _tagPanelIn.cxtList
          .removeRange(widget.index + 1, _tagPanelIn.cxtList.length);

    //print(_tagPanelIn.cxtList.length);

    // update Listener
    if (_tagItemCxt != null) _tagItemCxt.removeListener(_didValueChange);

    _tagItemCxt = _tagPanelIn.cxtList.elementAt(widget.index);
    _tagItemCxt.addListener(_didValueChange);
  }

  _didValueChange() => setState(() {});

  @override
  void dispose() {
    _tagItemCxt.removeListener(_didValueChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setItemContext();

    final double fontSize = widget.textStyle.fontSize;

    Color color = _tagItemCxt.active ? widget.activeColor : widget.color;

    if (_tagItemCxt.duplicated) color = widget.duplicatedColor;

    return Material(
      color: color,
      borderRadius:
          widget.borderRadius ?? BorderRadius.circular(_initBorderRadius),
      elevation: widget.elevation,
      //shadowColor: _tagItemCxt.highlights? Colors.red : Colors.blue,
      child: InkWell(
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(_initBorderRadius),
        highlightColor:
            widget.pressEnabled ? widget.highlightColor : Colors.transparent,
        splashColor:
            widget.pressEnabled ? widget.splashColor : Colors.transparent,
        child: Container(
            decoration: BoxDecoration(
                border: widget.border ??
                    Border.all(color: widget.activeColor, width: 0.5),
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(_initBorderRadius)),
            padding: widget.padding * (fontSize / 14),
            child: _combine),
        onTap: widget.pressEnabled
            ? () {
                if (widget.singleSelection) {
                  _deactivateOtherItems(_tagPanelIn, _tagItemCxt);
                  _tagItemCxt.active = true;
                } else
                  _tagItemCxt.active = !_tagItemCxt.active;

                if (widget.onPressed != null)
                  widget.onPressed(TagItemData(
                      index: widget.index,
                      title: _tagItemCxt.title,
                      active: _tagItemCxt.active,
                      customData: widget.customData));
              }
            : null,
        onLongPress: widget.onLongPressed != null
            ? () => widget.onLongPressed(TagItemData(
                index: widget.index,
                title: _tagItemCxt.title,
                active: _tagItemCxt.active,
                customData: widget.customData))
            : null,
      ),
    );
  }

  Widget get _combine {
    if (widget.image != null)
      assert((widget.image.image != null && widget.image.child == null) ||
          (widget.image.child != null && widget.image.image == null));
    final Widget text = Text(
      widget.title,
      softWrap: false,
      textAlign: _textAlignment,
      overflow: widget.textOverflow,
      textScaleFactor: widget.textScaleFactor,
      style: _textStyle,
    );
    final Widget icon = widget.icon != null
        ? Container(
            padding: widget.icon.padding ??
                (widget.combine == TagItemCombine.onlyIcon ||
                        widget.combine == TagItemCombine.imageOrIconOrText
                    ? null
                    : widget.combine == TagItemCombine.withTextAfter
                        ? EdgeInsets.only(right: 5)
                        : EdgeInsets.only(left: 5)),
            child: Icon(
              widget.icon.icon,
              color: _textStyle.color,
              size: _textStyle.fontSize * 1.2,
            ),
          )
        : text;
    final Widget image = widget.image != null
        ? Container(
            padding: widget.image.padding ??
                (widget.combine == TagItemCombine.onlyImage ||
                        widget.combine == TagItemCombine.imageOrIconOrText
                    ? null
                    : widget.combine == TagItemCombine.withTextAfter
                        ? EdgeInsets.only(right: 5)
                        : EdgeInsets.only(left: 5)),
            child: widget.image.child ??
                CircleAvatar(
                  radius:
                      widget.image.radius * (widget.textStyle.fontSize / 14),
                  backgroundColor: Colors.transparent,
                  backgroundImage: widget.image.image,
                ),
          )
        : text;

    final List list = [];

    switch (widget.combine) {
      case TagItemCombine.onlyText:
        list.add(text);
        break;
      case TagItemCombine.onlyIcon:
        list.add(icon);
        break;
      case TagItemCombine.onlyImage:
        list.add(image);
        break;
      case TagItemCombine.imageOrIconOrText:
        list.add((image != text ? image : icon));
        break;
      case TagItemCombine.withTextBefore:
        list.add(text);
        if (image != text)
          list.add(image);
        else if (icon != text) list.add(icon);
        break;
      case TagItemCombine.withTextAfter:
        if (image != text)
          list.add(image);
        else if (icon != text) list.add(icon);
        list.add(text);
    }

    final Widget row = Row(
        mainAxisAlignment: widget.alignment,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(list.length, (i) {
          if (i == 0 && list.length > 1)
            return Flexible(
              flex: widget.combine == TagItemCombine.withTextAfter ? 0 : 1,
              child: list[i],
            );
          return Flexible(
            flex: widget.combine == TagItemCombine.withTextAfter ||
                    list.length == 1
                ? 1
                : 0,
            child: list[i],
          );
        }));

    if (widget.removeButton != null)
      return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
                fit: _tagPanelIn.symmetry ? FlexFit.tight : FlexFit.loose,
                flex: 2,
                child: row),
            Flexible(
                flex: 0,
                child: FittedBox(
                    alignment: Alignment.centerRight,
                    fit: BoxFit.fill,
                    child: GestureDetector(
                      child: Container(
                        margin: widget.removeButton.margin ??
                            EdgeInsets.only(left: 5),
                        padding:
                            (widget.removeButton.padding ?? EdgeInsets.all(2)) *
                                (widget.textStyle.fontSize / 14),
                        decoration: BoxDecoration(
                          color: widget.removeButton.backgroundColor ??
                              Colors.black,
                          borderRadius: widget.removeButton.borderRadius ??
                              BorderRadius.circular(_initBorderRadius),
                        ),
                        child: widget.removeButton.padding ??
                            Icon(
                              Icons.clear,
                              color: widget.removeButton.color ?? Colors.white,
                              size: (widget.removeButton.size ?? 12) *
                                  (widget.textStyle.fontSize / 14),
                            ),
                      ),
                      onTap: () {
                        if (widget.removeButton.onRemoved != null) {
                          if (widget.removeButton.onRemoved())
                            _tagPanelIn.cxtList.removeAt(widget.index);
                        }
                      },
                    )))
          ]);

    return row;
  }

  ///Text Alignment
  TextAlign get _textAlignment {
    switch (widget.alignment) {
      case MainAxisAlignment.spaceBetween:
      case MainAxisAlignment.start:
        return TextAlign.start;
        break;
      case MainAxisAlignment.end:
        return TextAlign.end;
        break;
      case MainAxisAlignment.spaceAround:
      case MainAxisAlignment.spaceEvenly:
      case MainAxisAlignment.center:
        return TextAlign.center;
    }
    return null;
  }

  ///TextStyle
  TextStyle get _textStyle {
    return widget.textStyle.apply(
      color: _tagItemCxt.active ? widget.textActiveColor : widget.textColor,
    );
  }

  /// Deactivate other active TagItems
  void _deactivateOtherItems(
      TagPanelInherited panelIn, TagItemContext itemCxt) {
    panelIn.cxtList.where((tg) {
      return tg?.active == true && tg != itemCxt;
    }).forEach((tg) => tg.active = false);
  }
}

///callback
class TagItemData {
  TagItemData({this.index, this.title, this.active, this.customData});
  final int index;
  final String title;
  final bool active;
  final dynamic customData;

  @override
  String toString() {
    return "id:$index, title: $title, active: $active, customData: $customData";
  }
}

/// TagItem Image
class TagItemImage {
  TagItemImage({this.radius = 8, this.padding, this.image, this.child});

  final double radius;
  final EdgeInsets padding;
  final ImageProvider image;
  final Widget child;
}

/// TagItem Icon
class TagItemIcon {
  TagItemIcon({this.padding, @required this.icon});

  final EdgeInsets padding;
  final IconData icon;
}

/// TagItem RemoveButton
class TagItemRemoveButton {
  TagItemRemoveButton(
      {this.icon,
      this.size,
      this.backgroundColor,
      this.color,
      this.borderRadius,
      this.padding,
      this.margin,
      this.onRemoved});

  final IconData icon;
  final double size;
  final Color backgroundColor;
  final Color color;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;

  /// callback
  final OnRemovedCallback onRemoved;
}
