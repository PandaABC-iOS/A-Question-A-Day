# 使用 Decodable 解码并展平带有动态 Key 的 JSON



### 动态 Key JSON

首先解释下什么是动态 Key JSON , 这里可以看下以下示例

```swift
{
  "S001": {
    "firstName": "Tony",
    "lastName": "Stark"
  },
  "S002": {
    "firstName": "Peter",
    "lastName": "Parker"
  },
  "S003": {
    "firstName": "Bruce",
    "lastName": "Wayne"
  }
}
```

可以看到这个 JSON 的 Key 是可以无限扩展的，这将让我们对创建 Model 无从入手



例子再极端一点，假设是下面这样的呢？

```swift 
{
  "Vegetable": [
    { "name": "Carrots" },
    { "name": "Mushrooms" }
  ],
  "Spice": [
    { "name": "Salt" },
    { "name": "Paper" },
    { "name": "Sugar" }
  ],
  "Fruit": [
    { "name": "Apple" },
    { "name": "Orange" },
    { "name": "Banana" },
    { "name": "Papaya" }
  ]
}
```

这个 JSON 的 key 是可以动态定义的，也就是分类信息，而对应的值是一个数组，存储了该类别下所有的元素



### 解析动态 Key JSON 并展平

首先对第一种 JSON 解析

创建一个 Student 类

```swift
struct Student: Decodable {
    let firstName: String
    let lastName: String
}
```

再创建一个包装类，存储所有的元素

```swift
struct DecodedArray: Decodable {
    var array: [Student]
}
```

定义一个 CodingKey 用于解析

```swift
struct DecodedArray: Decodable {

    var array: [Student]
    
    // Define DynamicCodingKeys type needed for creating 
    // decoding container from JSONDecoder
    private struct DynamicCodingKeys: CodingKey {

        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }
}
```

实现自定义解码方法

```swift
struct DecodedArray: Decodable {

    var array: [Student]
    
    // Define DynamicCodingKeys type needed for creating
    // decoding container from JSONDecoder
    private struct DynamicCodingKeys: CodingKey {

        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }

    init(from decoder: Decoder) throws {

        // 1
        // Create a decoding container using DynamicCodingKeys
        // The container will contain all the JSON first level key
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var tempArray = [Student]()

        // 2
        // Loop through each key (student ID) in container
        for key in container.allKeys {

            // Decode Student using key & keep decoded Student object in tempArray
            let decodedObject = try container.decode(Student.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            tempArray.append(decodedObject)
        }

        // 3
        // Finish decoding all Student objects. Thus assign tempArray to array.
        array = tempArray
    }
}
```

到这里我们已经可以把 json 中的元素解析成 student 元素了

```swift
let jsonString = """
{
  "S001": {
    "firstName": "Tony",
    "lastName": "Stark"
  },
  "S002": {
    "firstName": "Peter",
    "lastName": "Parker"
  },
  "S003": {
    "firstName": "Bruce",
    "lastName": "Wayne"
  }
}
"""

let jsonData = Data(jsonString.utf8)

// Ask JSONDecoder to decode the JSON data as DecodedArray
let decodedResult = try! JSONDecoder().decode(DecodedArray.self, from: jsonData)

dump(decodedResult.array)

// Output:
//▿ 3 elements
//▿ __lldb_expr_21.Student
//  - firstName: "Bruce"
//  - lastName: "Wayne"
//▿ __lldb_expr_21.Student
//  - firstName: "Peter"
//  - lastName: "Parker"
//▿ __lldb_expr_21.Student
//  - firstName: "Tony"
//  - lastName: "Stark"
```

接下来我们将 动态 key 信息保存到 student 中，也就是把 S001 S002 等这些信息保存到对应的 student 中

为 student 添加 studentId

```swift
struct Student: Decodable {

    let firstName: String
    let lastName: String

    // 1
    // Define student ID
    let studentId: String

    // 2
    // Define coding key for decoding use
    enum CodingKeys: CodingKey {
        case firstName
        case lastName
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        // 3
        // Decode firstName & lastName
        firstName = try container.decode(String.self, forKey: CodingKeys.firstName)
        lastName = try container.decode(String.self, forKey: CodingKeys.lastName)

        // 4
        // Extract studentId from coding path
        studentId = container.codingPath.first!.stringValue
    }
}
```

这里我们再验证一下输出结果

```swift
let jsonData = Data(jsonString.utf8)
let decodedResult = try! JSONDecoder().decode(DecodedArray.self, from: jsonData)

dump(decodedResult.array)
// Output:
//▿ 3 elements
//▿ __lldb_expr_37.Student
//  - firstName: "Peter"
//  - lastName: "Parker"
//  - studentId: "S002"
//▿ __lldb_expr_37.Student
//  - firstName: "Tony"
//  - lastName: "Stark"
//  - studentId: "S001"
//▿ __lldb_expr_37.Student
//  - firstName: "Bruce"
//  - lastName: "Wayne"
//  - studentId: "S003"
```

可以看到 studentId 也成功保存了

到这里我们已经实现解析动态 Key JSON 并展平了，接下来我们再完善一下



### 支持集合操作

定义一个 typealias ， 这在之后遵循 Collection 协议有用， 修改的代码会以 *** 标记

