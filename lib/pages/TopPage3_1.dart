import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopPage3_1 extends StatelessWidget {
  final CountRepository _repository;

  TopPage3_1(this._repository);

  @override
  Widget build(BuildContext context) {
    return _HomePage(
        repository: _repository,
        child: Scaffold(
            appBar: AppBar(title: const Text('InteritedWidget BLoc Demo')),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _WidgetA(),
                _WidgetB(),
                _WidgetC(),
              ],
            )));
  }
}

class _HomePage extends StatefulWidget {
  final CountRepository repository;

  _HomePage({
    Key key,
    this.repository,
    this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _HomePageState createState() => _HomePageState();

  static _HomePageState of(BuildContext context, {bool rebuild = true}) {
    if (rebuild) {
      return (context.dependOnInheritedWidgetOfExactType<_MyInheritedWidget>())
          .data;
    }
    return (context
            .getElementForInheritedWidgetOfExactType<_MyInheritedWidget>()
            .widget as _MyInheritedWidget)
        .data;
  }
}

class _HomePageState extends State<_HomePage> {
  CounterBLoC counterBLoC;

  @override
  void initState() {
    super.initState();
    counterBLoC = CounterBLoC(widget.repository);
  }

  @override
  Widget build(BuildContext context) {
    return _MyInheritedWidget(
      data: this,
      child: Stack(
        children: <Widget>[
          widget.child,
          LoadingWidget1(counterBLoC.isLoading),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    counterBLoC.dispose();
  }
}

class _MyInheritedWidget extends InheritedWidget {
  _MyInheritedWidget({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  final _HomePageState data;

  @override
  bool updateShouldNotify(_MyInheritedWidget oldWidget) {
    return true;
  }
}

class _WidgetA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("called _WidgetA#build()");

    final _HomePageState state = _HomePage.of(context, rebuild: false);

    return Center(
      // ボタン押下でこのクラス以下だけが再構築される
      child: StreamBuilder(
        stream: state.counterBLoC.value,
        builder: (context, snapshot) {
          return Text(
            '${snapshot.data}',
            style: Theme.of(context).textTheme.headline4,
          );
        },
      ),
    );
  }
}

class _WidgetB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("called _WidgetB#build()");
    return const Text('I am a widget that will not be rebuilt.');
  }
}

class _WidgetC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("called _WidgetC#build()");

    final _HomePageState state = _HomePage.of(context, rebuild: false);
    // ignore: deprecated_member_use
    return RaisedButton(
      onPressed: () {
        state.counterBLoC.incrementCounter();
      },
      child: Icon(Icons.add),
    );
  }
}

class CountRepository {
  Future<int> fetch() {
    return Future.delayed(const Duration(seconds: 1)).then((_) {
      return 1;
    });
  }
}

class CounterBLoC {
  final CountRepository _repository;

  final _valueController = StreamController<int>();

  final _loadingController = StreamController<bool>();

  Stream<int> get value => _valueController.stream;

  Stream<bool> get isLoading => _loadingController.stream;

  int _counter = 0;

  CounterBLoC(this._repository) {
    _valueController.sink.add(_counter);
    _loadingController.sink.add(false);
  }

  void incrementCounter() async {
    _loadingController.sink.add(true);
    var increaseCount = await _repository.fetch().whenComplete(() {
      _loadingController.sink.add(false);
    });
    _counter += increaseCount;

    _valueController.sink.add(_counter);
  }

  void dispose() {
    _valueController.close();
    _loadingController.close();
  }
}

class LoadingWidget1 extends StatelessWidget {
  final Stream stream;

  const LoadingWidget1(this.stream);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: false,
        stream: stream,
        builder: (context, snapshot) {
          return (snapshot.data)
              ? const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x44000000),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink();
        });
  }
}
