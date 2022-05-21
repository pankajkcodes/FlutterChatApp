import 'package:flutter/material.dart';

showLoadingDialog(BuildContext context, String title) {
  AlertDialog loadingDialog = AlertDialog(
    content: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(
          width: 20,
        ),
        Text(title)
      ],
    ),
  );

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return loadingDialog;
      });
}

showAlertDialog(BuildContext context, String title, String content) {
  AlertDialog alertDialog = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Ok"))
    ],
  );

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return alertDialog;
      });
}
