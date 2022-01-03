import 'package:WeatherApp/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchBar extends StatefulWidget {
  final Function(String) onAdd;
  final Widget child;

  const SearchBar({Key key, this.onAdd, this.child}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final historyQueriesBox = Hive.box('history_queries');

  FloatingSearchBarController _searchBarController;

  List<String> _searchHistory = [];
  List<String> filteredSearchHistory;
  String selectedTerm = "";

  @override
  void initState() {
    super.initState();

    for(var value in historyQueriesBox.values)
      _searchHistory.add(value);

    _searchBarController = FloatingSearchBarController();
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  @override
  void dispose() {
    _searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
        controller: _searchBarController,
        backdropColor: Colors.black26,
        transition: CircularFloatingSearchBarTransition(),
        actions: [
          FloatingSearchBarAction.searchToClear(),
        ],
        onSubmitted: (query) {
          setState(() {
            addSearchTerm(query);
            selectedTerm = query;
          });

          _searchBarController.close();

          widget.onAdd?.call(selectedTerm);
        },
        automaticallyImplyBackButton: false,
        automaticallyImplyDrawerHamburger: false,
        onQueryChanged: (query) {
          setState(() {
            filteredSearchHistory = filterSearchTerms(filter: query);
          });
        },
        physics: BouncingScrollPhysics(),
        title: Text(
          selectedTerm,
          style: Theme.of(context).textTheme.headline6,
        ),
        hint: 'Search city...',
        body: widget.child ?? Container(),
        builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              elevation: 4,
              child: Builder(builder: (context) {
                if (filteredSearchHistory.isEmpty &&
                    _searchBarController.query.isEmpty) {
                  return Container(
                    height: 56,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'Start searching',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                } else if (filteredSearchHistory.isEmpty) {
                  return ListTile(
                    title: Text(_searchBarController.query),
                    leading: const Icon(Icons.search),
                    onTap: () {
                      setState(() {
                        addSearchTerm(_searchBarController.query);
                        selectedTerm = _searchBarController.query;
                      });
                      _searchBarController.close();

                      widget.onAdd?.call(selectedTerm);
                    },
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: filteredSearchHistory
                      .map(
                        (term) => ListTile(
                          title: Text(
                            term,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: const Icon(Icons.history),
                          trailing: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                deleteSearchTerm(term);
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              putSearchTermFirst(term);
                              selectedTerm = term;
                            });

                            _searchBarController.close();

                            widget.onAdd?.call(selectedTerm);

                          },
                        ),
                      )
                      .toList(),
                );
              }),
            ),
          );
        });
  }

  List<String> filterSearchTerms({
    @required String filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      // Reversed because we want the last added items to appear first in the UI
      return _searchHistory.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return _searchHistory.reversed.toList();
    }
  }

  void deleteSearchTerm(String term) {
    _searchHistory.removeWhere((t) => t == term);
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      putSearchTermFirst(term);
      return;
    }

    _searchHistory.add(term);
    historyQueriesBox.add(term);

    if (_searchHistory.length > Constants.HISTORY_LENGTH) {
      _searchHistory.removeRange(
          0, _searchHistory.length - Constants.HISTORY_LENGTH);

      for (int i = 0; i < _searchHistory.length - Constants.HISTORY_LENGTH; i++)
        historyQueriesBox.deleteAt(i);
    }
    // Changes in _searchHistory mean that we have to update the filteredSearchHistory
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }
}
