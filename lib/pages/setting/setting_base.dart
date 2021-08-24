import 'package:cry/cry_all.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin/pages/setting/setting_default_tab.dart';

class SettingBase extends StatefulWidget {
  @override
  _SettingBaseState createState() => _SettingBaseState();
}

class _SettingBaseState extends State<SettingBase> {
  @override
  Widget build(BuildContext context) {
    var list = ExpansionPanelList.radio(
      initialOpenPanelValue: 1,
      children: [
        ExpansionPanelRadio(
          canTapOnHeader: true,
          value: 1,
          headerBuilder: (c, e) {
            return ListTile(
              title: Text("默认标签页配置"),
            );
          },
          body: SettingDefaultTab(),
          // body:d,
        ),
        ExpansionPanelRadio(
          canTapOnHeader: true,
          value: 2,
          headerBuilder: (c, e) {
            return ListTile(
              title: Text("其它配置"),
            );
          },
          body: Center(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('。。。'),
          ),),
        ),
      ],
    );
    var result = Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: list,
        ),
      ),
      floatingActionButton: CryButtons.save(context, () {}),
    );
    return result;
  }
}
