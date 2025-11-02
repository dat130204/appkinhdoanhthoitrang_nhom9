import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final int rating;
  final Function(int)? onRatingChanged;
  final double size;
  final bool readOnly;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    Key? key,
    required this.rating,
    this.onRatingChanged,
    this.size = 24.0,
    this.readOnly = false,
    this.activeColor = const Color(0xFFFFB800),
    this.inactiveColor = const Color(0xFFE0E0E0),
  }) : super(key: key);

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  void didUpdateWidget(StarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rating != oldWidget.rating) {
      _currentRating = widget.rating;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        return GestureDetector(
          onTap: widget.readOnly
              ? null
              : () {
                  setState(() {
                    _currentRating = starNumber;
                  });
                  widget.onRatingChanged?.call(starNumber);
                },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
            child: Icon(
              starNumber <= _currentRating ? Icons.star : Icons.star_border,
              size: widget.size,
              color: starNumber <= _currentRating
                  ? widget.activeColor
                  : widget.inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}

class StaticStarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool showRating;
  final TextStyle? ratingTextStyle;

  const StaticStarRating({
    Key? key,
    required this.rating,
    this.size = 16.0,
    this.activeColor = const Color(0xFFFFB800),
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.showRating = false,
    this.ratingTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starNumber = index + 1;
          IconData iconData;
          Color color;

          if (rating >= starNumber) {
            iconData = Icons.star;
            color = activeColor;
          } else if (rating >= starNumber - 0.5) {
            iconData = Icons.star_half;
            color = activeColor;
          } else {
            iconData = Icons.star_border;
            color = inactiveColor;
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.05),
            child: Icon(
              iconData,
              size: size,
              color: color,
            ),
          );
        }),
        if (showRating) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: ratingTextStyle ??
                TextStyle(
                  fontSize: size * 0.8,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
          ),
        ],
      ],
    );
  }
}

class CompactStarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;

  const CompactStarRating({
    Key? key,
    required this.rating,
    this.reviewCount = 0,
    this.size = 14.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: size,
          color: const Color(0xFFFFB800),
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.9,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.85,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }
}
