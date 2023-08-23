import 'package:easy_color/easy_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  EasyColor easyColor = EasyColor();
  TextEditingController colorText = TextEditingController(text: 'rojo');

  Future? fLoad;
  Future<Map?>? fColorMap;

  @override
  initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        fLoad = easyColor.initialize();
      });
    });
  }

  void _getColor() {
    String colorNameStr = colorText.text;
    setState(() {
      fColorMap = easyColor.getColorMap(colorNameStr);
    });
  }

  void _clearColor() {
    setState(() {
      fColorMap = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: fLoad,
          builder: (context, data) {
            if (data.connectionState == ConnectionState.done) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: colorText,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _getColor(),
                    ),
                    FutureBuilder<Map?>(
                      future: fColorMap,
                      builder:
                          (BuildContext context, AsyncSnapshot<Map?> snapshot) {
                        if (snapshot.connectionState == ConnectionState.none) {
                          return const SizedBox.shrink();
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map? colorMap = snapshot.data;
                          String? colorHex = colorMap?['hex'];
                          String? colorName = colorMap?['name'];
                          Color? color = colorHex == null
                              ? Colors.transparent
                              : easyColor.hexToColor(colorHex);

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 90.0,
                                height: 90.0,
                                decoration: BoxDecoration(
                                  color: color,
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white60,
                                  ),
                                ),
                              ),
                              if (colorMap != null) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Your color is: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      textAlign: TextAlign.justify,
                                    ),
                                    Text(colorName ?? ''),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: _clearColor,
                                  child: const Icon(Icons.clear),
                                ),
                              ]
                            ],
                          );
                        }

                        return const SizedBox(
                          width: 90.0,
                          height: 90.0,
                          child: CircularProgressIndicator(
                            key: Key('circular_loading'),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }
            return const Center(
              child: SizedBox(
                width: 90.0,
                height: 90.0,
                child: CircularProgressIndicator(
                  key: Key('circular_loading'),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _getColor,
        tooltip: 'Search Color',
        child: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}
