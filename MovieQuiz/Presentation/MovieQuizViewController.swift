import UIKit


struct ViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}



final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var alertPresenter = AlertPresenter()
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
        alertPresenter.mainController = self
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.currentQuestion = question
            self?.showCurrentQuestion()
        }
    }
    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: Any) {
        handleUserAnswer(answer: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        handleUserAnswer(answer: true)
    }
    
    // MARK: - Private functions
    private func handleUserAnswer(answer: Bool) {
        guard let question = currentQuestion else { return }
        
        let isCorrect = question.correctAnswer == answer

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor =  isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        correctAnswers = isCorrect ? correctAnswers + 1 : correctAnswers
        
        self.disableOrEnableButtons(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.disableOrEnableButtons(isEnabled: true)
        }
    }
    
    private func showCurrentQuestion() {
        guard let question = currentQuestion else { return }
        let step = convert(model: question)
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let alert = AlertModel(
                title: "Игра окончена.",
                message: "Ваш результат: \(correctAnswers)/\(questionsAmount).",
                buttonText: "Сыграем еще раз?") { [weak self] _ in
                    guard let self = self else { return }
                    self.correctAnswers = 0
                    self.currentQuestionIndex = 0
                    self.questionFactory?.requestNextQuestion()
                }
            
            alertPresenter.show(alert: alert)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func disableOrEnableButtons(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
    }
}
