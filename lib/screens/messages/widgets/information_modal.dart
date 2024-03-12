//import 'dart:async';

import 'package:flutter/material.dart';

class InformationModal extends StatefulWidget {
  const InformationModal({
    Key? key,
    required this.information,
    required this.title,
  }) : super(key: key);

  final String information;
  final String title;

  @override
  _InformationModalState createState() => _InformationModalState();
}

class _InformationModalState extends State<InformationModal> {
  final ScrollController _scrollController = ScrollController();
  late bool _showFloatingButton;

  @override
  void initState() {
    super.initState();
    _showFloatingButton = false;
    _scrollController.addListener(_calculateFloatingButtonVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateShowFloatingButton();
      // Here we check for visibility after each frame, this updates the down-arrow scroll indicator
      /*setState(() {
        _showFloatingButton = _scrollController.position.viewportDimension <
            _scrollController.position.maxScrollExtent;
      });*/
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_calculateFloatingButtonVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateFloatingButtonVisibility() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final pixels = _scrollController.position.pixels;
    final atBottom = pixels >= maxScroll;
    setState(() {
      _showFloatingButton = !_showFloatingButton || !atBottom;
    });
    debugPrint(maxScroll.toString());
    debugPrint(pixels.toString());
    debugPrint(_scrollController.position.viewportDimension.toString());
    //debugPrint(_scrollController.position.maxScrollExtent.toString());
  }

  /*void _updateShowFloatingButton() {
    setState(() {
      _showFloatingButton = _scrollController.position.viewportDimension <
          _scrollController.position.maxScrollExtent;
    });
    debugPrint(_scrollController.position.viewportDimension.toString());
    debugPrint(_scrollController.position.maxScrollExtent.toString());
  }*/

  /*void _updateShowFloatingButton() {
    Future.delayed(Duration.zero).then((value) {
      setState(() {
        _showFloatingButton = _scrollController.position.viewportDimension <
            _scrollController.position.maxScrollExtent;
      });
      debugPrint(_scrollController.position.viewportDimension.toString());
      debugPrint(_scrollController.position.maxScrollExtent.toString());
    });
  }*/

  void _updateShowFloatingButton() {
    setState(() {
      final hasExtentAfter = _scrollController.position.extentAfter > 0;
      _showFloatingButton = hasExtentAfter;
    });
    debugPrint(_scrollController.position.extentAfter.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.information),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Visibility(
                      visible: _showFloatingButton,
                      child: FloatingActionButton(
                        onPressed: () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Icon(Icons.keyboard_arrow_down),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
