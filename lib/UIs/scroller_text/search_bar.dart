import 'package:flutter/material.dart';
import 'package:free_music/size.dart';

class SearchBar extends StatefulWidget {
  final Function(String) fSearch;
  const SearchBar({Key? key, required this.fSearch}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController tECsearchBar = TextEditingController();

  bool isSearchBarActive = false;
  bool isSearchBarTextActive = false;
  double marginForContainer = 9;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isSearchBarActive) {
          setState(() {
            isSearchBarActive = true;
            isSearchBarTextActive = true;
            marginForContainer = 0;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.all(marginForContainer),
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(5)),
        child: searchBar(),
      ),
    );
  }

  dynamic searchBar() {
    if (!isSearchBarActive) {
      return Center(
        child: Text(
          "Ara",
          style: Theme.of(context)
              .textTheme
              .headline6!
              .copyWith(color: Colors.white),
        ),
      );
    } else {
      return Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                marginForContainer = 9;
                isSearchBarActive = false;
                isSearchBarTextActive = false;
                FocusScope.of(context).unfocus();
              });
              widget.fSearch("ozel_admin_code:001");
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: TextField(
              onChanged: (_) {
                setState(() {
                  isSearchBarTextActive = true;
                });
              },
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                searchFun(value);
              },
              style: const TextStyle(color: Colors.white),
              controller: tECsearchBar,
              autofocus: isSearchBarTextActive,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Arama sorgusu",
                  hintStyle: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(color: Colors.white)),
            ),
          ),
          isSearchBarTextActive
              ? IconButton(
                  onPressed: () async {
                    searchFun(tECsearchBar.text);
                  },
                  icon: const Icon(
                    Icons.search_sharp,
                    color: Colors.white,
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    setState(() {
                      isSearchBarTextActive = true;
                      tECsearchBar.clear();
                    });
                    widget.fSearch("ozel_admin_code:001");
                  },
                  icon: const Icon(
                    Icons.close_sharp,
                    color: Colors.white,
                  ),
                ),
        ],
      );
    }
  }

  void searchFun(text) {
    setState(() {
      if (text.trim().isNotEmpty) {
        isSearchBarTextActive = false;
        FocusScope.of(context).unfocus();
        widget.fSearch(text);
      } else {
        tECsearchBar.clear();
      }
    });
  }
}
