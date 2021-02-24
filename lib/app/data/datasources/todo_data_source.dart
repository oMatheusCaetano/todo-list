import 'package:todo_list/app/data/datasources/contracts/i_todo_data_source.dart';
import 'package:todo_list/app/data/models/todo_model.dart';
import 'package:todo_list/external/sqflite/query_service.dart';
import 'package:todo_list/utils/type_converter.dart' as converter;

class TodoDataSource implements ITodoDataSource {
  final String _tableName = 'todos';

  QueryService _service;

  TodoDataSource(QueryService service) {
    this._service = service;
  }

  @override
  Future<List<TodoModel>> all() async {
    final todosMaps = await this._service.all(this._tableName);
    return todosMaps
        .map((Map todo) => TodoModel.fromMap(convertFieldToRead(todo)))
        .toList();
  }

  @override
  Future<TodoModel> find(int id) async {
    final todo = await this._service.find(this._tableName, id);
    return TodoModel.fromMap(convertFieldToRead(todo));
  }

  @override
  Future<TodoModel> create(TodoModel todo) async {
    todo.id = await this
        ._service
        .create(this._tableName, this.convertFieldToInsert(todo));
    return todo;
  }

  @override
  Future<bool> update(TodoModel todo) async {
    final result = await this
        ._service
        .update(this._tableName, this.convertFieldToInsert(todo));
    return result > 0;
  }

  @override
  Future<bool> delete(int id) async {
    return await this._service.destroy(this._tableName, id) > 0;
  }

  Map<String, dynamic> convertFieldToInsert(TodoModel todo) {
    return {...todo.toMap(), 'done': converter.boolToInt(todo.done)};
  }

  Map<String, dynamic> convertFieldToRead(Map<String, dynamic> todo) {
    return {...todo, 'done': converter.intToBool(todo['done'])};
  }
}