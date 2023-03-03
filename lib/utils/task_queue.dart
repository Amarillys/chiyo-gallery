class TaskQueue {
  static TaskQueue? _instance;
  static int? _thread;
  int running = 0;

  factory TaskQueue(int thread) {
    _thread = thread;
    _instance ??= TaskQueue._internal(thread);
    return _instance!;
  }

  TaskQueue._internal(int thread);
  static TaskQueue get instance => _instance!;
  static int get thread => _thread!;

  static sub () {
    if (TaskQueue.instance.running > 0) {
      TaskQueue.instance.running--;
    }
  }

  static Future<void> addOrWait() async {
    if (TaskQueue.instance.running < TaskQueue.thread) {
      TaskQueue.instance.running++;
    } else {
      do {
        await Future.delayed(const Duration(milliseconds: 100));
      } while (TaskQueue.instance.running >= TaskQueue.thread);
    }
  }
}