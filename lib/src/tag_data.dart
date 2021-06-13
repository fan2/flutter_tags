import 'package:flutter/material.dart';

/// Inherited Widget: TagPanelState.build中包裹标签面板
class TagPanelInherited extends InheritedWidget {
  TagPanelInherited(
      {Key key, this.cxtList, this.symmetry, this.itemCount, Widget child})
      : super(key: key, child: child);

  // TagPanelState.build 传入 _cxtList，
  // 后代 TagItem 通过静态 of 获取 TagPanelInherited，访存 cxtList。
  final List<TagItemContext> cxtList;
  final bool symmetry;
  final int itemCount;

  // 数据变更时，不回调通知所有子组件，避免惊群效应；
  // TagItem 监听 ValueNotifier 来实现单个刷新。
  @override
  bool updateShouldNotify(TagPanelInherited old) {
    // don`t callback TagItemState.didChangeDependencies
    return false;
  }

  // static TagPanelInherited of(BuildContext context) =>
  //     context.inheritFromWidgetOfExactType(TagPanelInherited);
  static TagPanelInherited of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType();
}

/// TagItem Data: 向外暴露的标签状态数据
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

/// TagItem Context: 内部扩展 TagItemData，变更时通知标签更新
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

  /// 高亮显示重复标签
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

  /// 是否为点击选中状态
  bool _active;
  get active => _active;
  set active(bool a) {
    _active = a;
    // rebuild only the specific Item that changes its value
    notifyListeners();
  }
}
