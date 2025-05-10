# adviosfinal_waterly

A SwiftUI-based iOS app for task management, daily planning, and productivity tracking, featuring a modern UI, calendar, statistics, and customizable categories.

---

## 2. Design Documentation

### Architecture Diagram

```
+-------------------+        +-------------------+        +-------------------+
|   Presentation    | <----> |     Domain        | <----> |      Data         |
| (SwiftUI Views,   |        | (Use Cases,       |        | (Repositories,    |
|  ViewModels)      |        |  Business Logic)  |        |  CoreData, Models)|
+-------------------+        +-------------------+        +-------------------+
        |                           |                              |
        | UIKit Integration         |                              |
        v                           v                              v
+-------------------+        +-------------------+        +-------------------+
|   Home, Task,     |        |  UseCases:        |        |  CoreDataStack,   |
|   Statistics,     |        |  - GetTaskStream  |        |  DefaultHomeRepo  |
|   Settings        |        |  - UpdateStatus   |        |  TaskEntity,      |
+-------------------+        +-------------------+        |  TaskModel        |
                                                          +-------------------+
```

### Data Flow Documentation

- **User Actions** (e.g., add/edit task, mark as done) are initiated in SwiftUI Views.
- **ViewModels** (e.g., `HomeViewModel`, `TaskFormViewModel`) handle state and call **Use Cases**.
- **Use Cases** (e.g., `GetTaskStreamUseCase`, `UpdateHomeTaskStatusUseCase`) encapsulate business logic and interact with **Repositories**.
- **Repositories** (e.g., `DefaultHomeRepository`) abstract data access, using **CoreData** for persistence.
- **Models** (e.g., `TaskModel`, `StatisticsModel`) are used throughout for data representation.

### API Documentation

This app does **not** use a remote API. All data is stored locally using CoreData. The main repository interface is:

- `HomeRepository`
  - `taskStream() -> AsyncThrowingStream<[TaskModel], Error>`: Streams task updates.
  - `fetch() async throws -> [TaskModel]`: Fetches all tasks.
  - `updateStatus(id: UUID, to: TaskStatus) async throws`: Updates a task's status.

---

## 3. User Documentation

### User Guide

#### Getting Started

1. **Launch the app** to see the Home screen with today's tasks and a wave gauge showing completion progress.
2. **Add a Task** by tapping the wave gauge or the "+" button.
3. **Switch Tabs** using the toolbar to view the calendar or statistics.
4. **View Task Details** by tapping a task; mark as done or edit as needed.
5. **Access Settings** from the toolbar for customization.

#### Main Screens

- **Home Screen**: Shows today's tasks, completion gauge, and quick access to add tasks.
- **Calendar Screen**: Browse tasks by date, view grouped by categories.
- **Statistics Screen**: Visualize completed vs. missed tasks with a donut chart.
- **Task Form**: Add or edit tasks, set title, date, time, category, notes, and repeat rules.
- **Settings**: Manage app preferences.

### Feature Descriptions

- **WaveGauge**: Animated gauge visualizing daily task completion.
- **Task Management**: Add, edit, delete, and mark tasks as done.
- **Calendar View**: See tasks for any date, grouped by category.
- **Statistics**: Track productivity with visual stats (done vs. missed tasks).
- **Categories**: Organize tasks with custom categories.
- **Repeat Rules**: Set tasks to repeat daily, weekly, etc.
- **Modern UI**: Dark mode, smooth animations, and intuitive navigation.