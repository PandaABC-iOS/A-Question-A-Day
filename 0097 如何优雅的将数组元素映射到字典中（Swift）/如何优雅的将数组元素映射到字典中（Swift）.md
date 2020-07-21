# 如何优雅的将数组元素映射到字典中（Swift）

### 以前

假设在我们开发一个商品页面的时候，需求是按商品的分类来分 section，但后台给我们返回的数据是整个列表的商品数组。在 Swift 5 之前，我们只能通过遍历数组来分组：

```swift
struct Shop {
    let name: String
    let category: String
}

let shops = [Shop(name: "iPhone 11", category: "phone"),
             Shop(name: "iPhone XR", category: "phone"),
             Shop(name: "Redmi note8", category: "phone"),
             Shop(name: "卫龙", category: "food"),
             Shop(name: "老干妈", category: "food")]

let allCategory = Set(shops.map { $0.category })
var shopSections = [String: [Shop]]()
allCategory.forEach { (cate) in
    let cateShops = shops.filter { $0.category == cate }
    shopSections[cate] = cateShops
}
```

### 现在

在 Swift 5.0 发布以后，Dictionary 新添加了一个初始化方法：`init(grouping:by:)`。该方法可以通过闭包中返回的 key 将数组组织为一个字典。用该方法重写上面的代码：

```swift
let shopSections = Dictionary(grouping: shops) { (shop) -> String in
    return shop.category
}
```

上面的代码可以通过 Swift 的语法糖更加精简：

```swift
let shopSections = Dictionary(grouping: shops) { $0.category }
```

### 更多

因为该方法提供了一个闭包来给我们操作，所以我们不仅仅可以返回当前模型的字段，我们还可以根据需求来灵活变通。比如上面的例子中，假如我们的需求变更为按商品的归属地来进行分类。虽然后台返回的字段没有返回，但我们依然可以通过商品来进行判断：

```swift
let shopSections = Dictionary(grouping: shops) { (shop) -> String in
    if shop.name.contains("iPhone") {
        return "US"
    }
    return "China"
}

print(shopSections)
/*
["US": [DataStructureDemo.Shop(name: "iPhone 11", category: "phone"), DataStructureDemo.Shop(name: "iPhone XR", category: "phone")],
"China": [DataStructureDemo.Shop(name: "Redmi note8", category: "phone"), DataStructureDemo.Shop(name: "卫龙", category: "food"),
DataStructureDemo.Shop(name: "薯条", category: "food")]]
*/
```

### 探索

大家都知道只要遵守 Hashable 的数据类型都可以当做字典的 key，比如 Int、String等。所以，我们也可以让结构体来当做字典的 key，只要它遵守了该协议：

```swift
struct Company: Hashable {
    let name: String
}

struct Shop {
    let name: String
    let category: String
    let company: Company
    
}

let apple = Company(name: "苹果")
let littleMi = Company(name: "小米")
let wl = Company(name: "卫龙")
let lgm = Company(name: "老干妈")


let shops = [Shop(name: "iPhone 11", category: "phone", company: apple),
             Shop(name: "iPhone XR", category: "phone", company: apple),
             Shop(name: "Redmi note8", category: "phone", company: littleMi),
             Shop(name: "卫龙", category: "food", company: wl),
             Shop(name: "薯条", category: "food", company: lgm)]


let shopSections = Dictionary(grouping: shops) { return $0.company }

print(shopSections)
/*
[DataStructureDemo.Company(name: "小米"): [DataStructureDemo.Shop(name: "Redmi note8", category: "phone", company: DataStructureDemo.Company(name: "小米"))], DataStructureDemo.Company(name: "苹果"): [DataStructureDemo.Shop(name: "iPhone 11", category: "phone", company: DataStructureDemo.Company(name: "苹果")), DataStructureDemo.Shop(name: "iPhone XR", category: "phone", company: DataStructureDemo.Company(name: "苹果"))], DataStructureDemo.Company(name: "卫龙"): [DataStructureDemo.Shop(name: "卫龙", category: "food", company: DataStructureDemo.Company(name: "卫龙"))], DataStructureDemo.Company(name: "老干妈"): [DataStructureDemo.Shop(name: "薯条", category: "food", company: DataStructureDemo.Company(name: "老干妈"))]]
*/
```

希望本文能让你清晰的知道该如何使用 `init(grouping:by:)` ，能给你带来更高的开发效率。😄