```swift
struct DecodedArray: Decodable {

    // ***
    // Define typealias required for Collection protocl conformance
    typealias DecodedArrayType = [Student]

    // ***
    private var array: DecodedArrayType

    // Define DynamicCodingKeys type needed for creating decoding container from JSONDecoder
    private struct DynamicCodingKeys: CodingKey {

        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }

    init(from decoder: Decoder) throws {

        // Create decoding container using DynamicCodingKeys
        // The container will contain all the JSON first level key
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        // ***
        var tempArray = DecodedArrayType()

        // Loop through each keys in container
        for key in container.allKeys {

            // Decode Student using key & keep decoded Student object in tempArray
            let decodedObject = try container.decode(Student.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            tempArray.append(decodedObject)
        }

        // Finish decoding all Student objects. Thus assign tempArray to array.
        array = tempArray
    }
}
```

遵循 Collection 协议

```swift
extension DecodedArray: Collection {

    // Required nested types, that tell Swift what our collection contains
    typealias Index = DecodedArrayType.Index
    typealias Element = DecodedArrayType.Element

    // The upper and lower bounds of the collection, used in iterations
    var startIndex: Index { return array.startIndex }
    var endIndex: Index { return array.endIndex }

    // Required subscript, based on a dictionary index
    subscript(index: Index) -> Iterator.Element {
        get { return array[index] }
    }

    // Method that returns the next index when iterating
    func index(after i: Index) -> Index {
        return array.index(after: i)
    }
}
```

这样我们就让 DecodedArray 变成了一个集合类型了，所有适用 Collection 的方法都可以使用了

```swift
let jsonData = Data(jsonString.utf8)
let decodedResult = try! JSONDecoder().decode(DecodedArray.self, from: jsonData)

// Array literal
dump(decodedResult[2])
//▿ __lldb_expr_5.Student
//- firstName: "Bruce"
//- lastName: "Wayne"
//- studentId: "S003"

// Map
dump(decodedResult.map({ $0.firstName }))
// Output:
//▿ 3 elements
//- "Tony"
//- "Peter"
//- "Bruce"

// Filter
dump(decodedResult.filter({ $0.studentId == "S002" }))
// Output:
//▿ __lldb_expr_1.Student
//- firstName: "Peter"
//- lastName: "Parker"
//- studentId: "S002"
```



### 通过泛型提高通用型

这里把 Student 用泛型表示就好了，修改的地方还是用 *** 标记

```swift
// ***
// Add generic parameter clause
struct DecodedArray<T: Decodable>: Decodable {

    // ***
    typealias DecodedArrayType = [T]

    private var array: DecodedArrayType

    // Define DynamicCodingKeys type needed for creating decoding container from JSONDecoder
    private struct DynamicCodingKeys: CodingKey {

        // Use for string-keyed dictionary
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        // Use for integer-keyed dictionary
        var intValue: Int?
        init?(intValue: Int) {
            // We are not using this, thus just return nil
            return nil
        }
    }

    init(from decoder: Decoder) throws {

        // Create decoding container using DynamicCodingKeys
        // The container will contain all the JSON first level key
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        var tempArray = DecodedArrayType()

        // Loop through each keys in container
        for key in container.allKeys {

            // ***
            // Decode T using key & keep decoded T object in tempArray
            let decodedObject = try container.decode(T.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            tempArray.append(decodedObject)
        }

        // Finish decoding all T objects. Thus assign tempArray to array.
        array = tempArray
    }
}
```



最后我们回顾一下之前提到的第二个动态 Key JSON ，我们用实现好的 DecodedArray 来解码

先定义单个元素类型，这里就是食物 Food

```swift
struct Food: Decodable {

    let name: String
    let category: String

    enum CodingKeys: CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode name
        name = try container.decode(String.self, forKey: CodingKeys.name)

        // Extract category from coding path
        category = container.codingPath.first!.stringValue
    }
}
```

接下来不需要再做其他工作，我们已经可以解析了

```swift
let jsonString = """
{
  "Vegetable": [
    { "name": "Carrots" },
    { "name": "Mushrooms" }
  ],
  "Spice": [
    { "name": "Salt" },
    { "name": "Paper" },
    { "name": "Sugar" }
  ],
  "Fruit": [
    { "name": "Apple" },
    { "name": "Orange" },
    { "name": "Banana" },
    { "name": "Papaya" }
  ]
}
"""

let jsonData = Data(jsonString.utf8)

// Define DecodedArray type using the angle brackets (<>)
let decodedResult = try! JSONDecoder().decode(DecodedArray<[Food]>.self, from: jsonData)

// Perform flatmap on decodedResult to convert [[Food]] to [Food]
let allFood = decodedResult.flatMap{ $0 }

dump(allFood)
// Ouput:
//▿ 9 elements
//▿ __lldb_expr_11.Food
//  - name: "Apple"
//  - category: "Fruit"
//▿ __lldb_expr_11.Food
//  - name: "Orange"
//  - category: "Fruit"
//▿ __lldb_expr_11.Food
//  - name: "Banana"
//  - category: "Fruit"
//▿ __lldb_expr_11.Food
//  - name: "Papaya"
//  - category: "Fruit"
//▿ __lldb_expr_11.Food
//  - name: "Salt"
//  - category: "Spice"
//▿ __lldb_expr_11.Food
//  - name: "Paper"
//  - category: "Spice"
//▿ __lldb_expr_11.Food
//  - name: "Sugar"
//  - category: "Spice"
//▿ __lldb_expr_11.Food
//  - name: "Carrots"
//  - category: "Vegetable"
//▿ __lldb_expr_11.Food
//  - name: "Mushrooms"
//  - category: "Vegetable"
```

注意这里解码出来的结果是 [[Food]] , 我们需要展平，这里用的是 flatmap

