import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:g2048/models/game_state.dart';
import 'package:g2048/providers/game_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy < -250) {
          ref.read(gameProvider.notifier).move(Direction.up);
        } else if (details.velocity.pixelsPerSecond.dy > 250) {
          ref.read(gameProvider.notifier).move(Direction.down);
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < -250) {
          ref.read(gameProvider.notifier).move(Direction.left);
        } else if (details.velocity.pixelsPerSecond.dx > 250) {
          ref.read(gameProvider.notifier).move(Direction.right);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.brown[100],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildScoreBoard(gameState),
            const SizedBox(height: 24),
            _buildGrid(gameState),
            if (gameState.status != GameStatus.playing)
              _buildGameOverlay(context, ref, gameState),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard(GameState gameState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildScoreBox('Score', gameState.score),
        _buildScoreBox('Best', gameState.highScore),
      ],
    );
  }

  Widget _buildScoreBox(String label, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.brown[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.brown[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score.toString(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.brown[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(GameState gameState) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 16,
        itemBuilder: (context, index) {
          final row = index ~/ 4;
          final col = index % 4;
          final value = gameState.board[row][col];
          return _buildTile(value);
        },
      ),
    );
  }

  Widget _buildTile(int value) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          value > 0 ? value.toString() : '',
          style: GoogleFonts.poppins(
            fontSize: value > 512 ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: value <= 4 ? Colors.brown[900] : Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 0:
        return Colors.brown[50]!;
      case 2:
        return Colors.amber[100]!;
      case 4:
        return Colors.amber[200]!;
      case 8:
        return Colors.orange[300]!;
      case 16:
        return Colors.orange[400]!;
      case 32:
        return Colors.deepOrange[400]!;
      case 64:
        return Colors.deepOrange[600]!;
      case 128:
        return Colors.red[400]!;
      case 256:
        return Colors.red[600]!;
      case 512:
        return Colors.pink[400]!;
      case 1024:
        return Colors.pink[600]!;
      case 2048:
        return Colors.purple[400]!;
      default:
        return Colors.purple[800]!;
    }
  }

  Widget _buildGameOverlay(BuildContext context, WidgetRef ref, GameState gameState) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            gameState.status == GameStatus.won ? '🎉 You Won! 🎉' : '😢 Game Over',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Score: ${gameState.score}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(gameProvider.notifier).resetGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Play Again',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
