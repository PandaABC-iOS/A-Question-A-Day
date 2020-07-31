# 自定义时期选择控件

因为 UIDatePicker 的样式不满足 UI 要求（间距问题），需要自定义一个日期选择控件，支持最小日期，最大日期范围，具体使用可以参考 AC iPhone 项目的用户信息编辑界面。

UIDatePicker 内部是使用 UIPickerView 来实现的，我们也可以直接用 UIPickerView 来做。

这里实现一个可以选择年，月，日的日期选择控件。

## 数据源

### model
```swift
/// 当前控件展示的日期
private var _date: Date
/// 日期的 components，用来记录用户选择的年，月，日，也用这个来构造 Date 对象
private var components: DateComponents

```

### UIPickerView 数据源
```swift
/// 年份的范围
private let yearRange: [Int]
/// 月份的范围
private let monthRange: [Int]
/// 天的范围，会根据年，月，动态调整
private var dayRange: [Int] = []
```

### 初始化数据

```swift
_date = Date()

if let pastYear = self.calendar.dateComponents(in: self.timezone, from: Date.distantPast).year,
	let futureYear = self.calendar.dateComponents(in: self.timezone, from: Date.distantFuture).year {
	/// 4000 年
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
````

动态获取当前日期天数
```swift
private func dayRange(date: Date) -> [Int]? {
	self.calendar.range(of: .day, in: .month, for: date).flatMap{Array($0)}
}
```

## 界面展示
```swift
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
```

### 滑动滚轮，更新时间
```swift
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
	
	/// 最小日期，最大日期判断
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

/// 设置新的当前日期
func setDate(date: Date, animated: Bool) {
	_date = date

	updateComponents(date: date)
	/// 更新当前日期的天数
	if let range = self.dayRange(date: _date) {
		self.dayRange = range
	}
	
	pickerView.reloadAllComponents()
	updateSelectedRows(animated: animated)
}

private func updateComponents(date: Date) {
	components = calendar.dateComponents([.year, .month, .day], from: date)
	components.calendar = calendar
}

/// 更新滚轮位置
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
```