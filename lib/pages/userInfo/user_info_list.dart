import 'package:cry/form/cry_input.dart';
import 'package:cry/form/cry_select.dart';
import 'package:cry/model/order_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin/api/user_info_api.dart';
import 'package:cry/cry_button.dart';
import 'package:cry/cry_data_table.dart';
import 'package:flutter_admin/constants/constant_dict.dart';
import 'package:flutter_admin/generated/l10n.dart';
import 'package:cry/model/page_model.dart';
import 'package:cry/model/request_body_api.dart';
import 'package:cry/model/response_body_api.dart';
import 'package:flutter_admin/models/user_info.dart';
import 'package:flutter_admin/pages/userInfo/user_info_edit.dart';
import 'package:flutter_admin/utils/dict_util.dart';

class UserInfoList extends StatefulWidget {
  UserInfoList({Key key}) : super(key: key);

  @override
  _UserInfoListState createState() => _UserInfoListState();
}

class _UserInfoListState extends State<UserInfoList> {
  final GlobalKey<CryDataTableState> tableKey = GlobalKey<CryDataTableState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PageModel page = PageModel(orders: [OrderItemModel(column: 'update_time')]);
  UserInfo userInfo = UserInfo();

  @override
  void initState() {
    super.initState();
    _query();
  }

  @override
  Widget build(BuildContext context) {
    var form = Form(
      key: formKey,
      child: Wrap(
        children: <Widget>[
          CryInput(
            width: 400,
            label: '用户名称',
            value: userInfo.name,
            onSaved: (v) {
              userInfo.name = v;
            },
          ),
          CrySelect(
              width: 400,
              label: '部门',
              value: userInfo.deptId,
              dataList: DictUtil.getDictSelectOptionList(ConstantDict.CODE_DEPT),
              onSaved: (v) {
                userInfo.deptId = v;
              }),
        ],
      ),
    );
    CryDataTable table = CryDataTable(
      key: tableKey,
      title: '用户管理',
      page: page,
      onPageChanged: _onPageChanged,
      onSelectChanged: (Map selected) {
        this.setState(() {});
      },
      columns: [
        DataColumn(
          label: Text(S.of(context).operating),
        ),
        DataColumn(
          label: Text('账号'),
          onSort: (int columnIndex, bool ascending) => _sort('user_name'),
        ),
        DataColumn(
          label: Text(S.of(context).name),
          onSort: (int columnIndex, bool ascending) => _sort('name'),
        ),
        DataColumn(
          label: Text(S.of(context).personNickname),
          onSort: (int columnIndex, bool ascending) => _sort('nick_name'),
        ),
        DataColumn(
          label: Text(S.of(context).personGender),
          onSort: (int columnIndex, bool ascending) => _sort('gender'),
        ),
        DataColumn(
          label: Text(S.of(context).personBirthday),
          onSort: (int columnIndex, bool ascending) => _sort('birthday'),
        ),
        DataColumn(
          label: Text(S.of(context).personDepartment),
          onSort: (int columnIndex, bool ascending) => _sort('dept_id'),
        ),
        DataColumn(
          label: Text(S.of(context).creationTime),
          onSort: (int columnIndex, bool ascending) => _sort('create_time'),
        ),
        DataColumn(
          label: Text(S.of(context).updateTime),
          onSort: (int columnIndex, bool ascending) => _sort('update_time'),
        ),
      ],
      getCells: (Map m) {
        UserInfo userInfo = UserInfo.fromMap(m);
        return [
          DataCell(
            Container(
              width: 60,
              child: ButtonBar(
                children: [
                  CryButton(iconData: Icons.edit, tip: '编辑', onPressed: () => _edit(userInfo)),
                ],
              ),
            ),
          ),
          DataCell(Text(userInfo.userName ?? '--')),
          DataCell(Text(userInfo.name ?? '--')),
          DataCell(Text(userInfo.nickName ?? '--')),
          DataCell(Text(DictUtil.getDictItemName(
            userInfo.gender,
            ConstantDict.CODE_GENDER,
          ))),
          DataCell(Text(userInfo.birthday ?? '--')),
          DataCell(Text(DictUtil.getDictItemName(
            userInfo.deptId,
            ConstantDict.CODE_DEPT,
            defaultValue: '--',
          ))),
          DataCell(Text(userInfo.createTime ?? '--')),
          DataCell(Text(userInfo.updateTime ?? '--')),
        ];
      },
    );
    List<UserInfo> selectedList = tableKey?.currentState?.getSelectedList(page)?.map<UserInfo>((e) => UserInfo.fromMap(e))?.toList() ?? [];
    ButtonBar buttonBar = ButtonBar(
      alignment: MainAxisAlignment.start,
      children: <Widget>[
        CryButton(label: '查询', iconData: Icons.search, onPressed: () => _query()),
        CryButton(label: '重置', iconData: Icons.refresh, onPressed: () => _reset()),
        CryButton(label: '增加', iconData: Icons.add, onPressed: () => _edit(null)),
        CryButton(label: '编辑', iconData: Icons.edit, onPressed: selectedList.length != 1 ? null : () => _edit(selectedList[0])),
      ],
    );
    var result = Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          form,
          buttonBar,
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: <Widget>[table],
            ),
          ),
        ],
      ),
    );
    return result;
  }

  _edit(UserInfo userInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: UserInfoEdit(
          userInfo: userInfo,
        ),
      ),
    ).then((v) {
      if (v != null) {
        userInfo == null ? _sort('create_time', ascending: false) : _sort('update_time', ascending: false);
      }
    });
  }

  _reset() {
    userInfo = UserInfo();
    _loadData();
  }

  _query() {
    formKey.currentState?.save();
    _loadData();
  }

  _loadData() async {
    ResponseBodyApi responseBodyApi = await UserInfoApi.page(RequestBodyApi(page: page, params: userInfo.toMap()).toMap());
    page = PageModel.fromMap(responseBodyApi.data);

    setState(() {});
  }

  _sort(column, {ascending}) {
    page.orders[0].column = column;
    page.orders[0].asc = ascending ?? !page.orders[0].asc;
    _query();
  }

  _onPageChanged(int size, int current) {
    page.size = size;
    page.current = current;
    _query();
  }
}
