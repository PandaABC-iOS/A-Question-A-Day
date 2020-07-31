//
//  ASDatePicker.swift
//  iPhoneN
//
//  Created by Song Zhou on 2020/7/30.
//  Copyright © 2020 PandaABC. All rights reserved.
//

import UIKit

class ASDatePicker: UIControl {

	override init(frame: CGRect) {
		pickerView = _ACPickerView(frame: frame)
		
		_date = Date()
		
		if let pastYear = self.calendar.dateComponents(in: self.timezone, from: Date.distantPast).year,
			let futureYear = self.calendar.dateComponents(in: self.timezone, from: Date.distantFuture).year {
			self.yearRange = Array(pastYear...futureYear)
		} else {
			self.yearRange = []
		}
		
		if let range = self.calendar.range(of: .month, in: .year, for: _date) {
			self.monthRange = Array(range)
		} else {
			self.monthRange = []
		}
		
		components = calendar.dateComponents([.year, .month, .day], from: _date)
		components.calendar = calendar
		
		super.init(frame: frame)
		if let range = self.dayRange(date: _date) {
			self.dayRange = range
		}
		
		addSubview(pickerView)
		pickerView.dataSource = self
		pickerView.delegate = self
		
		pickerView.reloadAllComponents()
		updateSelectedRows(animated: false)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		pickerView.frame = self.bounds
	}
	
	private func dayRange(date: Date) -> [Int]? {
		self.calendar.range(of: .day, in: .month, for: date).flatMap{Array($0)}
	}
	
	private func changeComponents(year: Int? = nil, month: Int? = nil, day: Int? = nil) {
		if let year = year {
			components.year = year
		}
		
		if let month = month {
			components.month = month
		}
		
		if let day = day {
			components.day = day
		}
		
		if let date = components.date {
			if let miniDate = minimumDate, date < miniDate {
				setDate(date: miniDate, animated: true)
			} else if let maxDate = maximumDate, date > maxDate {
				setDate(date: maxDate, animated: true)
			} else {
				setDate(date: date, animated: true)
			}
		}
	}
	
	private func updateSelectedRows(animated: Bool) {
		if let year = components.year, let index = yearRange.firstIndex(of: year) {
			pickerView.selectRow(index, inComponent: 0, animated: animated)
		}

		if let month = components.month, let index = monthRange.firstIndex(of: month) {
			pickerView.selectRow(index, inComponent: 1, animated: animated)
		}

		if let day = components.day, let index = dayRange(date: date)?.firstIndex(of: day) {
			pickerView.selectRow(index, inComponent: 2, animated: animated)
		}
	}
	
	var calendar: Calendar = Calendar(identifier: .gregorian)
	var locale: Locale = Locale.current
	var timezone: TimeZone = TimeZone.current
	
	var date: Date {
		set {
			setDate(date: newValue, animated: true)
		}

		get {
			return _date
		}
	}

	var minimumDate: Date?
	var maximumDate: Date?
	
	func setDate(date: Date, animated: Bool) {
		_date = date

		updateComponents(date: date)
		if let range = self.dayRange(date: _date) {
			self.dayRange = range
		}
		
		pickerView.reloadAllComponents()
		updateSelectedRows(animated: animated)
	}

	private var _date: Date
	private var components: DateComponents
	
	private let pickerView: _ACPickerView
	private let yearRange: [Int]
	private let monthRange: [Int]
	private var dayRange: [Int] = []
	
	private func updateComponents(date: Date) {
		components = calendar.dateComponents([.year, .month, .day], from: date)
		components.calendar = calendar
	}
}

extension ASDatePicker: UIPickerViewDataSource, UIPickerViewDelegate {
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 3
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch component {
		case 0:
			return yearRange.count
		case 1:
			return monthRange.count
		case 2:
			return dayRange.count
		default:
			return 0
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		let width = self.bounds.width/3
		print("width :\(width)")
		switch component {
		case 0:
			return width
		case 1:
			return width
		case 2:
			return width
		default:
			return 0
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
		return 40
	}

	func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
		let cell: ASDatePickerRow
		if let view = view as? ASDatePickerRow {
			cell = view
		} else {
			cell = ASDatePickerRow()
		}

		switch component {
		case 0:
			cell.textLabel.text = "\(yearRange[row])年"
		case 1:
			let month = monthRange[row]
			if month < 10 {
				cell.textLabel.text = "0\(month)月"
			} else {
				cell.textLabel.text = "\(month)月"
			}
		case 2:
			let day = dayRange[row]
			if day < 10 {
				cell.textLabel.text = "0\(day)日"
			} else {
				cell.textLabel.text = "\(day)日"
			}

		default:
			break
		}
		
		return cell
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch component {
		case 0:
			let year = yearRange[row]
			changeComponents(year:year)
		case 1:
			let month = monthRange[row]
			changeComponents(month: month)
		case 2:
			let day = dayRange[row]
			changeComponents(day: day)
		default:
			break
		}
	}
}

private class _ACPickerView: UIPickerView {
    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.borderWidth = 0 // Main view rounded border

        // Component borders
        self.subviews.forEach {
            $0.layer.borderWidth = 0
            $0.isHidden = $0.frame.height <= 1.0
        }
    }
}

private class ASDatePickerRow: UIView {
	override init(frame: CGRect) {
		textLabel = UILabel()
		textLabel.font = UIFont.as_font(size: 20)
		textLabel.textColor = UIColor.asLabelBlack
		textLabel.textAlignment = .center
		super.init(frame: frame)
		
		addSubview(textLabel)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		textLabel.frame = CGRect(x: 9, y: 0, width: bounds.width-9, height: bounds.height)
	}
	
	let textLabel: UILabel
}
