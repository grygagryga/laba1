import 'TaskClass.dart';
import 'Menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchState();
}

class _BranchState extends State<BranchScreen> {
  List<Task> _Tasks = [];
  List<Task> _visibleTasks = [];
  bool _onlyFavorite = false;
  bool _hideDone = false;
  String _title = 'Учeба';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        title: Text(_title),
        actions: [EditButton()],
      ),
      body: _TaskList(_visibleTasks),
      backgroundColor: Colors.lightBlue,
      floatingActionButton: _buildAddTaskFab(_Tasks),
    );
  }

  List<Task> _visibleTasksConstructor(
      {required List<Task> tasks,
      required bool onlyFavorite,
      required bool isDone}) {
    List<Task> out = [];
    out.addAll(tasks);
    if (onlyFavorite) {
      out.removeWhere((task) => !task.isFavorite);
    }
    if (_hideDone) {
      out.removeWhere((task) => task.isDone);
    }
    return out;
  }

  Widget _buildAddTaskFab(List tasks) {
    return FloatingActionButton(
      onPressed: () => _showCreateTaskDialog(context),
      backgroundColor: Colors.greenAccent ,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _showCreateTaskDialog(BuildContext context) {
    late String text;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Создать задачу'),
          actions: <Widget>[
            Form(child: Builder(builder: (context) {
              return Column(children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Название не может быть пустым';
                    }
                    if (value.length > 40) {
                      return "Название слишком длинное";
                    }
                    return null;
                  },
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  maxLength: 40,
                  decoration: InputDecoration(
                    labelText: 'Введите название задачи',
                  ),
                  onChanged: (String value) {
                    text = value;
                  },
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Отмена'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Ок'),
                    onPressed: () {
                      if (Form.of(context).validate()) {
                        final newTask = Task(title: text, id: _Tasks.length);
                        setState(() {
                          _Tasks.add(newTask);
                          if (!_onlyFavorite) {
                            _visibleTasks.add(newTask);
                          }
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ]),
              ]);
            }))
          ],
        );
      },
    );
  }

  Widget _taskCard({required List tasks, required int index}) {
    return Padding(
      padding: EdgeInsets.all(6.0),
      child: Dismissible(
        background: Container(
          color: Colors.red,
          child: Container(
              margin: EdgeInsets.only(left: 320.0),
              child: Icon(Icons.delete_forever)),
        ),
        key: ValueKey<int>(tasks[index].id),
        onDismissed: (DismissDirection direction) {
          setState(() {
            _Tasks.remove(tasks[index]);
            _visibleTasks.remove(tasks[index]);
          });
        },
        direction: DismissDirection.endToStart,
        child: CheckboxListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
          checkboxShape: CircleBorder(),
          tileColor: Colors.white,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(tasks[index].title),
          value: tasks[index].isDone,
          onChanged: (bool? value) {
            setState(() {
              tasks[index].isDone = !tasks[index].isDone;
            });
          },
          secondary: IconButton(
            iconSize: 30,
            color: Colors.amber,
            isSelected: tasks[index].isFavorite,
            icon: const Icon(
              Icons.star_border,
            ),
            selectedIcon: const Icon(
              Icons.star,
            ),
            onPressed: () {
              setState(() {
                tasks[index].isFavorite = !tasks[index].isFavorite;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget _TaskList(List<Task> tasks) {
    if (tasks.length != 0) {
      return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return _taskCard(tasks: tasks, index: index);
          });
    } else {
      return _taskListBackground();
    }
  }

  Widget _taskListBackground() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              SvgPicture.asset('assets/todolist_background.svg'),
              SvgPicture.asset('assets/todolist.svg'),
            ],
          ),
          const Text(
            'На данный момент задачи отсутствуют',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteCompletedConfirmationDialog(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Подтвердите удаление'),
              content:
                  Text("Удалить выполненные задачи? Это действие необратимо."),
              actions: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Отмена'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Ок'),
                    onPressed: () {
                      _Tasks.removeWhere((task) => task.isDone);
                      _visibleTasks.removeWhere((task) => task.isDone);
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                  )
                ]),
              ]);
        });
  }

  Future<void> _showEditBranchTitleDialog(BuildContext context) {
    late String text;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Редактировать ветку'),
          actions: <Widget>[
            Form(child: Builder(builder: (context) {
              return Column(children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Название не может быть пустым';
                    }
                    if (value.length > 40) {
                      return "Название слишком длинное";
                    }
                    return null;
                  },
                  maxLengthEnforcement: MaxLengthEnforcement.none,
                  maxLength: 40,
                  decoration: InputDecoration(
                    labelText: 'Введите название ветки',
                  ),
                  onChanged: (String value) {
                    text = value;
                  },
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Отмена'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Ок'),
                    onPressed: () {
                      if (Form.of(context).validate()) {
                        setState(() {
                          _title = text;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ]),
              ]);
            }))
          ],
        );
      },
    );
  }

  @override
  Widget EditButton() {
    List<String> _hideDoneButtonText = [
      'Скрыть выполненные',
      'Показать выполненные'
    ];
    List<String> _onlyFavoriteButtonText = ['Только избранные', 'Показать все'];
    List<IconData> _hideDoneButtonIcon = [
      Icons.check_circle,
      Icons.check_circle_outline
    ];
    List<IconData> _onlyFavoriteButtonIcon = [Icons.star, Icons.star_border];

    return PopupMenuButton<Menu>(
        onSelected: (Menu item) {
          if (item == Menu.hideDone) {
            setState(() {
              _hideDone = !_hideDone;
              _visibleTasks = _visibleTasksConstructor(
                  tasks: _Tasks,
                  onlyFavorite: _onlyFavorite,
                  isDone: _hideDone);
            });
          }
          if (item == Menu.onlyFavorite) {
            setState(() {
              _onlyFavorite = !_onlyFavorite;
              _visibleTasks = _visibleTasksConstructor(
                  tasks: _Tasks,
                  onlyFavorite: _onlyFavorite,
                  isDone: _hideDone);
            });
          }
          if (item == Menu.deleteDone) {
            _showDeleteCompletedConfirmationDialog(context);
          }
          if (item == Menu.editThread) {
            _showEditBranchTitleDialog(context);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(
                  value: Menu.hideDone,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    leading: Icon(_hideDoneButtonIcon[_hideDone ? 1 : 0]),
                    title: Text(_hideDoneButtonText[_hideDone ? 1 : 0]),
                  )),
              PopupMenuItem<Menu>(
                value: Menu.onlyFavorite,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  leading: Icon(_onlyFavoriteButtonIcon[_onlyFavorite ? 1 : 0]),
                  title: Text(_onlyFavoriteButtonText[_onlyFavorite ? 1 : 0]),
                ),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.deleteDone,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  leading: Icon(Icons.delete_forever),
                  title: Text('Удалить выполненные'),
                ),
              ),
              const PopupMenuItem<Menu>(
                value: Menu.editThread,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  leading: Icon(Icons.edit),
                  title: Text('Редактировать ветку'),
                ),
              ),
            ]);
  }
}
