import UIKit
import FirebaseAuth
import FirebaseFirestore
import SnapKit
import DGCharts

class HomeViewController: UIViewController {
    
    var goals: [(id: String, text: String, date: Date, amount: Double)] = []
    let db = Firestore.firestore()
    lazy var currentUserID: String? = Auth.auth().currentUser?.uid
    
    let backImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "osnovnoy")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "FINWISE"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = UIColor.tabBarItemAccent
        label.numberOfLines = 0
        return label
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.left.to.line.compact"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.grayCustom.withAlphaComponent(0.2)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var pieChartView: PieChartView = {
        let chartView = PieChartView()
        chartView.rotationEnabled = true
        chartView.isUserInteractionEnabled = true
        chartView.holeRadiusPercent = 0.2
        chartView.transparentCircleColor = UIColor.clear
        chartView.chartDescription.enabled = false
        chartView.legend.orientation = .vertical
        chartView.legend.verticalAlignment = .bottom
        chartView.delegate = self
        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        return chartView
    }()
    
    lazy var goalTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Название цели"
        textField.borderStyle = .roundedRect
        textField.alpha = 0
        textField.isHidden = true
        return textField
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.alpha = 0
        datePicker.isHidden = true
        return datePicker
    }()
    
    lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Необходимая сумма"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.alpha = 0
        textField.isHidden = true
        return textField
    }()
    
    lazy var goalsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить цель", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.grayCustom.withAlphaComponent(0.2)
        button.addTarget(self, action: #selector(goalsTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        if let currentUserID = currentUserID {
            loadGoals(for: currentUserID)
        } else {
            // Handle the case when currentUserID is nil
        }
    }
    
    private func setUI() {
        view = backImage
        backImage.addSubview(nameLabel)
        backImage.addSubview(logoutButton)
        backImage.addSubview(pieChartView)
        backImage.addSubview(goalTextField)
        backImage.addSubview(datePicker)
        backImage.addSubview(amountTextField)
        backImage.addSubview(goalsButton)
        setConstraints()
    }
    
    private func setConstraints() {
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.left.equalToSuperview().offset(20) }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.centerX.equalToSuperview() }
        
        goalTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(40) }
        
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(goalTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(40) }
        
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(10)
            make.leading.trailing.equalTo(goalsButton)
            make.height.equalTo(150) }
        
        pieChartView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(250) }
        
        goalsButton.snp.makeConstraints { make in
            make.top.equalTo(pieChartView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(70) }
    }
    
    @objc func goalsTapped() {
        UIView.animate(withDuration: 0.3, animations: {
            self.goalTextField.alpha = 1
            self.datePicker.alpha = 1
            self.amountTextField.alpha = 1
        }) { _ in
            self.goalTextField.isHidden = false
            self.datePicker.isHidden = false
            self.amountTextField.isHidden = false
            self.goalTextField.becomeFirstResponder()
        }
        
        goalsButton.setTitle("Сохранить цель", for: .normal)
        goalsButton.removeTarget(self, action: #selector(goalsTapped), for: .touchUpInside)
        goalsButton.addTarget(self, action: #selector(saveGoal), for: .touchUpInside)
    }
    
    @objc func saveGoal() {
        guard let goalText = goalTextField.text, !goalText.isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите название цели", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard let amountText = amountTextField.text, !amountText.isEmpty, let amount = Double(amountText) else {
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите корректную сумму", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
            return
        }
        
        let goalDate = datePicker.date
        
        let goalData: [String: Any] = [
            "text": goalText,
            "date": goalDate,
            "amount": amount,
            "userID": currentUserID ?? ""
        ]
        
        db.collection("goals").addDocument(data: goalData) { error in
            if let error = error {
                print("Ошибка добавления документа: \(error)")
            } else {
                print("Цель успешно сохранена")
                self.goalTextField.text = ""
                self.amountTextField.text = ""
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.goalTextField.alpha = 0
                    self.datePicker.alpha = 0
                    self.amountTextField.alpha = 0
                }) { _ in
                    self.goalTextField.isHidden = true
                    self.datePicker.isHidden = true
                    self.amountTextField.isHidden = true
                    self.goalTextField.resignFirstResponder()
                    self.loadGoals(for: self.currentUserID ?? "")
                }
                
                self.goalsButton.setTitle("Добавить цель", for: .normal)
                self.goalsButton.removeTarget(self, action: #selector(self.saveGoal), for: .touchUpInside)
                self.goalsButton.addTarget(self, action: #selector(self.goalsTapped), for: .touchUpInside)
            }
        }
    }
    
    private func loadGoals(for userID: String) {
        db.collection("goals").whereField("userID", isEqualTo: userID).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.goals = []
                var dataEntries: [PieChartDataEntry] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let id = document.documentID
                    let amount = data["amount"] as? Double ?? 0.0
                    let text = data["text"] as? String ?? ""
                    let timestamp = data["date"] as? Timestamp ?? Timestamp()
                    let date = timestamp.dateValue()
                    self.goals.append((id: id, text: text, date: date, amount: amount))
                    let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
                    let label = "\(text)\n\(dateString)"
                    dataEntries.append(PieChartDataEntry(value: amount, label: label))
                }
                let dataSet = PieChartDataSet(entries: dataEntries, label: "Goals")
                
                // Добавление цветов к сегментам
                dataSet.colors = ChartColorTemplates.material()
                
                let data = PieChartData(dataSet: dataSet)
                self.pieChartView.data = data
                self.pieChartView.legend.enabled = true
                self.pieChartView.legend.orientation = .vertical
                self.pieChartView.legend.verticalAlignment = .bottom
                self.pieChartView.delegate = self // Установка делегата для обработки выбора сегментов
            }
        }
    }
    
    @objc func logoutTapped() {
        do {
            try Auth.auth().signOut()
            if let window = UIApplication.shared.windows.first {
                let loginViewController = LoginViewController()
                window.rootViewController = loginViewController
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: nil)
            }
        } catch let signOutError as NSError {
            print("Ошибка выхода: \(signOutError.localizedDescription)")
            let alert = UIAlertController(title: "Ошибка", message: signOutError.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    private func deleteGoal(at index: Int) {
        let goal = goals[index]
        db.collection("goals").document(goal.id).delete { error in
            if let error = error {
                print("Ошибка удаления документа: \(error)")
            } else {
                print("Цель успешно удалена")
                self.goals.remove(at: index)
                self.loadGoals(for: self.currentUserID ?? "")
            }
        }
    }
}

extension HomeViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let alert = UIAlertController(title: "Удалить цель?", message: "Вы уверены, что хотите удалить эту цель?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
            if let index = self.pieChartView.data?.dataSets.first?.entryIndex(entry: entry) {
                self.deleteGoal(at: index)
            }
        })
        present(alert, animated: true)
    }
}

