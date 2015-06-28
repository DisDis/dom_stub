part of dom_stub.html_stub;

class Window extends Mock {
  static final Window _window = new Window._internal();

  factory Window() {
    return _window;
  }

  Window._internal();

  static final Mock _location = new Mock();

  Mock get location => _location;

}