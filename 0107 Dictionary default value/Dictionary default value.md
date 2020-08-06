# Dictionary default value



Swift4 以后可以在字典中 key 找不到的情况下提供默认值访问

```swift
let person = ["name": "Taylor", "city": "Nashville"]
let name = person["name", default: "Anonymous"]
```

或许你会觉得这还不如用 ??

```swift
let name = person["name"] ?? "Anonymous"
```

取值的时候确实用 ?? 也不错，但是修改值时，有默认值就方便多了，因为修改的不再是可选值了

```swift
var favoriteTVShows = ["Red Dwarf", "Blackadder", "Fawlty Towers", "Red Dwarf"]
var favoriteCounts = [String: Int]()

for show in favoriteTVShows {
    favoriteCounts[show, default: 0] += 1
}
```

