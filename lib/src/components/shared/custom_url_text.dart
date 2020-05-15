import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instafram/src/helpers/utilities.dart';

class CustomUrlText extends StatelessWidget {
  const CustomUrlText({
    this.text,
    this.style,
    this.urlStyle,
    this.onHashTagPressed,
  });

  final String text;
  final TextStyle style;
  final TextStyle urlStyle;
  final Function(String) onHashTagPressed;

  List<InlineSpan> getTextSpans() {
    final List<InlineSpan> widgets = <InlineSpan>[];
    final RegExp reg = RegExp(
        r'([#])\w+| [@]\w+|(https?|ftp|file|#)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]*');
    final Iterable<RegExpMatch> _matches = reg.allMatches(text);
    final List<_ResultMatch> resultMatches = <_ResultMatch>[];
    int start = 0;
    for (final Match match in _matches) {
      if (match.group(0).isNotEmpty) {
        if (start != match.start) {
          final _ResultMatch result1 = _ResultMatch();
          result1.isUrl = false;
          result1.text = text.substring(start, match.start);
          resultMatches.add(result1);
        }

        final _ResultMatch result2 = _ResultMatch();
        result2.isUrl = true;
        result2.text = match.group(0);
        resultMatches.add(result2);
        start = match.end;
      }
    }
    if (start < text.length) {
      final _ResultMatch result1 = _ResultMatch();
      result1.isUrl = false;
      result1.text = text.substring(start);
      resultMatches.add(result1);
    }
    for (final _ResultMatch result in resultMatches) {
      if (result.isUrl) {
        widgets.add(_LinkTextSpan(
            onHashTagPressed: onHashTagPressed,
            text: result.text,
            style: urlStyle ?? TextStyle(color: Colors.blue)));
      } else {
        widgets.add(TextSpan(
            text: result.text, style: style ?? TextStyle(color: Colors.black)));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: getTextSpans()),
    );
  }
}

class _LinkTextSpan extends TextSpan {
  _LinkTextSpan({TextStyle style, String text, this.onHashTagPressed})
      : super(
            style: style,
            text: text,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (onHashTagPressed != null &&
                    (text.substring(0, 1).contains('#') ||
                        text.substring(0, 1).contains('#'))) {
                  onHashTagPressed(text);
                } else {
                  launchURL(text);
                }
              });

  final Function(String) onHashTagPressed;
}

class _ResultMatch {
  bool isUrl;
  String text;
}
