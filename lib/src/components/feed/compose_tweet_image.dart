import 'dart:io';

import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';

class ComposeTweetImage extends StatelessWidget {
  const ComposeTweetImage({Key key, this.image, this.onCrossIconPressed})
      : super(key: key);

  final File image;
  final void Function() onCrossIconPressed;

  @override
  Container build(BuildContext context) => Container(
        child: image == null
            ? Container()
            : Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: 220,
                      width: fullWidth(context) * .8,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        image: DecorationImage(
                            image: FileImage(image), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.black54),
                      child: IconButton(
                        padding: const EdgeInsets.all(0),
                        iconSize: 20,
                        onPressed: onCrossIconPressed,
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  )
                ],
              ),
      );
}
