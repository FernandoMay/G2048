// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Game2048 {
    struct GameState {
        uint256[4][4] board;
        bool isGameOver;
        bool isWon;
        uint256 score;
        uint256 highScore;
    }

    struct Achievement {
        string name;
        string description;
        bool unlocked;
    }

    mapping(address => GameState) public games;
    mapping(address => Achievement[]) public achievements;
    address[] public players;
    mapping(address => uint256) public highScores;

    event GameUpdated(address player, uint256[4][4] board, bool isGameOver, bool isWon, uint256 score);
    event AchievementUnlocked(address player, string name);
    event NewHighScore(address player, uint256 score);

    function startGame() external {
        GameState storage game = games[msg.sender];
        game.board = [[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0]];
        game.isGameOver = false;
        game.isWon = false;
        game.score = 0;
        
        // Initialize two random tiles
        addRandomTile(game);
        addRandomTile(game);

        if (achievements[msg.sender].length == 0) {
            initializeAchievements(msg.sender);
        }

        emit GameUpdated(msg.sender, game.board, game.isGameOver, game.isWon, game.score);
    }

    function makeMove(uint8 direction) external {
        require(direction <= 3, "Invalid direction");
        GameState storage game = games[msg.sender];
        require(!game.isGameOver, "Game is over");

        bool moved = false;
        uint256[4][4] memory newBoard = game.board;

        // 0: up, 1: right, 2: down, 3: left
        if (direction == 0) moved = moveUp(newBoard, game.score);
        else if (direction == 1) moved = moveRight(newBoard, game.score);
        else if (direction == 2) moved = moveDown(newBoard, game.score);
        else moved = moveLeft(newBoard, game.score);

        if (moved) {
            game.board = newBoard;
            addRandomTile(game);
            checkGameStatus(game);
            checkAchievements(msg.sender, game);
            
            if (game.score > highScores[msg.sender]) {
                highScores[msg.sender] = game.score;
                emit NewHighScore(msg.sender, game.score);
            }
        }

        emit GameUpdated(msg.sender, game.board, game.isGameOver, game.isWon, game.score);
    }

    function moveLeft(uint256[4][4] memory board, uint256 score) private pure returns (bool) {
        bool moved = false;
        for (uint i = 0; i < 4; i++) {
            uint pos = 0;
            uint lastMerged = 0;
            
            for (uint j = 0; j < 4; j++) {
                if (board[i][j] == 0) continue;
                
                if (pos > 0 && board[i][pos-1] == board[i][j] && lastMerged != pos) {
                    board[i][pos-1] *= 2;
                    score += board[i][pos-1];
                    board[i][j] = 0;
                    lastMerged = pos;
                    moved = true;
                } else {
                    if (pos != j) {
                        board[i][pos] = board[i][j];
                        board[i][j] = 0;
                        moved = true;
                    }
                    pos++;
                }
            }
        }
        return moved;
    }

    // Similar implementations for moveRight, moveUp, moveDown...

    function addRandomTile(GameState storage game) private {
        uint256[] memory emptyTiles = new uint256[](16);
        uint256 count = 0;
        
        for (uint i = 0; i < 4; i++) {
            for (uint j = 0; j < 4; j++) {
                if (game.board[i][j] == 0) {
                    emptyTiles[count] = i * 4 + j;
                    count++;
                }
            }
        }
        
        if (count > 0) {
            uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % count;
            uint256 position = emptyTiles[randomIndex];
            uint256 value = uint256(keccak256(abi.encodePacked(block.timestamp))) % 10 < 9 ? 2 : 4;
            
            game.board[position / 4][position % 4] = value;
        }
    }

    function checkGameStatus(GameState storage game) private {
        // Check for 2048 tile
        for (uint i = 0; i < 4; i++) {
            for (uint j = 0; j < 4; j++) {
                if (game.board[i][j] == 2048) {
                    game.isWon = true;
                    return;
                }
            }
        }

        // Check for available moves
        bool hasEmpty = false;
        bool canMerge = false;

        for (uint i = 0; i < 4; i++) {
            for (uint j = 0; j < 4; j++) {
                if (game.board[i][j] == 0) {
                    hasEmpty = true;
                } else if (i < 3 && game.board[i][j] == game.board[i+1][j]) {
                    canMerge = true;
                } else if (j < 3 && game.board[i][j] == game.board[i][j+1]) {
                    canMerge = true;
                }
            }
        }

        game.isGameOver = !hasEmpty && !canMerge;
    }

    function initializeAchievements(address player) private {
        achievements[player].push(Achievement("Beginner", "Score 1000 points", false));
        achievements[player].push(Achievement("Pro", "Score 10000 points", false));
        achievements[player].push(Achievement("Master", "Get the 2048 tile", false));
    }

    function checkAchievements(address player, GameState storage game) private {
        Achievement[] storage playerAchievements = achievements[player];
        
        if (!playerAchievements[0].unlocked && game.score >= 1000) {
            playerAchievements[0].unlocked = true;
            emit AchievementUnlocked(player, "Beginner");
        }
        
        if (!playerAchievements[1].unlocked && game.score >= 10000) {
            playerAchievements[1].unlocked = true;
            emit AchievementUnlocked(player, "Pro");
        }
        
        if (!playerAchievements[2].unlocked && game.isWon) {
            playerAchievements[2].unlocked = true;
            emit AchievementUnlocked(player, "Master");
        }
    }

    function getGameState() external view returns (GameState memory) {
        return games[msg.sender];
    }

    function getAchievements() external view returns (Achievement[] memory) {
        return achievements[msg.sender];
    }

    function getHighScores() external view returns (address[] memory, uint256[] memory) {
        uint256 count = players.length;
        address[] memory topPlayers = new address[](count);
        uint256[] memory scores = new uint256[](count);
        
        for (uint i = 0; i < count; i++) {
            topPlayers[i] = players[i];
            scores[i] = highScores[players[i]];
        }
        
        return (topPlayers, scores);
    }
}
