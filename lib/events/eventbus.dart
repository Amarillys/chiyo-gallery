import 'package:event_bus/event_bus.dart';

class GlobalEventBus {
  static final _instance = _getInstance();

  static EventBus _getInstance() {
    return EventBus();
  }

  static EventBus get instance => _instance;
}