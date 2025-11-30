//
//  AIManager.swift
//  tictactoeAI
//
//  Created by parvana on 30.11.25.
//

import Foundation

class AIManager {
    private var nodesEvaluated = 0
    
    // Simple Minimax
    func minimax(_ engine: GameEngine, depth: Int, isMaximizing: Bool) -> Int {
        nodesEvaluated += 1
        
        if engine.isTerminal() || depth == 0 {
            return engine.utility()
        }
        
        if isMaximizing {
            var maxEval = Int.min
            for move in engine.availableMoves() {
                let newEngine = copyGameEngine(engine)
                _ = newEngine.makeMove(row: move.row, col: move.col)
                let eval = minimax(newEngine, depth: depth - 1, isMaximizing: false)
                maxEval = max(maxEval, eval)
            }
            return maxEval
        } else {
            var minEval = Int.max
            for move in engine.availableMoves() {
                let newEngine = copyGameEngine(engine)
                _ = newEngine.makeMove(row: move.row, col: move.col)
                let eval = minimax(newEngine, depth: depth - 1, isMaximizing: true)
                minEval = min(minEval, eval)
            }
            return minEval
        }
    }
    
    // Alpha-Beta Pruning ilə Minimax
    func minimaxWithAlphaBeta(_ engine: GameEngine, depth: Int, alpha: Int, beta: Int, isMaximizing: Bool) -> Int {
        nodesEvaluated += 1
        
        if engine.isTerminal() || depth == 0 {
            return engine.utility()
        }
        
        var alpha = alpha
        var beta = beta
        
        if isMaximizing {
            var maxEval = Int.min
            for move in engine.availableMoves() {
                let newEngine = copyGameEngine(engine)
                _ = newEngine.makeMove(row: move.row, col: move.col)
                let eval = minimaxWithAlphaBeta(newEngine, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: false)
                maxEval = max(maxEval, eval)
                alpha = max(alpha, eval)
                if beta <= alpha {
                    break // Beta cut-off
                }
            }
            return maxEval
        } else {
            var minEval = Int.max
            for move in engine.availableMoves() {
                let newEngine = copyGameEngine(engine)
                _ = newEngine.makeMove(row: move.row, col: move.col)
                let eval = minimaxWithAlphaBeta(newEngine, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: true)
                minEval = min(minEval, eval)
                beta = min(beta, eval)
                if beta <= alpha {
                    break // Alpha cut-off
                }
            }
            return minEval
        }
    }
    
    // Ən yaxşı hamləni tapmaq
    func findBestMove(_ engine: GameEngine, useAlphaBeta: Bool = true) -> Move? {
        nodesEvaluated = 0
        let availableMoves = engine.availableMoves()
        
        guard !availableMoves.isEmpty else { return nil }
        
        var bestMove: Move?
        var bestValue = engine.currentPlayer == .x ? Int.min : Int.max
        
        for move in availableMoves {
            let newEngine = copyGameEngine(engine)
            _ = newEngine.makeMove(row: move.row, col: move.col)
            
            let moveValue: Int
            if useAlphaBeta {
                moveValue = minimaxWithAlphaBeta(
                    newEngine,
                    depth: getSearchDepth(for: engine.size),
                    alpha: Int.min,
                    beta: Int.max,
                    isMaximizing: engine.currentPlayer == .o // Çünki hamle etdikdə növbə dəyişir
                )
            } else {
                moveValue = minimax(
                    newEngine,
                    depth: getSearchDepth(for: engine.size),
                    isMaximizing: engine.currentPlayer == .o
                )
            }
            
            if engine.currentPlayer == .x {
                if moveValue > bestValue {
                    bestValue = moveValue
                    bestMove = move
                }
            } else {
                if moveValue < bestValue {
                    bestValue = moveValue
                    bestMove = move
                }
            }
        }
        
        print("AI evaluated \(nodesEvaluated) nodes")
        return bestMove
    }
    
    private func getSearchDepth(for boardSize: Int) -> Int {
        switch boardSize {
        case 3: return 9 // 3x3 üçün tam axtarış
        case 4: return 5 // 4x4 üçün məhdud dərinlik
        case 5: return 4 // 5x5 üçün daha da məhdud
        default: return 3
        }
    }
    
    private func copyGameEngine(_ engine: GameEngine) -> GameEngine {
        let newEngine = GameEngine(size: engine.size, winLength: engine.winLength)
        // Board state-i kopyala
        for row in 0..<engine.size {
            for col in 0..<engine.size {
                if let player = engine.getBoard()[row][col] {
                    _ = newEngine.makeMove(row: row, col: col)
                    // Current player-i düzəlt
                    newEngine.currentPlayer = engine.currentPlayer
                }
            }
        }
        return newEngine
    }
    
}
