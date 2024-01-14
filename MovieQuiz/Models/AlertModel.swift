class AlertModel {
    let title: String
    let message: String
    let buttonText: String
    
    let action: (Any) -> Void
    
    init(title: String, message: String, buttonText: String, action: @escaping (Any) -> Void) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.action = action
    }
}
