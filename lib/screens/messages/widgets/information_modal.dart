import 'package:flutter/material.dart';
import 'dart:async';

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
  bool _showFloatingButton = true;
  Timer? _buttonTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_calculateFloatingButtonVisibility);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_calculateFloatingButtonVisibility);
    _scrollController.dispose();
    _buttonTimer?.cancel();
    super.dispose();
  }

  void _calculateFloatingButtonVisibility() {
    if (_buttonTimer != null && _buttonTimer!.isActive) {
      _buttonTimer!.cancel();
    }
    _buttonTimer = Timer(Duration(milliseconds: 100), () {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final pixels = _scrollController.position.pixels;
      final atBottom = pixels >= maxScroll;
      setState(() {
        _showFloatingButton = !_showFloatingButton || !atBottom;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.information),
                SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildFloatingButton(),
          ),
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

  Widget _buildFloatingButton() {
    return Visibility(
      visible: _showFloatingButton,
      child: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: Icon(Icons.keyboard_arrow_down), // Use an arrow icon
      ),
    );
  }
}
