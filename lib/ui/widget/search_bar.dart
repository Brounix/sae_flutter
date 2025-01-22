import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExpandableSearchBar extends StatefulWidget {
  final Function(String? orderBy, String? genre, String? platform)? onFilterChanged;

  ExpandableSearchBar({this.onFilterChanged});

  @override
  _ExpandableSearchBarState createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar> {
  bool isExpanded = false;
  String? selectedOrderBy;
  String? selectedGenre;
  String? selectedPlatform;
  List<String> genres = [];
  List<String> platforms = [];
  String? globalApiKey = '818d548ac16c461585d8de97929fa6ad';

  @override
  void initState() {
    super.initState();
    fetchGenres();
    fetchPlatforms();
  }

  Future<void> fetchGenres() async {
    final response = await http.get(Uri.parse('https://data_source.rawg.io/data_source/genres?key=$globalApiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        genres = (data['results'] as List).map((genre) => genre['name'].toString()).toList();
      });
    } else {
      print('Failed to load genres');
    }
  }

  Future<void> fetchPlatforms() async {
    final response = await http.get(Uri.parse('https://data_source.rawg.io/data_source/platforms?key=$globalApiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        platforms = (data['results'] as List).map((platform) => platform['name'].toString()).toList();
      });
    } else {
      print('Failed to load platforms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white),
                    const Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      _buildFilterOption('Order by', selectedOrderBy, ['Name', 'Released date', 'Most rated', 'Less rated'], (value) {
                        setState(() {
                          selectedOrderBy = value;
                          widget.onFilterChanged?.call(selectedOrderBy, selectedGenre, selectedPlatform);
                        });
                      }),
                      _buildDropdownFilterOption('Genre', selectedGenre, genres, (value) {
                        setState(() {
                          selectedGenre = value;
                          widget.onFilterChanged?.call(selectedOrderBy, selectedGenre, selectedPlatform);
                        });
                      }),
                      _buildDropdownFilterOption('Platform', selectedPlatform, platforms, (value) {
                        setState(() {
                          selectedPlatform = value;
                          widget.onFilterChanged?.call(selectedOrderBy, selectedGenre, selectedPlatform);
                        });
                      }),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption(String label, String? currentValue, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label :', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          DropdownButton<String?>(
            value: currentValue,
            onChanged: onChanged,
            dropdownColor: Color(0xFF2C2C2C),
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.white)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilterOption(String label, String? currentValue, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label :', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          DropdownButton<String?>(
            value: currentValue,
            onChanged: onChanged,
            dropdownColor: Color(0xFF2C2C2C),
            items: options.isNotEmpty
                ? options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.white)),
              );
            }).toList()
                : [
              DropdownMenuItem<String>(
                value: null,
                child: Text('Loading...', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
