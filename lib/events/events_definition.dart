class ChangePathEvent {
  String path;

  ChangePathEvent(this.path);
}

class PathChangedEvent {
  String path;

  PathChangedEvent(this.path);
}

class PathBackEvent {
  PathBackEvent();
}

class AddCollectionEvent {
  String collectionPath;

  AddCollectionEvent(this.collectionPath);
}

class ClearItemChooseEvent {
  ClearItemChooseEvent();
}

class ItemChooseEvent {
  List<int> itemIndexes;
  List<String> paths;
  ItemChooseEvent(this.itemIndexes, this.paths);
}

class CloseDrawerEvent {
  CloseDrawerEvent();
}

class ImageChangedEvent {
  ImageChangedEvent();
}

class PrevImageEvent {
  PrevImageEvent();
}
class NextImageEvent {
  NextImageEvent();
}