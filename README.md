# Task Manager

A task management iOS application built with SwiftUI  and Core Data to provide a seamless user experience with dynamic UI, persistent storage, and advanced accessibility features.

## Features
### Task Creation
- Add tasks with
  - Title
  - Description
  - Priority (Low, Medium, High)
  - Due date
    
### Task List
* Display tasks dynamically with:
    * Sorting options (Priority, Due Date, Alphabetical)
    * Filtering by status (All, Completed, Pending)
### Task Details
* Detailed view with options to:
    * Mark task as completed
    * Delete task
### Persistent Storage
* Save tasks locally using Core Data.
* Ensure data persistence across app restarts.

## Advanced UI Features
* Light and Dark appearances.
* Theme color customization 
* Drag-and-Drop: Reorder tasks with haptic feedback using onMove
* Swipe Gestures: Swipe-to-delete and swipe-to-complete option
* Custom Progress Indicator: Animated circular progress ring for task completion

## Installation

1. Clone the repository:

   https://github.com/janainaIOS/TaskManagerSwiftUI.git

2. Install dependencies:

   Swift Package Manager: Open the project in Xcode and resolve dependencies through File > Packages > Resolve Package Versions.

3. Open the project:
 
   TaskManager.xcodeproj
