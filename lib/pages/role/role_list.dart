import 'package:cry/cry_data_table.dart';
import 'package:cry/cry_dialog.dart';
import 'package:cry/model/order_item_model.dart';
import 'package:cry/model/request_body_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin/api/role_api.dart';
import 'package:cry/cry_button.dart';
import 'package:flutter_admin/generated/l10n.dart';
import 'package:cry/model/page_model.dart';
import 'package:cry/model/response_body_api.dart';
import 'package:flutter_admin/models/role.dart';
import 'package:flutter_admin/pages/role/role_edit.dart';
import 'package:flutter_admin/pages/role/role_menu_select.dart';
import 'package:flutter_admin/pages/role/role_user_select.dart';

class RoleList extends StatefulWidget {
  RoleList({Key key}) : super(key: key);

  @override
  _RoleListState createState() => _RoleListState();
}

class _RoleListState extends State<RoleList> {
  final GlobalKey<CryDataTableState> tableKey = GlobalKey<CryDataTableState>();
  PageModel page;

  @override
  void initState() {
    super.initState();
    page = PageModel(orders: [OrderItemModel(column: 'name')]);

    WidgetsBinding.instance.addPostFrameCallback((c) {
      _query();
    });
  }

  @override
  Widget build(BuildContext context) {
    CryDataTable table = CryDataTable(
      key: tableKey,
      title: '角色管理',
      page: page,
      onPageChanged: _onPageChanged,
      onSelectChanged: (Map selected) {
        this.setState(() {});
      },
      columns: [
        DataColumn(
          label: Container(
            alignment: Alignment.center,
            child: Text('操作'),
            width: 240,
          ),
        ),
        DataColumn(
          label: Container(
            child: Text('名称'),
            width: 800,
          ),
          onSort: (int columnIndex, bool ascending) => _sort('name', ascending),
        ),
      ],
      getCells: (Map m) {
        Role role = Role.fromJson(m);
        return [
          DataCell(
            Container(
              width: 240,
              child: ButtonBar(
                children: [
                  CryButton(iconData: Icons.edit, tip: '编辑', onPressed: () => _edit(role)),
                  CryButton(iconData: Icons.delete, tip: '删除', onPressed: () => _delete([role])),
                  CryButton(iconData: Icons.person, tip: '关联人员', onPressed: () => _selectUser(role)),
                  CryButton(iconData: Icons.menu, tip: '关联菜单', onPressed: () => _selectMenu(role)),
                ],
              ),
            ),
          ),
          DataCell(Container(width: 800, child: Text(role.name ?? '--'))),
        ];
      },
    );
    List<Role> selectedList = tableKey?.currentState?.getSelectedList(page)?.map<Role>((e) => Role.fromJson(e))?.toList() ?? [];
    ButtonBar buttonBar = ButtonBar(
      alignment: MainAxisAlignment.start,
      children: <Widget>[
        CryButton(
          label: '查询',
          iconData: Icons.search,
          onPressed: () {
            _query();
          },
        ),
        CryButton(
          label: '增加',
          iconData: Icons.add,
          onPressed: () {
            _edit(null);
          },
        ),
        CryButton(
          label: '删除',
          iconData: Icons.delete,
          onPressed: selectedList.length == 0
              ? null
              : () {
                  _delete(selectedList);
                },
        ),
      ],
    );
    var result = Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
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

  _selectMenu(Role role) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => RoleMenuSelect(
          role: role,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  _selectUser(Role role) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => RoleUserSelect(
          role: role,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  _edit(Role role) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: RoleEdit(
          role: role,
        ),
      ),
    ).then((v) {
      if (v != null) {
        _query();
      }
    });
  }

  _delete(List<Role> roleList) {
    if (roleList == null || roleList.length == 0) {
      return;
    }
    cryConfirm(context, S.of(context).confirmDelete, () async {
      await RoleApi.removeByIds(roleList.map((e) => e.id).toList());
      _query();
      Navigator.of(context).pop();
    });
  }

  _query() async {
    RequestBodyApi requestBodyApi = RequestBodyApi();
    requestBodyApi.page = page;
    ResponseBodyApi responseBodyApi = await RoleApi.page(requestBodyApi.toMap());
    page = PageModel.fromMap(responseBodyApi.data);

    setState(() {});
  }

  _sort(column, ascending) {
    page.orders[0].column = column;
    page.orders[0].asc = !page.orders[0].asc;
    _query();
  }

  _onPageChanged(int size, int current) {
    page.size = size;
    page.current = current;
    _query();
  }
}
