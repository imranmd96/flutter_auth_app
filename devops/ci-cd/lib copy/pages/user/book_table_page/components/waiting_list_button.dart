import 'package:flutter/material.dart';

import '../constants/book_table_constants.dart';

class WaitingListButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const WaitingListButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: BookTableConstants.buttonHeight,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: BookTableConstants.accentBlue,
        borderRadius: BorderRadius.circular(BookTableConstants.borderRadius),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BookTableConstants.borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Join Waiting List',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
} 