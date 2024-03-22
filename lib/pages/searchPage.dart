// import 'package:flutter/material.dart';

// class SearchPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Search'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: 10, // Replace with your actual data
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   leading: Icon(Icons.video_library),
//                   title: Text('Video Title $index'),
//                   subtitle: Text('Channel Name $index'),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
