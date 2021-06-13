import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_tags/flutter_tags.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tags Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'Flutter Tags'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  ScrollController _scrollViewController;

  // 移除按钮：只影响 Demo 1
  bool _removeButton = false;
  // 禁止横向滚动，自动折行排版：同时影响 Demo 1 和 Demo 2
  bool _horizontalScroll = true;
  // 对称排版，每个标签宽度一致：同时影响 Demo 1 和 Demo 2
  /// 勾选 None 默认为 1，已勾选时不可再选 None
  bool _symmetryArrangement = false;
  // 每行显示的标签数：同时影响 Demo 1 和 Demo 2
  /// 禁用 _horizontalScroll 自动折行或开启 symmetryArrangement，排版受该参数影响
  int _columnPerRow = 0;
  // 单选模式：只影响 Demo 1，Demo 2 不支持点选
  bool _singleSelection = false;

  // 显示推荐：只影响 Demo 2 _addTagTextField
  bool _showSuggesttions = false;
  // 组合方式：只影响 Demo 2 _combineMenuItems
  String _tagItemCombineMode = 'withTextBefore';
  // 读取顺序：只影响 Demo 2
  bool _startDirection = false;

  // 字体大小：同时影响 Demo 1 和 Demo 2
  double _fontSize = 14;

  // Demo 1 + 添加数字标签，当前添加计数
  int _addCount = 0;

  // 初始标签标题列表
  final List<String> _initTagItemTitles = [
    '0',
    'SDK',
    'plugin updates',
    'Facebook',
    '哔了狗了QP又不够了',
    'Kirchhoff',
    'Italy',
    'France',
    'Spain',
    '美',
    'Dart',
    'SDK',
    'Foo',
    'Select',
    'lorem ip',
    '9',
    'Star',
    'Flutter Selectable Tags',
    '1',
    'Hubble',
    '2',
    'Input flutter tags',
    'A B C',
    '8',
    'Android Studio developer',
    'welcome to the jungle',
    'Gauss',
    '美术',
    '互联网',
    '炫舞时代',
    '篝火营地',
  ];

  // 拷贝标签标题列表
  List _tagItemTitles;

  var _mapStr2TagItemCombineMode = {
    'onlyText': TagItemCombineMode.onlyText,
    'onlyIcon': TagItemCombineMode.onlyIcon,
    'onlyImage': TagItemCombineMode.onlyImage,
    'imageOrIconOrText': TagItemCombineMode.imageOrIconOrText,
    'withTextAfter': TagItemCombineMode.withTextAfter,
    'withTextBefore': TagItemCombineMode.withTextBefore,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollViewController = ScrollController();

    _tagItemTitles = _initTagItemTitles.toList();
  }

  final GlobalKey<TagPanelState> _tagPanelKey = GlobalKey<TagPanelState>();

  @override
  Widget build(BuildContext context) {
    //List<Item> lst = _tagStateKey.currentState?.getAllItem; lst.forEach((f) => print(f.title));
    return Scaffold(
      body: NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text("flutter tags"),
                centerTitle: true,
                pinned: true,
                expandedHeight: 0,
                floating: true,
                forceElevated: boxIsScrolled,
                bottom: TabBar(
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: TextStyle(fontSize: 18.0),
                  tabs: [
                    Tab(text: "Demo 1"),
                    Tab(text: "Demo 2"),
                  ],
                  controller: _tabController,
                ),
              )
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Demo 1
              CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate([
                    // Settings 1
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey[300], width: 0.5))),
                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      child: ExpansionTile(
                        title: Text("Settings 1"),
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                child: Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: _removeButton,
                                        onChanged: (a) {
                                          setState(() {
                                            _removeButton = !_removeButton;
                                          });
                                        }),
                                    Text('Remove Button')
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _removeButton = !_removeButton;
                                  });
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                              ),
                              GestureDetector(
                                child: Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: _symmetryArrangement,
                                        onChanged: (a) {
                                          setState(() {
                                            // 初始勾选时，None 转为 1
                                            if (!_symmetryArrangement &&
                                                _columnPerRow == 0) {
                                              _columnPerRow = 1;
                                            }
                                            _symmetryArrangement =
                                                !_symmetryArrangement;
                                          });
                                        }),
                                    Text('Symmetry')
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _symmetryArrangement =
                                        !_symmetryArrangement;
                                  });
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                              ),
                              DropdownButton(
                                hint: _columnPerRow == 0
                                    ? Text("None")
                                    : Text(_columnPerRow.toString()),
                                items: _symmetryMenuItems(),
                                onChanged: (a) {
                                  // 已勾选时，不能再选 None
                                  if (_symmetryArrangement && a == 0) {
                                    return;
                                  }
                                  setState(() {
                                    _columnPerRow = a;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                child: Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: _horizontalScroll,
                                        onChanged: (a) {
                                          setState(() {
                                            _horizontalScroll =
                                                !_horizontalScroll;
                                          });
                                        }),
                                    Text('Horizontal Scroll')
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _horizontalScroll = !_horizontalScroll;
                                  });
                                },
                              ),
                              GestureDetector(
                                child: Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: _singleSelection,
                                        onChanged: (a) {
                                          setState(() {
                                            _singleSelection =
                                                !_singleSelection;
                                          });
                                        }),
                                    Text('Single Selection')
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _singleSelection = !_singleSelection;
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text('Font Size'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Slider(
                                    value: _fontSize,
                                    min: 6,
                                    max: 30,
                                    onChanged: (a) {
                                      setState(() {
                                        _fontSize = (a.round()).toDouble();
                                      });
                                    },
                                  ),
                                  Text(_fontSize.toString()),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    //color: Colors.blueGrey,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      //color: Colors.white,
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          _addCount++;
                                          _tagItemTitles
                                              .add(_addCount.toString());
                                          //_items.removeAt(3); _items.removeAt(10);
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    //color: Colors.grey,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      //color: Colors.white,
                                      icon: Icon(Icons.refresh),
                                      onPressed: () {
                                        setState(() {
                                          _tagItemTitles =
                                              _initTagItemTitles.toList();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                    ),
                    _tagPanel1,
                    Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: <Widget>[
                            Divider(
                              color: Colors.blueGrey,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('--- Demo 1 ---'),
                            ),
                          ],
                        )),
                  ])),
                ],
              ),
              // Demo 2
              CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate([
                    // Settings 2
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey[300], width: 0.5))),
                      margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: ExpansionTile(
                        title: Text("Settings 2"),
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                child: Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: _showSuggesttions,
                                        onChanged: (a) {
                                          setState(() {
                                            _showSuggesttions =
                                                !_showSuggesttions;
                                          });
                                        }),
                                    Text('Suggestions')
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _showSuggesttions = !_showSuggesttions;
                                  });
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.all(20),
                              ),
                              DropdownButton(
                                hint: Text(_tagItemCombineMode),
                                items: _combineMenuItems(),
                                onChanged: (val) {
                                  setState(() {
                                    _tagItemCombineMode = val;
                                  });
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                child: Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: _horizontalScroll,
                                        onChanged: (a) {
                                          setState(() {
                                            _horizontalScroll =
                                                !_horizontalScroll;
                                          });
                                        }),
                                    Text('Horizontal Scroll')
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _horizontalScroll = !_horizontalScroll;
                                  });
                                },
                              ),
                              GestureDetector(
                                child: Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: _startDirection,
                                        onChanged: (a) {
                                          setState(() {
                                            _startDirection = !_startDirection;
                                          });
                                        }),
                                    Text('Start Direction')
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    _startDirection = !_startDirection;
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text('Font Size'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Slider(
                                    value: _fontSize,
                                    min: 6,
                                    max: 30,
                                    onChanged: (a) {
                                      setState(() {
                                        _fontSize = (a.round()).toDouble();
                                      });
                                    },
                                  ),
                                  Text(_fontSize.toString()),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                    ),
                    _tagPanel2,
                    Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: <Widget>[
                            Divider(
                              color: Colors.blueGrey,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text('--- Demo 2 ---'),
                            ),
                          ],
                        )),
                  ])),
                ],
              ),
            ],
          )),
    );
  }

  Widget get _tagPanel1 {
    return TagPanel(
      key: _tagPanelKey,
      symmetry: _symmetryArrangement,
      columns: _columnPerRow,
      horizontalScroll: _horizontalScroll,
      //verticalDirection: VerticalDirection.up, textDirection: TextDirection.rtl,
      heightHorizontalScroll: 60 * (_fontSize / 14),
      itemCount: _tagItemTitles.length,
      itemBuilder: (index) {
        final item = _tagItemTitles[index];

        // pressEnabled: true, removeButton?,
        // pass singleSelection default true-!active
        return TagItem(
          key: Key(index.toString()),
          index: index,
          title: item,
          pressEnabled: true,
          activeColor: Colors.blueGrey[600],
          singleSelection: _singleSelection,
          splashColor: Colors.green,
          combineMode: TagItemCombineMode.withTextBefore,
          image: null,
          icon: null,
          removeButton: _removeButton
              ? TagItemRemoveButton(
                  onRemoved: () {
                    setState(() {
                      _tagItemTitles.removeAt(index);
                    });
                    return true;
                  },
                )
              : null,
          textScaleFactor:
              utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
          textStyle: TextStyle(
            fontSize: _fontSize,
          ),
          onPressed: (item) => print(item),
        );
      },
    );
  }

  // Position for popup menu
  Offset _tapPosition;

  Widget get _tagPanel2 {
    TagItemCombineMode combineMode =
        _mapStr2TagItemCombineMode[_tagItemCombineMode] ??
            TagItemCombineMode.onlyText;

    //popup Menu
    final RenderBox overlay = Overlay.of(context).context?.findRenderObject();

    return TagPanel(
      key: Key("2"),
      symmetry: _symmetryArrangement,
      columns: _columnPerRow,
      horizontalScroll: _horizontalScroll,
      verticalDirection:
          _startDirection ? VerticalDirection.up : VerticalDirection.down,
      textDirection: _startDirection ? TextDirection.rtl : TextDirection.ltr,
      heightHorizontalScroll: 60 * (_fontSize / 14),
      textField: _addTagTextField,
      itemCount: _tagItemTitles.length,
      itemBuilder: (index) {
        final item = _tagItemTitles[index];

        // 包裹手势控件，支持长按浮出菜单
        return GestureDetector(
          // pressEnabled: false, removeButton,
          // internal singleSelection default false-active
          child: TagItem(
            key: Key(index.toString()),
            index: index,
            title: item,
            active: true,
            pressEnabled: false,
            activeColor: Colors.green[400],
            combineMode: combineMode,
            image: null,
            icon: null,
            removeButton: TagItemRemoveButton(
              backgroundColor: Colors.green[900],
              onRemoved: () {
                setState(() {
                  _tagItemTitles.removeAt(index);
                });
                return true;
              },
            ),
            textScaleFactor:
                utf8.encode(item.substring(0, 1)).length > 2 ? 0.8 : 1,
            textStyle: TextStyle(
              fontSize: _fontSize,
            ),
          ),
          onTapDown: (details) => _tapPosition = details.globalPosition,
          onLongPress: () {
            showMenu(
                    //semanticLabel: item,
                    items: <PopupMenuEntry>[
                  PopupMenuItem(
                    child: Text(item, style: TextStyle(color: Colors.blueGrey)),
                    enabled: false,
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.content_copy),
                        Text("Copy text"),
                      ],
                    ),
                  ),
                ],
                    context: context,
                    position: RelativeRect.fromRect(
                        _tapPosition & Size(40, 40),
                        Offset.zero &
                            overlay
                                .size) // & RelativeRect.fromLTRB(65.0, 40.0, 0.0, 0.0),
                    )
                .then((value) {
              if (value == 1) Clipboard.setData(ClipboardData(text: item));
            });
          },
        );
      },
    );
  }

  TagsTextField get _addTagTextField {
    return TagsTextField(
      autofocus: false,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10),
      textStyle: TextStyle(
        fontSize: _fontSize,
        //height: 1
      ),
      enabled: true,
      constraintSuggestion: true,
      suggestions: _showSuggesttions
          ? [
              "One",
              "two",
              "android",
              "Dart",
              "flutter",
              "test",
              "tests",
              "androids",
              "androidsaaa",
              "Test",
              "suggest",
              "suggestions",
              "互联网",
              "last",
              "lest",
              "炫舞时代"
            ]
          : null,
      onSubmitted: (String str) {
        setState(() {
          _tagItemTitles.add(str);
        });
      },
    );
  }

  List<DropdownMenuItem> _symmetryMenuItems() {
    List<DropdownMenuItem> list = [];

    int count = 8;

    list.add(
      DropdownMenuItem(
        child: Text("None"),
        value: 0,
      ),
    );

    for (int i = 1; i < count; i++)
      list.add(
        DropdownMenuItem(
          child: Text(i.toString()),
          value: i,
        ),
      );

    return list;
  }

  List<DropdownMenuItem> _combineMenuItems() {
    List<DropdownMenuItem> list = [];

    list.add(DropdownMenuItem(
      child: Text("onlyText"),
      value: 'onlyText',
    ));

    list.add(DropdownMenuItem(
      child: Text("onlyIcon"),
      value: 'onlyIcon',
    ));
    list.add(DropdownMenuItem(
      child: Text("onlyImage"),
      value: 'onlyImage',
    ));
    list.add(DropdownMenuItem(
      child: Text("imageOrIconOrText"),
      value: 'imageOrIconOrText',
    ));
    list.add(DropdownMenuItem(
      child: Text("withTextBefore"),
      value: 'withTextBefore',
    ));
    list.add(DropdownMenuItem(
      child: Text("withTextAfter"),
      value: 'withTextAfter',
    ));
    return list;
  }
}
