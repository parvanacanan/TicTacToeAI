//
//  ViewController.swift
//  tictactoeAI
//
//  Created by parvana on 30.11.25.
 
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    private var gameEngine: GameEngine!
    private var aiManager: AIManager!
    
    // UI Components
    private let mainStackView = UIStackView()
    private let statusLabel = UILabel()
    private let boardStackView = UIStackView()
    private let resetButton = UIButton()
    private var buttons: [UIButton] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupGame() {
        gameEngine = GameEngine(size: 3, winLength: 3)
        aiManager = AIManager()
        updateStatus()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Main Stack View
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        // Status Label
        statusLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        statusLabel.textAlignment = .center
        statusLabel.text = "X-in növbəsi"
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(statusLabel)
        
        // Board Stack View (3x3 grid)
        setupBoard()
        
        // Reset Button
        resetButton.setTitle("Yeni Oyun", for: .normal)
        resetButton.backgroundColor = .systemBlue
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        resetButton.layer.cornerRadius = 10
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(resetButton)
        
        // Button sizes
        NSLayoutConstraint.activate([
            statusLabel.heightAnchor.constraint(equalToConstant: 40),
            resetButton.widthAnchor.constraint(equalToConstant: 200),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupBoard() {
        boardStackView.axis = .vertical
        boardStackView.distribution = .fillEqually
        boardStackView.spacing = 5
        boardStackView.translatesAutoresizingMaskIntoConstraints = false
        
        for row in 0..<3 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 5
            
            for col in 0..<3 {
                let button = UIButton(type: .system)
                button.backgroundColor = .systemGray6
                button.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .bold)
                button.tag = row * 3 + col
                button.addTarget(self, action: #selector(cellTapped(_:)), for: .touchUpInside)
                
                // Button size
                button.translatesAutoresizingMaskIntoConstraints = false
                button.widthAnchor.constraint(equalToConstant: 80).isActive = true
                button.heightAnchor.constraint(equalToConstant: 80).isActive = true
                
                rowStack.addArrangedSubview(button)
                buttons.append(button)
            }
            
            boardStackView.addArrangedSubview(rowStack)
        }
        
        // Board size
        boardStackView.translatesAutoresizingMaskIntoConstraints = false
        boardStackView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        boardStackView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        mainStackView.addArrangedSubview(boardStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Main stack view center
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Board size
            boardStackView.widthAnchor.constraint(equalToConstant: 250),
            boardStackView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    // MARK: - Actions
    @objc private func cellTapped(_ sender: UIButton) {
        let tag = sender.tag
        let row = tag / 3
        let col = tag % 3
        
        // İnsan hamlesi
        if gameEngine.makeMove(row: row, col: col) {
            updateBoardUI()
            
            // AI hamlesi
            if !gameEngine.isTerminal() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.makeAIMove()
                }
            }
        }
    }
    
    @objc private func resetButtonTapped() {
        gameEngine.reset()
        updateBoardUI()
        updateStatus()
    }
    
    // MARK: - Game Logic
    private func makeAIMove() {
        if let bestMove = aiManager.findBestMove(gameEngine) {
            _ = gameEngine.makeMove(row: bestMove.row, col: bestMove.col)
            updateBoardUI()
        }
    }
    
    private func updateBoardUI() {
        let board = gameEngine.getBoard()
        
        for row in 0..<3 {
            for col in 0..<3 {
                let index = row * 3 + col
                let button = buttons[index]
                
                if let player = board[row][col] {
                    button.setTitle(player.symbol, for: .normal)
                    button.isEnabled = false
                    button.backgroundColor = player == .x ? .systemBlue : .systemRed
                    button.setTitleColor(.white, for: .normal)
                } else {
                    button.setTitle("", for: .normal)
                    button.isEnabled = true
                    button.backgroundColor = .systemGray6
                }
            }
        }
        
        updateStatus()
    }
    
    private func updateStatus() {
        if let winner = gameEngine.checkWinner() {
            statusLabel.text = "🎉 \(winner.symbol) qalibdir!"
            disableAllButtons()
        } else if gameEngine.isTerminal() {
            statusLabel.text = "🤝 Heç-heçə!"
            disableAllButtons()
        } else {
            let currentPlayerSymbol = gameEngine.currentPlayer.symbol
            statusLabel.text = "Növbə: \(currentPlayerSymbol)"
        }
    }
    
    private func disableAllButtons() {
        for button in buttons {
            button.isEnabled = false
        }
    }
}
