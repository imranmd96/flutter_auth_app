# Session Management System - Refactored Architecture

## Overview

The session management system has been refactored into a modular, maintainable architecture that separates concerns and improves code organization. The system handles automatic data clearing when browser/tab is closed, similar to banking websites.

## Architecture

### Core Components

#### 1. SessionConfig - Configuration Management
- **File**: `session_config.dart`
- **Purpose**: Centralizes all configuration constants
- **Responsibilities**:
  - Timeout durations (session, activity, heartbeat)
  - Storage keys
  - Configuration constants

#### 2. HeartbeatManager - Tab Activity Detection
- **File**: `heartbeat_manager.dart`
- **Purpose**: Manages heartbeat mechanism for detecting active tabs
- **Responsibilities**:
  - Send periodic heartbeats for current tab
  - Track active tabs across multiple browser tabs
  - Clean up stale and duplicate heartbeats
  - Count active tabs

#### 3. TabManager - Tab Identification
- **File**: `tab_manager.dart`
- **Purpose**: Manages tab identification and persistence
- **Responsibilities**:
  - Generate unique tab IDs
  - Persist tab IDs across navigations
  - Clear tab data when needed

#### 4. ActivityManager - User Activity Tracking
- **File**: `activity_manager.dart`
- **Purpose**: Manages activity tracking and timeouts
- **Responsibilities**:
  - Track last user activity
  - Check for session inactivity
  - Update activity timestamps
  - Clear activity data

#### 5. LifecycleManager - App Lifecycle Events
- **File**: `lifecycle_manager.dart`
- **Purpose**: Manages app lifecycle events
- **Responsibilities**:
  - Handle app backgrounding/foregrounding
  - Queue events during initialization
  - Process lifecycle events with timing controls
  - Manage background timers

#### 6. SessionManager - Main Orchestrator
- **File**: `session_manager_new.dart`
- **Purpose**: Main session manager that orchestrates all components
- **Responsibilities**:
  - Initialize all components
  - Coordinate between different managers
  - Handle session validation
  - Manage session state
  - Provide public API

## Key Features

### Security Features
- **Automatic Session Clearing**: Clears all authentication data when app is closed
- **Multi-Tab Detection**: Uses heartbeat mechanism to detect active tabs
- **Inactivity Timeout**: Automatically logs out after 30 minutes of inactivity
- **App Restart Detection**: Detects app restarts and clears sessions

### Performance Features
- **Lazy Initialization**: Components are initialized only when needed
- **Efficient Cleanup**: Automatic cleanup of stale data
- **Minimal Overhead**: Lightweight heartbeat mechanism (5-second intervals)

### Debug Features
- **Comprehensive Logging**: Detailed debug logs for troubleshooting
- **Session Info**: Rich debugging information about session state
- **Testing Tools**: Methods for testing session management

## Benefits of Refactoring

### Separation of Concerns
- Each manager has a single, well-defined responsibility
- Easier to understand and maintain
- Better testability

### Modularity
- Components can be tested independently
- Easy to modify individual features
- Clear interfaces between components

### Maintainability
- Smaller, focused files
- Clear naming conventions
- Comprehensive documentation

### Extensibility
- Easy to add new features
- Simple to modify existing behavior
- Clear extension points

### Debugging
- Better error isolation
- Comprehensive logging
- Rich debugging information 