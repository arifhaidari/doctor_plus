import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:doctor_panel/widgets/pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/models.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
// import 'package:printing/printing.dart';
import '../utils/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MedicalPhotoGallery extends StatefulWidget {
  final List<MedicalRecordFileModel>? medicalRecordFileList;
  final List<ChatImageModel>? chatImageList;

  const MedicalPhotoGallery({Key? key, this.medicalRecordFileList, this.chatImageList})
      : super(key: key);

  @override
  _MedicalPhotoGalleryState createState() => _MedicalPhotoGalleryState();
}

class _MedicalPhotoGalleryState extends State<MedicalPhotoGallery> {
  @override
  void initState() {
    super.initState();
    widget.medicalRecordFileList != null ? _createMemoryImage() : null;
  }

  final List<pw.MemoryImage> _theImageList = <pw.MemoryImage>[];
  void _createMemoryImage() async {
    for (var element in widget.medicalRecordFileList!) {
      final ByteData imageData = await NetworkAssetBundle(Uri.parse(element.file!)).load("");
      final Uint8List bytes = imageData.buffer.asUint8List();
      final image = pw.MemoryImage(bytes);
      _theImageList.add(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: myAppBar(chatImageList == null ? 'Medical Photo Gallery' : 'Chat Images'),
      appBar: AppBar(
        title: Text(
          widget.chatImageList == null ? 'Medical Photo Gallery' : 'Chat Images',
          style: const TextStyle(
              fontSize: GlobalVariable.APPT_BAR_FONT_SIZE, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
        backgroundColor: Palette.imageBackground,
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.medicalRecordFileList == null
            ? widget.chatImageList!.length
            : widget.medicalRecordFileList!.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(
              widget.chatImageList == null
                  ? (widget.medicalRecordFileList![index].file ?? '')
                  : (widget.chatImageList![index].image ?? ''),
            ),

            // NetworkImage(
            //   networkRandomImage[index],
            // ),
            // Contained = the smallest possible size to fit one dimension of the screen
            minScale: PhotoViewComputedScale.contained * 0.8,
            // Covered = the smallest possible size to fit the whole screen
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        // Set the background color to the "classic white"
        backgroundDecoration: const BoxDecoration(
          color: Palette.imageBackground,
        ),
        loadingBuilder: (context, event) => Container(
          height: mQuery.height,
          width: mQuery.width,
          color: Palette.imageBackground,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(
                width: 50.0,
                height: 50.0,
                child: CircularProgressIndicator(backgroundColor: Colors.white
                    // value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes,
                    ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                'Loading',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: widget.medicalRecordFileList != null
          ? FloatingActionButton(
              onPressed: () async {
                final doc = pw.Document();
                // final ByteData imageData =
                //     await NetworkAssetBundle(Uri.parse(widget.medicalRecordFileList!.first.file!))
                //         .load("");
                // final Uint8List bytes = imageData.buffer.asUint8List();

                // final image = pw.MemoryImage(bytes);
                doc.addPage(
                  pw.MultiPage(
                      pageFormat: PdfPageFormat.a4,
                      build: (context) => _theImageList
                          .map(
                            (e) => pw.Image(e, fit: pw.BoxFit.contain),
                          )
                          .toList()),
                  // pw.Page(
                  //   pageFormat: PdfPageFormat.a4,
                  //   build: (pw.Context context) {
                  //     return pw.Center(
                  //       child: pw.Image(image, fit: pw.BoxFit.contain),
                  //     ); // Center
                  //   }),
                );
                await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
              },
              child: const Icon(Icons.print),
            )
          : null,
    );
  }
}
