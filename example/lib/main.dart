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

  // 移除按钮
  bool _removeButton = false;
  // 定制一行显示的标签列数
  bool _symmetryArrangement = false;
  // _symmetry 选择每行显示的标签数
  int _symmetryColumnPerRow = 0;
  // 一行横向滚动or自动折行纵向排版
  bool _horizontalScroll = true;
  // 单选模式
  bool _singleSelection = true;

  // 显示推荐
  bool _showSuggesttions = false;
  // 组合方式
  String _tagItemCombine = 'withTextBefore';
  // 读取顺序
  bool _startDirection = false;

  // 字体大小
  double _fontSize = 14;

  // +添加数字标签，当前添加计数
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

  var _mapStr2TagItemCombine = {
    'onlyText': TagItemCombine.onlyText,
    'onlyIcon': TagItemCombine.onlyIcon,
    'onlyImage': TagItemCombine.onlyImage,
    'imageOrIconOrText': TagItemCombine.imageOrIconOrText,
    'withTextAfter': TagItemCombine.withTextAfter,
    'withTextBefore': TagItemCombine.withTextBefore,
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
              CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey[300], width: 0.5))),
                      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      child: ExpansionTile(
                        title: Text("Settings"),
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
                                hint: _symmetryColumnPerRow == 0
                                    ? Text("None")
                                    : Text(_symmetryColumnPerRow.toString()),
                                items: _symmetryMenuItems(),
                                onChanged: (a) {
                                  setState(() {
                                    _symmetryColumnPerRow = a;
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
              CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey[300], width: 0.5))),
                      margin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: ExpansionTile(
                        title: Text("Settings"),
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
                                hint: Text(_tagItemCombine),
                                items: _combineMenuItems(),
                                onChanged: (val) {
                                  setState(() {
                                    _tagItemCombine = val;
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
      columns: _symmetryColumnPerRow,
      horizontalScroll: _horizontalScroll,
      //verticalDirection: VerticalDirection.up, textDirection: TextDirection.rtl,
      heightHorizontalScroll: 60 * (_fontSize / 14),
      itemCount: _tagItemTitles.length,
      itemBuilder: (index) {
        final item = _tagItemTitles[index];

        return TagItem(
          key: Key(index.toString()),
          index: index,
          title: item,
          pressEnabled: true,
          activeColor: Colors.blueGrey[600],
          singleSelection: _singleSelection,
          splashColor: Colors.green,
          combine: TagItemCombine.withTextBefore,
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
    TagItemCombine combine =
        _mapStr2TagItemCombine[_tagItemCombine] ?? TagItemCombine.onlyText;

    //popup Menu
    final RenderBox overlay = Overlay.of(context).context?.findRenderObject();

    return TagPanel(
      key: Key("2"),
      symmetry: _symmetryArrangement,
      columns: _symmetryColumnPerRow,
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
          child: TagItem(
            key: Key(index.toString()),
            index: index,
            title: item,
            pressEnabled: false,
            activeColor: Colors.green[400],
            combine: combine,
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
