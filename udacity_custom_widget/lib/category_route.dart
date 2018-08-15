// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'api.dart';
import 'backdrop.dart';
import 'category.dart';
import 'category_tile.dart';
import 'unit.dart';
import 'unit_converter.dart';

/// Loads in unit conversion data, and displays the data.
///
/// This is the main screen to our app. It retrieves conversion data from a
/// JSON asset and from an API. It displays the [Categories] in the back panel
/// of a [Backdrop] widget and shows the [UnitConverter] in the front panel.
///
/// While it is named CategoryRoute, a more apt name would be CategoryScreen,
/// because it is responsible for the UI at the route's destination.
class CategoryRoute extends StatefulWidget {
  const CategoryRoute();

  @override
  _CategoryRouteState createState() => _CategoryRouteState();
}

class _CategoryRouteState extends State<CategoryRoute> {
  Category _defaultCategory;
  Category _currentCategory;
  // Widgets are supposed to be deeply immutable objects. We can update and edit
  // _categories as we build our app, and when we pass it into a widget's
  // `children` property, we call .toList() on it.
  // For more details, see https://github.com/dart-lang/sdk/issues/27755
  final _categories = <Category>[];
  static const _baseColors = <ColorSwatch>[
    ColorSwatch(0xFF6AB7A8, {
      'highlight': Color(0xFF6AB7A8),
      'splash': Color(0xFF0ABC9B),
    }),
    ColorSwatch(0xFFFFD28E, {
      'highlight': Color(0xFFFFD28E),
      'splash': Color(0xFFFFA41C),
    }),
    ColorSwatch(0xFFFFB7DE, {
      'highlight': Color(0xFFFFB7DE),
      'splash': Color(0xFFF94CBF),
    }),
    ColorSwatch(0xFF8899A8, {
      'highlight': Color(0xFF8899A8),
      'splash': Color(0xFFA9CAE8),
    }),
    ColorSwatch(0xFFEAD37E, {
      'highlight': Color(0xFFEAD37E),
      'splash': Color(0xFFFFE070),
    }),
    ColorSwatch(0xFF81A56F, {
      'highlight': Color(0xFF81A56F),
      'splash': Color(0xFF7CC159),
    }),
    ColorSwatch(0xFFD7C0E2, {
      'highlight': Color(0xFFD7C0E2),
      'splash': Color(0xFFCA90E5),
    }),
    ColorSwatch(0xFFCE9A9A, {
      'highlight': Color(0xFFCE9A9A),
      'splash': Color(0xFFF94D56),
      'error': Color(0xFF912D2D),
    }),
  ];
  static const _icons = <String>[
    'assets/icons/length.png',
    'assets/icons/area.png',
    'assets/icons/volume.png',
    'assets/icons/mass.png',
    'assets/icons/time.png',
    'assets/icons/digital_storage.png',
    'assets/icons/power.png',
    'assets/icons/currency.png',
  ];

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    // We have static unit conversions located in our
    // assets/data/regular_units.json
    // and we want to also obtain up-to-date Currency conversions from the web
    // We only want to load our data in once
    if (_categories.isEmpty) {
      await _retrieveLocalCategories();
      await _retrieveApiCategory();
    }
  }

  /// Retrieves a list of [Categories] and their [Unit]s
  Future<void> _retrieveLocalCategories() async {
    // Consider omitting the types for local variables. For more details on Effective
    // Dart Usage, see https://www.dartlang.org/guides/language/effective-dart/usage
    final json = DefaultAssetBundle
        .of(context)
        .loadString('assets/data/regular_units.json');
    final data = JsonDecoder().convert(await json);
    if (data is! Map) {
      throw ('Data retrieved from API is not a Map');
    }
    var categoryIndex = 0;
    data.keys.forEach((key) {
      final List<Unit> units =
          data[key].map<Unit>((dynamic data) => Unit.fromJson(data)).toList();

      var category = Category(
        name: key,
        units: units,
        color: _baseColors[categoryIndex],
        iconLocation: _icons[categoryIndex],
      );
      setState(() {
        if (categoryIndex == 0) {
          _defaultCategory = category;
        }
        _categories.add(category);
      });
      categoryIndex += 1;
    });
  }

  /// Retrieves a [Category] and its [Unit]s from an API on the web
  Future<void> _retrieveApiCategory() async {
    // Add a placeholder while we fetch the Currency category using the API
    setState(() {
      _categories.add(Category(
        name: apiCategory['name'],
        units: [],
        color: _baseColors.last,
        iconLocation: _icons.last,
      ));
    });
    final api = Api();
    final jsonUnits = await api.getUnits(apiCategory['route']);
    // If the API errors out or we have no internet connection, this category
    // remains in placeholder mode (disabled)
    if (jsonUnits != null) {
      final units = <Unit>[];
      for (var unit in jsonUnits) {
        units.add(Unit.fromJson(unit));
      }
      setState(() {
        _categories.removeLast();
        _categories.add(Category(
          name: apiCategory['name'],
          units: units,
          color: _baseColors.last,
          iconLocation: _icons.last,
        ));
      });
    }
  }

  /// Function to call when a [Category] is tapped.
  void _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
    });
  }

  /// Makes the correct number of rows for the list view, based on whether the
  /// device is portrait or landscape.
  ///
  /// For portrait, we use a [ListView]. For landscape, we use a [GridView].
  Widget _buildCategoryWidgets(Orientation deviceOrientation) {
    if (deviceOrientation == Orientation.portrait) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          // TODO: You may want to make the Currency [Category] not tappable
          // while it is loading, or if there an error.
          var _category = _categories[index];
          return CategoryTile(
            category: _categories[index],
//            onTap: _onCategoryTap,
            onTap:
                _category.name == apiCategory['name'] && _category.units.isEmpty
                    ? null
                    : _onCategoryTap,
          );
        },
        itemCount: _categories.length,
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        children: _categories.map((Category c) {
          return CategoryTile(
            category: c,
            onTap: _onCategoryTap,
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Center(
        child: Container(
          height: 180.0,
          width: 180.0,
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Based on the device size, figure out how to best lay out the list
    // You can also use MediaQuery.of(context).size to calculate the orientation
    assert(debugCheckHasMediaQuery(context));
    final listView = Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 48.0,
      ),
      child: _buildCategoryWidgets(MediaQuery.of(context).orientation),
    );
    return Backdrop(
      currentCategory:
          _currentCategory == null ? _defaultCategory : _currentCategory,
      frontPanel: _currentCategory == null
          ? UnitConverter(category: _defaultCategory)
          : UnitConverter(category: _currentCategory),
      backPanel: listView,
      frontTitle: Text('Unit Converter'),
      backTitle: Text('Select a Category'),
    );
  }
}

//// Copyright 2018 The Chromium Authors. All rights reserved.
//// Use of this source code is governed by a BSD-style license that can be
//// found in the LICENSE file.
//
//// To keep your imports tidy, follow the ordering guidelines at
//// https://www.dartlang.org/guides/language/effective-dart/style#ordering
//import 'package:flutter/material.dart';
//import 'package:meta/meta.dart';
//
//import 'category.dart';
//
//// We use an underscore to indicate that these variables are private.
//// See https://www.dartlang.org/guides/language/effective-dart/design#libraries
//const _rowHeight = 100.0;
//final _borderRadius = BorderRadius.circular(_rowHeight / 2);
//
///// A [CategoryTile] to display a [Category].
//class CategoryTile extends StatelessWidget {
//  final Category category;
//  final ValueChanged<Category> onTap;
//
//  /// The [CategoryTile] shows the name and color of a [Category] for unit
//  /// conversions.
//  ///
//  /// Tapping on it brings you to the unit converter.
//  const CategoryTile({
//    Key key,
//    @required this.category,
//    @required this.onTap,
//  })  : assert(category != null),
//        assert(onTap != null),
//        super(key: key);
//
//  /// Builds a custom widget that shows [Category] information.
//  ///
//  /// This information includes the icon, name, and color for the [Category].
//  @override
//  // This `context` parameter describes the location of this widget in the
//  // widget tree. It can be used for obtaining Theme data from the nearest
//  // Theme ancestor in the tree. Below, we obtain the display1 text theme.
//  // See https://docs.flutter.io/flutter/material/Theme-class.html
//  Widget build(BuildContext context) {
//    return Material(
//      color: Colors.transparent,
//      child: Container(
//        height: _rowHeight,
//        child: InkWell(
//          borderRadius: _borderRadius,
//          highlightColor: category.color['highlight'],
//          splashColor: category.color['splash'],
//          // We can use either the () => function() or the () { function(); }
//          // syntax.
//          onTap: () => onTap(category),
//          child: Padding(
//            padding: EdgeInsets.all(8.0),
//            child: Row(
//              crossAxisAlignment: CrossAxisAlignment.stretch,
//              // There are two ways to denote a list: `[]` and `List()`.
//              // Prefer to use the literal syntax, i.e. `[]`, instead of `List()`.
//              // You can add the type argument if you'd like, i.e. <Widget>[].
//              // See https://www.dartlang.org/guides/language/effective-dart/usage#do-use-collection-literals-when-possible
//              children: [
//                Padding(
//                  padding: EdgeInsets.all(16.0),
//                  child: Image.asset(category.iconLocation),
//                ),
//                Center(
//                  child: Text(
//                    category.name,
//                    textAlign: TextAlign.center,
//                    style: Theme.of(context).textTheme.headline,
//                  ),
//                ),
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//}
