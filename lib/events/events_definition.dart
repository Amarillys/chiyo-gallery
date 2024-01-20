import 'package:chiyo_gallery/components/custom_panel.dart';

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

class LayoutChangedEvent {
  String layoutType;
  LayoutChangedEvent(this.layoutType);
}

class ShowHiddenOptionChangedEvent {
  bool showHidden;
  ShowHiddenOptionChangedEvent(this.showHidden);
}

class ShowCustomPanelEvent {
  List<CustomOption> menuOptions;
  ShowCustomPanelEvent(this.menuOptions);
}

class HideCustomPanelEvent {
  HideCustomPanelEvent();
}

class SortTypeChangedEvent {
  String sortType;
  SortTypeChangedEvent(this.sortType);
}

class LanguageChangedEvent {
  List<String> language;
  LanguageChangedEvent(this.language);
}

buildEventFromString(String eventType, value) {
  switch (eventType) {
    case 'sortType':
      return SortTypeChangedEvent(value);
    case 'layoutType':
      return LayoutChangedEvent(value);
    case 'language':
      return LanguageChangedEvent(value);
  }
}
