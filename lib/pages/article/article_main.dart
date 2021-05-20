import 'package:cry/cry_button_bar.dart';
import 'package:cry/cry_dialog.dart';
import 'package:cry/form/cry_input.dart';
import 'package:cry/form/cry_select.dart';
import 'package:cry/form/cry_select_date.dart';
import 'package:cry/routes/cry.dart';
import 'package:cry/utils/cry_utils.dart';
import 'package:flutter_admin/constants/constant_dict.dart';
import 'package:flutter_admin/generated/l10n.dart';
import 'package:flutter_admin/utils/dict_util.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:cry/cry_buttons.dart';
import 'package:cry/model/page_model.dart';
import 'package:cry/model/request_body_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin/api/article_api.dart';
import 'package:flutter_admin/models/article.dart';
import 'package:flutter_admin/pages/article/article_edit.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ArticleMain extends StatefulWidget {
  @override
  _ArticleMainState createState() => _ArticleMainState();
}

class _ArticleMainState extends State<ArticleMain> {
  ArticleDataSource ds = ArticleDataSource();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Article article = Article();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var buttonBar = CryButtonBar(
      children: [
        CryButtons.query(context, query),
        CryButtons.reset(context, reset),
        CryButtons.add(context, ds.edit),
      ],
    );
    var form = Form(
      key: formKey,
      child: Wrap(
        alignment: WrapAlignment.start,
        children: [
          CryInput(
            label: S.of(context)!.title,
            value: article.title,
            width: 400,
            onSaved: (v) {
              article.title = v;
            },
          ),
          CryInput(
            label: S.of(context)!.subTitle,
            value: article.titleSub,
            width: 400,
            onSaved: (v) {
              article.titleSub = v;
            },
          ),
          CrySelect(
            label: S.of(context)!.status,
            value: article.status,
            width: 200,
            dataList: DictUtil.getDictSelectOptionList(ConstantDict.CODE_ARTICLE_STATUS),
            onSaved: (v) {
              article.status = v;
            },
          ),
          CrySelectDate(
            context,
            label: S.of(context)!.publishTimeStart,
            value: article.publishTimeStart,
            width: 200,
            onSaved: (v) {
              article.publishTimeStart = v;
            },
          ),
          CrySelectDate(
            context,
            label: S.of(context)!.publishTimeEnd,
            value: article.publishTimeEnd,
            width: 200,
            onSaved: (v) {
              article.publishTimeEnd = v;
            },
          ),
        ],
      ),
    );
    var dataGrid = SfDataGrid(
      source: ds,
      columns: <GridColumn>[
        GridTextColumn(
          columnName: 'operation',
          label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context)!.operating,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          width: 120,
        ),
        GridTextColumn(
          columnName: 'id',
          label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              'ID',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridTextColumn(
          columnName: 'title',
          label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context)!.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          columnWidthMode: ColumnWidthMode.fill,
        ),
        GridTextColumn(
          columnName: 'titleSub',
          label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context)!.subTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        GridTextColumn(
          columnName: 'author',
          label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context)!.author,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          width: 120,
        ),
        GridTextColumn(
          columnName: 'publishTime',
          label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context)!.publishTime,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          width: 120,
        ),
        GridTextColumn(
          columnName: 'status',
          label: Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              S.of(context)!.status,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
    var pager = SfDataPagerTheme(
      data: SfDataPagerThemeData(
        brightness: Brightness.light,
        selectedItemColor: Get.theme.primaryColor,
      ),
      child: SfDataPager(
        delegate: ds,
        pageCount: 10,
        direction: Axis.horizontal,
      ),
    );
    var result = Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          form,
          buttonBar,
          Expanded(child: dataGrid),
          pager,
        ],
      ),
    );
    return result;
  }

  query() {
    formKey.currentState!.save();
    ds.loadData(params: article.toMap());
  }

  reset() async {
    article = Article();
    formKey.currentState!.reset();
    await ds.loadData(params: {});
  }
}

class ArticleDataSource extends DataGridSource {
  PageModel pageModel = PageModel();
  Map params = {};
  List<DataGridRow> _rows = [];

  loadData({Map? params}) async {
    if (params != null) {
      this.params = params;
    }
    var responseBodyApi = await ArticleApi.page(RequestBodyApi(page: pageModel, params: this.params).toMap());
    pageModel = responseBodyApi.data != null ? PageModel.fromMap(responseBodyApi.data) : PageModel();
    List<Article> list = pageModel.records!.map((element) => Article.fromMap(element as Map<String?, dynamic>)).toList();
    _rows = list.map<DataGridRow>((v) {
      return DataGridRow(cells: [
        DataGridCell(columnName: 'article', value: v),
      ]);
    }).toList(growable: false);
    notifyDataSourceListeners();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    pageModel.current = newPageIndex;
    await loadData();
    return true;
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    Article article = row.getCells()[0].value;
    return DataGridRowAdapter(cells: [
      CryButtonBar(
        children: [
          CryButtons.edit(CryUtils.context, () => edit(article: article), showLabel: false),
          CryButtons.delete(CryUtils.context, () => delete([article.id]), showLabel: false),
        ],
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.centerRight,
        child: Text(
          article.id!,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.centerRight,
        child: Text(
          article.title ?? '--',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.centerRight,
        child: Text(
          article.titleSub ?? '--',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.centerRight,
        child: Text(
          article.author ?? '--',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.centerRight,
        child: Text(
          article.publishTime ?? '--',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.centerRight,
        child: Text(
          DictUtil.getDictItemName(article.status, ConstantDict.CODE_ARTICLE_STATUS)!,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  delete(ids) async {
    cryConfirm(CryUtils.context, S.of(CryUtils.context)!.confirmDelete, (context) async {
      await ArticleApi.removeByIds(ids);
      loadData();
    });
  }

  edit({Article? article}) async {
    var result = await Cry.push(ArticleEdit(article: article));
    if (result ?? false) {
      loadData();
    }
  }
}
