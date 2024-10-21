//
//  ViewController.swift
//  ConjugateSegments
//
//  Created by Alexander on 20.10.2024.
//

// to do: позволить изображению выходить за фрейм imageView или обработать такой сценарий, пофиксить цвета для темной темы, вынести текста в константы, вынести расчет графики в отдельный поток

import UIKit

enum ParametersError: Error {
    case validation(String)
    case parameters
}

final class ViewController: UIViewController {
    
    private var conjugateRadius: Double = 12
    private var innerRadius: Double = 100
    private var outerRadius: Double = 150
    private var teethNumber: Int = 12
    
    private lazy var renderer: UIGraphicsImageRenderer = {
        return UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = false
        return imageView
    }()
    
    private lazy var conjugateRadiusStepper: StepperWithValueView = {
        return StepperWithValueView(minValue: 0,
                                    initialValue: conjugateRadius,
                                    titleText: "Радиус сопряжения:") { [unowned self] newValue in
            self.conjugateRadius = newValue
            updateImage()
        }
    }()
    
    private lazy var innerRadiusStepper: StepperWithValueView = {
        return StepperWithValueView(minValue: 0,
                                    initialValue: innerRadius,
                                    titleText: "Радиус внутренней окружности:") { [unowned self] newValue in
            self.innerRadius = newValue
            updateImage()
        }
    }()
    
    private lazy var outerRadiusStepper: StepperWithValueView = {
        return StepperWithValueView(minValue: 0,
                                    initialValue: outerRadius,
                                    titleText: "Радиус внешней окружности:") { [unowned self] newValue in
            self.outerRadius = newValue
            updateImage()
        }
    }()
    
    private lazy var teethNumberStepper: StepperWithValueView = {
        return StepperWithValueView(minValue: 3,
                                    initialValue: Double(teethNumber),
                                    titleText: "Количество зубцов:") { [unowned self] newValue in
            self.teethNumber = Int(newValue)
            self.updateImage()
        }
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.text = ""
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            DispatchQueue.main.async {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            DispatchQueue.main.async {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    @objc func hideKeyboard() {
            view.endEditing(true)
        }
    
    private func addConjugateRadiusStepper() {
        conjugateRadiusStepper.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(conjugateRadiusStepper)
    }
    
    private func addInnerRadiusStepper() {
        innerRadiusStepper.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(innerRadiusStepper)
    }
    
    private func addOuterRadiusStepper() {
        outerRadiusStepper.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(outerRadiusStepper)
    }
    
    private func addTeethNumberStepper() {
        teethNumberStepper.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(teethNumberStepper)
    }
    
    private func addImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    private func addStatusLabel() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
    }
    
    private func addUI() {
        addConjugateRadiusStepper()
        addInnerRadiusStepper()
        addOuterRadiusStepper()
        addTeethNumberStepper()
        addImageView()
        addStatusLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        renderer = UIGraphicsImageRenderer(size: imageView.layer.frame.size)
        updateImage()
    }
    
    // Разбивать или нет выставление констрейнтов в отдельные метоы это холиварный вопрос и решается на уровне соглашений по всему проекту - в данном сучае оставил все в одном методе
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        conjugateRadiusStepper.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        conjugateRadiusStepper.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        conjugateRadiusStepper.bottomAnchor.constraint(equalTo: innerRadiusStepper.topAnchor).isActive = true
        innerRadiusStepper.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        innerRadiusStepper.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        innerRadiusStepper.bottomAnchor.constraint(equalTo: outerRadiusStepper.topAnchor).isActive = true
        outerRadiusStepper.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        outerRadiusStepper.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        outerRadiusStepper.bottomAnchor.constraint(equalTo: teethNumberStepper.topAnchor).isActive = true
        teethNumberStepper.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        teethNumberStepper.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        teethNumberStepper.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        imageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -20).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        statusLabel.bottomAnchor.constraint(equalTo: conjugateRadiusStepper.topAnchor).isActive = true
        statusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10).isActive = true
        statusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
    }
    
    private func checkParameters() throws {
        if innerRadius <= 0 {
            throw ParametersError.validation("Внутренний радиус должен быть больше 0")
        }
        if outerRadius <= 0 {
            throw ParametersError.validation("Внешний радиус должен быть больше 0")
        }
        if innerRadius > outerRadius {
            throw ParametersError.validation("Внешний радиус должен быть не меньше внутреннего")
        }
        if teethNumber < 3 {
            throw ParametersError.validation("Количество зубцов не может быть меньше 3")
        }
        if conjugateRadius > 180 {
            throw ParametersError.validation("Радиус сопряжения не может быть больше 180")
        }
    }
    
    private func checkDistance(prevPoint: CGPoint, currentPoint: CGPoint, nextPoint: CGPoint) throws {
        let midPoint = CGPoint(x: 0.5 * (prevPoint.x + nextPoint.x), y: 0.5 * (prevPoint.y + nextPoint.y))
        if MathHelper.distanceSquared(from: midPoint, to: prevPoint) < MathHelper.distanceSquared(from: currentPoint, to: prevPoint) {
            statusLabel.text = "Неправильные параметры"
            imageView.image = nil
            throw ParametersError.parameters
        }
    }
    
    private func updateImage() {
        do {
            try checkParameters()
        } catch ParametersError.validation(let errorMessage) {
            statusLabel.text = errorMessage
            imageView.image = nil
            return
        } catch {
            // to do
            return
        }
        statusLabel.text = ""
        let img = renderer.image { ctx in
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(3)
            let innerRectangle = CGRect(x: 0, y: 0, width: imageView.layer.frame.size.width, height: imageView.layer.frame.size.height)
            let path = CGMutablePath()
            let points = MathHelper.polygonPointArray(sides: teethNumber,
                                                      x: innerRectangle.size.width / 2,
                                                      y: innerRectangle.size.height / 2,
                                                      innerRadius: innerRadius,
                                                      outerRadius: outerRadius)
            path.move(to: CGPoint(x: 0.5 * (points[0].x + points[1].x), y: 0.5 * (points[0].y + points[1].y)))
            for i in 0..<points.count - 2 {
                let nextPoint1 = points[i + 1]
                let nextPoint2 = points[i + 2]
                do {
                    try checkDistance(prevPoint: points[i], currentPoint: path.currentPoint, nextPoint: nextPoint1)
                } catch {
                    return
                }
                path.addArc(tangent1End: nextPoint1, tangent2End: nextPoint2, radius: conjugateRadius)
            }
            path.closeSubpath()
            ctx.cgContext.addPath(path)
            ctx.cgContext.drawPath(using: .stroke)
        }
        imageView.image = img
    }
    
}
