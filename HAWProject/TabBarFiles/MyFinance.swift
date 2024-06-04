import Foundation
import UIKit
import SnapKit

class MyFinCabViewController: UIViewController {
    
    let netWorkManager = NetworkManager.shared
    var exchangeData: ExchangeData?
    
    var selectedCurrencyFrom: String?
    var selectedCurrencyTo: String?
    
    lazy var nameExchangeLabel: UILabel = {
        let label = UILabel()
        label.text = "ОБМЕН ВАЛЮТЫ"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.tabBarItemAccent
        label.numberOfLines = 0
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 2, height: 2)
        label.layer.shadowOpacity = 0.7
        label.layer.shadowRadius = 1.0
        return label
    }()
    
    lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 5
        textField.layer.masksToBounds = true
        textField.textColor = .black
        textField.placeholder = "Введите сумму"
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    lazy var currencyFromButton: UIButton = {
        let button = UIButton()
        button.setTitle("Валюта", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(currencyFromButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var currencyToButton: UIButton = {
        let button = UIButton()
        button.setTitle("Валюта", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(currencyToButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var currencyPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
        return pickerView
    }()
    
    lazy var convertButton: UIButton = {
        let button = UIButton()
        button.setTitle("Конвертировать ↑↓", for: .normal)
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor.grayCustom.withAlphaComponent(0.2)
        button.setTitleColor(.white, for: .normal)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(convertButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "San Francisco", size: 14)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let backImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "osnovnoy")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var goButton: UIButton = {
        let button = UIButton()
        button.setTitle("Калькулятор: Инвестиционный", for: .normal)
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor.grayCustom.withAlphaComponent(0.2)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(buttonTapp), for: .touchUpInside)
        return button
    }()
    
    lazy var pushButton: UIButton = {
        let button = UIButton()
        button.setTitle("Калькулятор: Срок Накопления", for: .normal)
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor.grayCustom.withAlphaComponent(0.2)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var creditButton: UIButton = {
        let button = UIButton()
        button.setTitle("Калькулятор: Кредитный", for: .normal)
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor.grayCustom.withAlphaComponent(0.2)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(tapMe), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadExchangeData()
    }
    
    private func setUI() {
        view = backImage
        backImage.addSubview(goButton)
        backImage.addSubview(pushButton)
        backImage.addSubview(creditButton)
        
        backImage.addSubview(nameExchangeLabel)
        backImage.addSubview(amountTextField)
        backImage.addSubview(currencyFromButton)
        backImage.addSubview(currencyToButton)
        backImage.addSubview(currencyPickerView)
        backImage.addSubview(convertButton)
        backImage.addSubview(resultLabel)
        
        setConstraints()
    }
    
    private func setConstraints() {
        
        goButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(140)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(70)
        }
        
        pushButton.snp.makeConstraints { make in
            make.top.equalTo(goButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(70)
        }
        
        creditButton.snp.makeConstraints { make in
            make.top.equalTo(pushButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(70)
        }
        
        nameExchangeLabel.snp.makeConstraints { make in
            make.top.equalTo(creditButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(70)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(nameExchangeLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(80)
            make.width.equalTo(200)
        }
        
        
        currencyFromButton.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(100)
            make.height.equalTo(amountTextField)
        }
        
        currencyToButton.snp.makeConstraints { make in
            make.top.equalTo(currencyFromButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(100)
            make.height.equalTo(amountTextField)
        }
       
        currencyPickerView.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(150)
        }
        
        convertButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-115)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(70)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-160)
        }
    }
    
    @objc func buttonTapp() {
        print("Tapped")
        navigationController?.pushViewController(InvestCalculatorViewController(), animated: true)
    }
    
    @objc func buttonTapped() {
        print("Tapped")
        navigationController?.pushViewController(InvestCalculatorSecondViewController(), animated: true)
    }
    
    @objc func tapMe() {
        print("Tapped")
        navigationController?.pushViewController(CreditCalculatorViewController(), animated: true)
    }
    
    @objc func currencyFromButtonTapped() {
        currencyPickerView.tag = 1
        currencyPickerView.isHidden = !currencyPickerView.isHidden
    }
    
    @objc func currencyToButtonTapped() {
        currencyPickerView.tag = 2
        currencyPickerView.isHidden = !currencyPickerView.isHidden
    }
    
    @objc func convertButtonTapped() {
        guard let amountText = amountTextField.text, let amount = Double(amountText),
              let selectedCurrencyFrom = selectedCurrencyFrom, let selectedCurrencyTo = selectedCurrencyTo,
              let rates = exchangeData?.rates else {
            resultLabel.text = "Ошибка ввода данных"
            return
        }
        
        guard let rateFrom = rates[selectedCurrencyFrom], let rateTo = rates[selectedCurrencyTo] else {
            resultLabel.text = "Ошибка с курсами валют"
            return
        }
        
        let usdAmount = amount / rateFrom
        let convertedAmount = usdAmount * rateTo
        resultLabel.text = String(format: "%.2f", convertedAmount)
    }
    
    private func loadExchangeData() {
        netWorkManager.getExchangeData { [weak self] exchangeData in
            guard let exchangeData = exchangeData else {
                return
            }
            
            DispatchQueue.main.async {
                self?.exchangeData = exchangeData
                self?.currencyPickerView.reloadAllComponents()
            }
        }
    }
}

extension MyFinCabViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exchangeData?.rates.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let exchangeData = exchangeData {
            let currencies = Array(exchangeData.rates.keys)
            return currencies[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let exchangeData = exchangeData {
            let currencies = Array(exchangeData.rates.keys)
            if pickerView.tag == 1 {
                selectedCurrencyFrom = currencies[row]
                currencyFromButton.setTitle(selectedCurrencyFrom, for: .normal)
            } else if pickerView.tag == 2 {
                selectedCurrencyTo = currencies[row]
                currencyToButton.setTitle(selectedCurrencyTo, for: .normal)
            }
            pickerView.isHidden = true
        }
    }
}


