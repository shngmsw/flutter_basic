import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopPage3_1 extends StatelessWidget {
  final CountRepository _repository;

  TopPage3_1(this._repository);

  @override
  Widget build(BuildContext context) {
    // 階層の上位にProviderがある
    // BLoCのインスタンスもdisposeもProviderの関数内で呼び出される
    return Provider<CounterBloc>(
        create: (context) => CounterBloc(_repository),
        dispose: (_, bloc) => bloc.dispose(),
        child: Stack(
          children: <Widget>[
            Scaffold(
              appBar: AppBar(
                title: const Text('BLoC Demo'),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _WidgetA(),
                  _WidgetB(),
                  _WidgetC(),
                ],
              ),
            ),
            // ConsumerでBLoCを取得できる
            Consumer<CounterBloc>(builder: (context, value, child) {
              return LoadingWidget1(value.isLoading);
            }),
          ],
        ));
  }
}

class _WidgetA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("called _WidgetA#build()");

    // Provider.ofでBLoCを取得できる
    var bloc = Provider.of<CounterBloc>(context, listen: false);

    return Center(
      // ボタン押下でこのクラス以下だけが再構築される
      child: StreamBuilder(
        stream: bloc.value,
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
    // ignore: deprecated_member_use
    return RaisedButton(
      onPressed: () {
        Provider.of<CounterBloc>(context, listen: false).incrementCounter();
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

class CounterBloc {
  final CountRepository _repository;

  final _valueController = StreamController<int>();

  final _loadingController = StreamController<bool>();

  Stream<int> get value => _valueController.stream;

  Stream<bool> get isLoading => _loadingController.stream;

  int _counter = 0;

  CounterBloc(this._repository) {
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
