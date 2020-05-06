#pragma once

#include <optional>

template<class T, size_t size>
class lockfree_queue {
private:
  T _data[size] = {};
  size_t _wp = 0;
  size_t _rp = 0;
public:
  bool enqueue(const T& item) {
    auto wpnext = _wp + 1;
    if (wpnext >= size) {
      wpnext = 0;
    }
    if (wpnext == _rp) {
      return false;
    } else {
      _data[_wp] = item;
      _wp = wpnext;
      return true;
    }
  }
  std::optional<T> dequeue() {
    if (empty()) {
      return std::nullopt;
    } else {
      auto d = _data[_rp];
      _rp++;
      if (_rp >= size) {
        _rp = 0;
      }
      return d;
    }
  }
  bool empty() {
    return _wp == _rp;
  }
};
