//
//  StepperWithValueView.swift
//  ConjugateSegments
//
//  Created by Alexander on 20.10.2024.
//

import UIKit

final class StepperWithValueView: UIView {
    
    private let stepper = UIStepper()
    private let titleLabel = UILabel()
    private let valueTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        return textField
    }()
    private var valueHandler: ((Double) -> Void)?
    
    required init(minValue: Double,
                  initialValue: Double,
                  titleText: String,
                  valueHandler: @escaping (Double) -> Void) {
        super.init(frame: CGRect.zero)
        stepper.minimumValue = minValue
        stepper.maximumValue = Double.infinity
        stepper.value = initialValue
        titleLabel.text = titleText
        valueTextField.text = String(initialValue)
        self.valueHandler = valueHandler
        addSubview(stepper)
        addSubview(titleLabel)
        addSubview(valueTextField)
        setupConstraints()
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        valueTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEnd)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        self.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        stepper.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        stepper.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        stepper.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: stepper.leadingAnchor, constant: 10).isActive = true
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        valueTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        valueTextField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        valueTextField.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        valueTextField.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 10).isActive = true
    }
    
    @objc func stepperChanged() {
        valueTextField.text = String(stepper.value)
        valueHandler?(stepper.value)
    }
    
    @objc func textFieldDidChange() {
        if let newValue = Double(valueTextField.text ?? ""), newValue >= stepper.minimumValue {
            stepper.value = newValue
            valueHandler?(newValue)
        } else {
            valueTextField.text = String(stepper.value)
        }
    }
    
}
