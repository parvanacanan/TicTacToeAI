//
//  GameEngine.swift
//  tictactoeAI
//
//  Created by parvana on 30.11.25.
//
 

import Foundation

enum Player {
    case x
    case o
    
    var symbol: String {
        switch self {
        case .x: return "X"
        case .o: return "O"
        }
    }
    
    var opposite: Player {
        switch self {
        case .x: return .o
        case .o: return .x
        }
    }
}

struct Move {
    let row: Int
    let col: Int
}

class GameEngine {
    private var board: [[Player?]]
    let size: Int
    let winLength: Int
    var currentPlayer: Player
    
    init(size: Int = 3, winLength: Int = 3) {
        self.size = size
        self.winLength = winLength
        self.board = Array(repeating: Array(repeating: nil, count: size), count: size)
        self.currentPlayer = .x
    }
    
    // Hamle etmek üçün
    func makeMove(row: Int, col: Int) -> Bool {
        guard row >= 0 && row < size && col >= 0 && col < size else { return false }
        guard board[row][col] == nil else { return false }
        
        board[row][col] = currentPlayer
        currentPlayer = currentPlayer.opposite
        return true
    }
    
    // Boş hüceyrələri tapmaq
    func availableMoves() -> [Move] {
        var moves: [Move] = []
        for row in 0..<size {
            for col in 0..<size {
                if board[row][col] == nil {
                    moves.append(Move(row: row, col: col))
                }
            }
        }
        return moves
    }
    
    // Qalib kimdir?
    func checkWinner() -> Player? {
        // Sətirləri yoxla
        for row in 0..<size {
            for col in 0...(size - winLength) {
                if let player = board[row][col] {
                    var win = true
                    for offset in 0..<winLength {
                        if board[row][col + offset] != player {
                            win = false
                            break
                        }
                    }
                    if win { return player }
                }
            }
        }
        
        // Sütunları yoxla
        for col in 0..<size {
            for row in 0...(size - winLength) {
                if let player = board[row][col] {
                    var win = true
                    for offset in 0..<winLength {
                        if board[row + offset][col] != player {
                            win = false
                            break
                        }
                    }
                    if win { return player }
                }
            }
        }
        
        // Diaqonalları yoxla (\)
        for row in 0...(size - winLength) {
            for col in 0...(size - winLength) {
                if let player = board[row][col] {
                    var win = true
                    for offset in 0..<winLength {
                        if board[row + offset][col + offset] != player {
                            win = false
                            break
                        }
                    }
                    if win { return player }
                }
            }
        }
        
        // Əks diaqonalları yoxla (/)
        for row in 0...(size - winLength) {
            for col in (winLength - 1)..<size {
                if let player = board[row][col] {
                    var win = true
                    for offset in 0..<winLength {
                        if board[row + offset][col - offset] != player {
                            win = false
                            break
                        }
                    }
                    if win { return player }
                }
            }
        }
        
        return nil
    }
    
    // Oyun bitib?
    func isTerminal() -> Bool {
        return checkWinner() != nil || availableMoves().isEmpty
    }
    
    // X üçün utility (Minimax üçün)
    func utility() -> Int {
        if let winner = checkWinner() {
            return winner == .x ? 1 : -1
        }
        return 0 // Heç-heçə
    }
    
    // Board statusunu almaq
    func getBoard() -> [[Player?]] {
        return board
    }
    
    // Boardu sıfırlamaq
    func reset() {
        board = Array(repeating: Array(repeating: nil, count: size), count: size)
        currentPlayer = .x
    }
    
    // Test üçün: Boardu print etmek
    func printBoard() {
        for row in board {
            let rowString = row.map { $0?.symbol ?? "." }.joined(separator: " ")
            print(rowString)
        }
        print()
    }
}
