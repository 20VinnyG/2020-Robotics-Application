import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrTools {

	static Future buildQrCode (BuildContext context, String qrMessage) {
		return showDialog (
			context: context,
			builder: (context) { return Dialog(child: QrImage(data: qrMessage)); }
		);
	}

	static Future buildCompressedQrCode (BuildContext context, String qrMessage) {
		List<int> stringBytes = utf8.encode(qrMessage);
		List<int> gzipBytes = new GZipEncoder().encode(stringBytes);
		String compressedString = base64.encode(gzipBytes);
		return buildQrCode(context, compressedString);
	}

	static Future<String> readQrCode () async {
		return BarcodeScanner.scan();
	}

	static Future<String> readCompressedQrCode () async {
		String qrMessage = await readQrCode();
		List<int> stringBytesDecoded = base64.decode(qrMessage);
		List<int> gzipBytesDecoded = new GZipDecoder().decodeBytes(stringBytesDecoded);
		return Utf8Codec().decode(gzipBytesDecoded);
	}

}