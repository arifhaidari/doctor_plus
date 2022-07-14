import 'package:flutter/material.dart';
import '../../utils/utils.dart';

class Blog extends StatefulWidget {
  const Blog({Key? key}) : super(key: key);

  @override
  _BlogState createState() => _BlogState();
}

class _BlogState extends State<Blog> {
  @override
  Widget build(BuildContext context) {
    // final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Palette.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Blogs',
          style:
              TextStyle(fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Palette.blueAppBar,
        actions: [
          _notificationSorter(),
        ],
      ),
      body: const Center(
        child: Text(
          'Coming Soon...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  PopupMenuButton _notificationSorter() {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        // if (result != 'Clear') {
        //   setState(() {
        //     theQuery = result;
        //   });
        // } else {
        //   _remvoeAllNotes();
        // }
      },
      icon: const Icon(Icons.sort),
      color: Palette.imageBackground,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'All',
          child: Text('All'),
        ),
        const PopupMenuItem<String>(
          value: 'New',
          child: Text('New'),
        ),
        const PopupMenuItem<String>(
          value: 'Rated',
          child: Text('Rated'),
        ),
      ],
    );
  }
}
