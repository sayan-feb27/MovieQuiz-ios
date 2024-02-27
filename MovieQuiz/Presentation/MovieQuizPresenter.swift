import UIKit


final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    
    private var currentQuestionIndex: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticsService: StatisticsService
    weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticsService = StatisticsServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.currentQuestion = question
            
            let step = self?.convert(model: question)
            guard let quizStep = step else { return }
            self?.viewController?.show(quiz: quizStep)
        }
    }
    
    // MARK: - Internal functions
    func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        self.questionFactory?.requestNextQuestion()
    }
    
    func noButtonClicked() {
        handleUserAnswer(answer: false)
    }
    
    func yesButtonClicked() {
        handleUserAnswer(answer: true)
    }
    
    func loadData() {
        questionFactory?.loadData()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        var image = UIImage(data: model.image) ?? UIImage(named: "network-errors")
        if image == nil {
            image = UIImage()
        }
        
        return QuizStepViewModel(
            image: image!,
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
        )
    }
    
    // MARK: - Private functions
    private func makeStatisticsMessage() -> String {
        statisticsService.store(correct: correctAnswers, total: questionsAmount)
        
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticsService.gamesCount)
        Рекорд: \(statisticsService.bestGame.correct)/\(statisticsService.bestGame.total)
        (\(statisticsService.bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticsService.totalAccuracy * 100))%
        """
        
        return message
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let results = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: self.makeStatisticsMessage(),
                buttonText: "Сыграем еще раз?"
            )
            viewController?.show(quiz: results)
        } else {
            self.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        viewController?.disableOrEnableButtons(isEnabled: false)
        viewController?.showLoadingIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.proceedToNextQuestionOrResults()
            viewController?.hideLoadingIndicator()
            viewController?.disableOrEnableButtons(isEnabled: true)
        }
    }
    
    private func handleUserAnswer(answer: Bool) {
        guard let question = currentQuestion else { return }
        
        let isCorrect = question.correctAnswer == answer
        correctAnswers = isCorrect ? correctAnswers + 1 : correctAnswers
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
}
