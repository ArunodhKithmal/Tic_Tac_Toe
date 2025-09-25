import 'package:flutter/material.dart';

class BoardGrid extends StatelessWidget {
  final List<String> board;
  final void Function(int) onTap;
  const BoardGrid({super.key, required this.board, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                board[i],
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: board[i] == 'X' ? Colors.teal : Colors.red,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
