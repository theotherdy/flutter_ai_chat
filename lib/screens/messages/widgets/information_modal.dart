import 'package:flutter/material.dart';

class InformationModal extends StatefulWidget {
  const InformationModal({
    Key? key,
    required this.information,
  }) : super(key: key);

  final String information;

  @override
  _InformationModalState createState() => _InformationModalState();
}

class _InformationModalState extends State<InformationModal> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingIcon = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateFloatingIconVisibility);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateFloatingIconVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFloatingIconVisibility() {
    setState(() {
      // Check if user has scrolled more than a certain offset from the top
      _showFloatingIcon = _scrollController.position.pixels > 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget
                      .information), // Provide very long text to force overflow
                  SizedBox(height: 20), // Adding some space below the text
                ],
              ),
            ),
          ),
          if (_showFloatingIcon)
            _buildFloatingDownIcon(), // Add floating down icon
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildFloatingDownIcon() {
    return Container(
      alignment: Alignment.center,
      child: IconButton(
        icon: Icon(Icons.keyboard_arrow_down), // Use an arrow icon
        onPressed: () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}
