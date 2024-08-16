import 'dart:convert';

import 'package:selfsync_frontend/common/eventbus_events.dart';
import 'package:selfsync_frontend/common/my_custom_cache.dart';
import 'package:selfsync_frontend/feature/todos/data/todo_provider.dart';
import 'package:selfsync_frontend/feature/todos/model/todo_model.dart';
import 'package:selfsync_frontend/main.dart';

class TodoRepository {
  final MyCustomCache todoCache = MyCustomCache(
    cacheKey: 'all_todos',
    cacheDuration: 5 * 365 * 24 * 60, // 5 hours -- basically never expires
    dirPrefix: 'todos',
  );

  final MyCustomCache deletedTodosCache = MyCustomCache(
    cacheKey: 'deleted_todos',
    cacheDuration: 5 * 365 * 24 * 60, // 5 years -- basically never expires
    dirPrefix: 'todos',
  );

  List<Todo> todos = [];
  List<Todo> deletedTodos = [];

  final TodosProvider _todosprovider;
  TodoRepository(this._todosprovider);

  List<Todo> get getTodos => todos;

  Future<List<Todo>> fetchTodos() async {
    // Steps
    // 1. Fetch todos from the cache if available
    // 2. Check if there are any todos in the cache that needs to be synced
    // 3. Sync todos with the server
    // 4. Fetch todos from the server
    // 5. Save todos to the cache
    // 6. Return todos
    await syncDeletedTodos();
    await syncTodos();
    String? networkResponse = await _todosprovider.getTodos();
    List<Todo> serverTodos = [];
    if (networkResponse != null) { // null means no internet connection
      serverTodos = (jsonDecode(networkResponse) as List)
          .map((e) => Todo.fromJson(e))
          .toList();
      // Save todos to the cache
      await todoCache.writeCache(jsonEncode(serverTodos));
      todos = serverTodos;
    }
    return todos;
  }

  Future<bool> syncTodos() async {
    //clear the cache if file does not exist
    await todoCache.invalidateCacheIfFileDoesNotExist();
    await deletedTodosCache.invalidateCacheIfFileDoesNotExist();
    bool changed = false;
    // Fetch todos from the cache
    bool cacheValid = await todoCache.isCacheValid();
    if (cacheValid) {
      String? cachedTodos = await todoCache.readCache();
      if (cachedTodos != null && cachedTodos.isNotEmpty) {
        try {
          todos = [];
          jsonDecode(cachedTodos).forEach((todo) {
            todos.add(Todo.fromJson(todo));
          });
        } catch (e) {
          // invalidate the cache
          await todoCache.invalidateCache();
        }
      }
    }
    // Check if there are any todos in the cache that needs to be synced, on success update the isLocal flag to false
    if (todos.isNotEmpty) {
      List<Todo> tmpTodos = List.from(todos);
      for (var todo in tmpTodos) {
        if (todo.isLocal) {
          bool success = await _todosprovider.syncTodos(todo);
          if (success) {
            todo.isLocal = false;
            changed = true;
          }
        }
      }
      todos = tmpTodos;
    }
    syncDeletedTodos();
    return changed;
  }

  Future<void> addTodo(Todo todo) async {
    todo.isLocal = true;
    todos.add(todo);
    // Save todos to the cache
    await todoCache.writeCache(jsonEncode(todos));
    syncTodos().then((value) => {
          if (value) {eventBus.fire(TodosUpdatedEvent())}
        });
  }

  Future<void> updateTodo(Todo todo) async {
    todo.isLocal = true; // set the isLocal flag to true so that it can be synced
    // find the todo by id and update it
    todos = todos.map((e) => e.id == todo.id ? todo : e).toList();
    await todoCache.writeCache(jsonEncode(todos));

    syncTodos().then((value) => {
          if (value) {eventBus.fire(TodosUpdatedEvent())}
        });
  }

  Future<void> deleteTodo(Todo todo) async {
    // Delete todo from the server
    todos.removeWhere((element) => element.id == todo.id);
    await todoCache.writeCache(jsonEncode(todos));
    // Save the deleted todo to the cache
    //read the deleted todos from the cache
    deletedTodos = [];
    String? deletedTodosJson = await deletedTodosCache.readCache();
    if (deletedTodosJson != null && deletedTodosJson.isNotEmpty) {
      deletedTodos = (jsonDecode(deletedTodosJson) as List)
          .map((e) => Todo.fromJson(e))
          .toList();
    }
    deletedTodos.add(todo);
    await deletedTodosCache.writeCache(jsonEncode(deletedTodos));
    syncDeletedTodos();
  }
  
  Future<void> syncDeletedTodos() async {
    // Check if there are any deleted todos in the cache that needs to be synced
    if (deletedTodos.isEmpty) {
      //try to read the deleted todos from the cache
      String? deletedTodosJson = await deletedTodosCache.readCache();
      if (deletedTodosJson != null && deletedTodosJson.isNotEmpty) {
        deletedTodos = (jsonDecode(deletedTodosJson) as List)
            .map((e) => Todo.fromJson(e))
            .toList();
      }
    }
    List<Todo> failedDeletedTodos = [];
    for (var todo in deletedTodos) {
      if(!await _todosprovider.deleteTodos(todo)){
        print('Failed to delete todo with id: ${todo.id}');
        failedDeletedTodos.add(todo);
      }
    }
    deletedTodos = failedDeletedTodos;
    await deletedTodosCache.writeCache(jsonEncode(deletedTodos));
  }
}
