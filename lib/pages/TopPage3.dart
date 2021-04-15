import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopPage3_0 extends StatefulWidget {
  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage3_0> {
  CounterBLoC counterBLoC;

  @override
  void initState() {
    super.initState();
    counterBLoC = CounterBLoC(CountRepository());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Bloc Simple Demo'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _WidgetA(counterBLoC),
              _WidgetB(),
              _WidgetC(counterBLoC),
            ],
          ),
        ),
        LoadingWidget1(counterBLoC.isLoading),
      ],
    );
  }

  @override
  void dispose() {
    counterBLoC.dispose();
    super.dispose();
  }
}

class _WidgetA extends StatelessWidget {
  final CounterBLoC counterBLoC;

  _WidgetA(this.counterBLoC);

  @override
  Widget build(BuildContext context) {
    print("called _WidgetA#build()");
    return Center(
      // ボタン押下でこのクラス以下だけが再構築される
      child: StreamBuilder(
        stream: counterBLoC.value,
        builder: (context, snapshot) {
          return Text(
            '${snapshot.data}',
            style: Theme.of(context).textTheme.headline1,
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
  final CounterBLoC counterBLoC;

  _WidgetC(this.counterBLoC);

  @override
  Widget build(BuildContext context) {
    print("called _WidgetC#build()");
    // ignore: deprecated_member_use
    return RaisedButton(
      onPressed: () {
        counterBLoC.incrementCounter();
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
