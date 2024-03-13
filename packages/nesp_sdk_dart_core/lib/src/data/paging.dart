/*
 * Copyright (c) 2023-2023. NESP Technology.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); 
 * you may not use this file except in compliance with the License. You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License 
 * for the specific language governing permissions and limitations under the License.
 *
 */

typedef OnPageNumberChangedListener = Function(
    int currentPageNumber, int pageCount);

/// Pagination component
///
/// [T] data type
class Paging<T> {
  Paging(this.pageDataSize);

  factory Paging.shrink() => Paging(0);

  bool _needNotify = true;

  final List<T> _data = [];

  List<T> get currentPageData => List.unmodifiable(_data);

  int pageDataSize = 1;
  OnPageNumberChangedListener? onPageNumberChangedListener;

  bool get isEmpty => _data.isEmpty;

  bool get isNotEmpty => _data.isNotEmpty;

  int _totalDataSize = 0;

  set totalDataSize(int value) {
    _totalDataSize = value;
    totalPageCount = calculateTotalPageCount2(value, pageDataSize);
    if (value > 0 && currentPageNumber <= 0) {
      _needNotify = false;
      firstPage();
    }
  }

  int get totalDataSize => _totalDataSize;

  int _currentPageNumber = 0;

  /// The current page number, starting from 0
  int get currentPageNumber => _currentPageNumber;

  set currentPageNumber(int value) {
    _currentPageNumber = value;
    _notifyOnPageNumberChanged();
  }

  /// The amount of current page data that is low than or equals [pageDataSize]
  int get currentPageDataSize => _data.length;

  int _totalPageCount = 0;

  /// Total number of pages
  int get totalPageCount => _totalPageCount;

  set totalPageCount(int value) {
    _totalPageCount = value;
    if (isLastPage) {
      _needNotify = false;
      lastPage();
    }
  }

  /// Whether it is the first page
  bool get isFirstPage => currentPageNumber <= 0;

  /// Navigate to the first page
  void firstPage() => currentPageNumber = 0;

  /// Whether it is the last page
  bool get isLastPage => currentPageNumber >= totalPageCount - 1;

  /// Navigate to the last page
  void lastPage() => currentPageNumber = totalPageCount - 1;

  /// Is there a previous page
  bool get hasPreviousPage => currentPageNumber > 0;

  /// Navigate to the previous page and do nothing if the previous page does not exist
  void previous() {
    if (hasPreviousPage) {
      currentPageNumber--;
    }
  }

  /// Is there a next page
  bool get hasNextPage => currentPageNumber < totalPageCount - 1;

  /// Navigate to the next page and do nothing if the next page does not exist
  void next() {
    if (hasNextPage) {
      currentPageNumber++;
    }
  }

  /// Clears all content of the current page
  void clear() => _data.clear();

  void addAll(Iterable<T> elements) => _data.addAll(elements);

  void add(T element) => _data.add(element);

  T operator [](int index) => _data[index];

  void operator []=(int index, T element) => _data[index] = element;

  void insert(int index, T element) => _data.insert(index, element);

  bool get isShrink => pageDataSize <= 0;

  /// Gets the total number of pages
  ///
  /// [totalDataSize] Total data volume
  /// [pageDataSize] Maximum amount of data per page
  static int calculateTotalPageCount(int totalDataSize, int pageDataSize) {
    return totalDataSize % pageDataSize == 0
        ? totalDataSize ~/ pageDataSize
        : totalDataSize ~/ pageDataSize + 1;
  }

  /// Gets the total number of pages
  ///
  /// [totalDataSize] Total data volume
  /// [pageDataSize] Maximum amount of data per page
  static int calculateTotalPageCount2(int totalDataSize, int pageDataSize) {
    return (totalDataSize + pageDataSize - 1) ~/ pageDataSize;
  }

  /// Gets the total number of pages
  ///
  /// [totalDataSize] Total data volume
  /// [pageDataSize] Maximum amount of data per page
  static int calculateTotalPageCount3(int totalDataSize, int pageDataSize) {
    return (totalDataSize.toDouble() / pageDataSize.toDouble()).ceil();
  }

  void _notifyOnPageNumberChanged() {
    if (!_needNotify) {
      _needNotify = true;
      return;
    }
    onPageNumberChangedListener?.call(currentPageNumber, pageDataSize);
  }
}
