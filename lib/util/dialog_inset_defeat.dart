 import 'package:flutter/material.dart';

/// A widget to defeat the hard coded insets of the [Dialog] class which
/// are [EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0)].
///
/// See also:
///
///  * [Dialog], for dialogs that have a message and some buttons.
///  * [showDialog], which actually displays the dialog and returns its result.
///  * <https://material.io/design/components/dialogs.html>
///  * <https://stackoverflow.com/questions/53913192/flutter-change-the-width-of-an-alertdialog>
class DialogInsetDefeat extends StatelessWidget {
  final BuildContext context;
  final Widget child;
  final deInset = EdgeInsets.symmetric(horizontal: -40, vertical: -24);
  final EdgeInsets edgeInsets;

  DialogInsetDefeat({@required this.context, @required this.child, this.edgeInsets});

  @override
  Widget build(BuildContext context) {
    var netEdgeInsets = deInset + (edgeInsets ?? EdgeInsets.zero);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(viewInsets: netEdgeInsets),
      child: child,
    );
  }
}

/// Displays a Material dialog using the above DialogInsetDefeat class.
/// Meant to be a drop-in replacement for showDialog().
///
/// See also:
///
///  * [Dialog], on which [SimpleDialog] and [AlertDialog] are based.
///  * [showDialog], which allows for customization of the dialog popup.
///  * <https://material.io/design/components/dialogs.html>
Future<T> showDialogWithInsets<T>({
  @required BuildContext context,
  bool barrierDismissible = true,
  @required WidgetBuilder builder,
  EdgeInsets edgeInsets,
}) {
  return showDialog(
    context: context,
    builder: (_) => DialogInsetDefeat(
      context: context,
      edgeInsets: edgeInsets,
      child: Builder(builder: builder),
    ),
    barrierDismissible: barrierDismissible = true,
  );
}