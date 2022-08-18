//
//  ViewController.swift
//  clock-demo
//
//  Created by Seven on 2022/8/18.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    private let clockView = UIView()
    private let digitalTimeLabel = UILabel()
    private let hourView = UIView()
    private let minuteView = UIView()
    private let secondView = UIView()
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addTimer()
    }

    deinit {
        self.removeTimer()
    }
    
    private func setupViews() {
        // clock
        clockView.layer.borderColor = UIColor.black.cgColor
        clockView.layer.borderWidth = 1.0
        clockView.layer.cornerRadius = 100
        clockView.clipsToBounds = true
        
        view.addSubview(clockView)
        
        clockView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(200)
        }
        
        // clockTime
        let clockTimeView = makeClockTimeView()
        
        clockView.addSubview(clockTimeView)
        
        clockTimeView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(3)
        }
        
        // digitalTime
        digitalTimeLabel.text = currentClockTimeText()
        digitalTimeLabel.textAlignment = .center
        
        view.addSubview(digitalTimeLabel)
        
        digitalTimeLabel.snp.makeConstraints {
            $0.bottom.equalTo(clockView.snp.top).offset(-20)
            $0.centerX.leading.trailing.equalToSuperview()
        }
        
        // hour
        hourView.backgroundColor = .orange
        hourView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.9)
        
        view.addSubview(hourView)
        
        hourView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(15)
            $0.height.equalTo(80)
        }
        
        // minute
        minuteView.backgroundColor = .blue
        minuteView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.9)

        view.addSubview(minuteView)
        
        minuteView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(10)
            $0.height.equalTo(100)
        }
        
        // second
        secondView.backgroundColor = .red
        secondView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.9)

        view.addSubview(secondView)
        
        secondView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(5)
            $0.height.equalTo(90)
        }
        
        // Initial Pointer angles
        self.setClockPointersAngles()
    }
    
    private func addTimer() {
        // Prevent from old timer existing.
        self.removeTimer()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.setClockPointersAngles()
            self.digitalTimeLabel.text = self.currentClockTimeText()
        })
        // Needs add to runLoop, otherwise, timer may not count if there's a scrollView and when it scrolls.
        RunLoop.current.add(self.timer!, forMode: .common)
    }

    private func removeTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func setClockPointersAngles() {
        let (hourAngel, minAngle, secAngle) = self.currentClockPointerAngles()
        self.rotate(angle: hourAngel, view: self.hourView)
        self.rotate(angle: minAngle, view: self.minuteView)
        self.rotate(angle: secAngle, view: self.secondView)
    }
    
    private func currentClockTimes() -> (Int, Int, Int) {
        let calendar = Calendar.current
        let now = Date()
        
        let hour = calendar.component(.hour, from: now)
        let min = calendar.component(.minute, from: now)
        let sec = calendar.component(.second, from: now)
        
        return (hour, min, sec)
    }
    
    private func currentClockPointerAngles() -> (CGFloat, CGFloat, CGFloat) {
        let (hour, min, sec) = currentClockTimes()
        // For example: clock time is 15:30, `hourWithMinutes` will be 15 + (30 / 60) = 15.5.
        // It's for `hourView` not only at hour position but also reveals minutes.
        let hourWithMinutes = CGFloat(hour) + CGFloat(min) / 60.0
        
        let hourWithMinutesAngle = CGFloat(hourWithMinutes) / 12.0 * 2 * CGFloat.pi
        let minAngle = CGFloat(min) / 60.0 * 2 * CGFloat.pi
        let secAngle = CGFloat(sec) / 60.0 * 2 * CGFloat.pi
        
        return (hourWithMinutesAngle, minAngle, secAngle)
    }
    
    private func currentClockTimeText() -> String {
        let (hour, min, sec) = currentClockTimes()
        let times = [hour, min, sec].map { "\($0) "}
        return times.joined(separator: ":")
    }
    
    private func rotate(angle: CGFloat, view: UIView) {
        let transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        
        let animate = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animate.duration = 0.1
        animate.fillMode = .forwards
        animate.isRemovedOnCompletion = false
        animate.toValue = NSValue(caTransform3D: transform)

        view.layer.add(animate, forKey: nil)
    }
    
    // MARK: - Factory
    
    private func makeClockTimeView() -> UIView {
        let view = UIView()
        view.backgroundColor = .yellow
        
        let twelveLabel = makeClockLabel(clockTime: "12")
        view.addSubview(twelveLabel)
        twelveLabel.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        
        let threeLabel = makeClockLabel(clockTime: "3")
        view.addSubview(threeLabel)
        threeLabel.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
        }
        
        let sixLabel = makeClockLabel(clockTime: "6")
        view.addSubview(sixLabel)
        sixLabel.snp.makeConstraints {
            $0.bottom.centerX.equalToSuperview()
        }
        
        let nineLabel = makeClockLabel(clockTime: "9")
        view.addSubview(nineLabel)
        nineLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        
        return view
    }
    
    private func makeClockLabel(clockTime: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = clockTime
        return label
    }
}

