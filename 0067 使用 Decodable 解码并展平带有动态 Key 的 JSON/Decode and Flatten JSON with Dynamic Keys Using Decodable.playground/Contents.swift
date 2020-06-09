import Foundation

///////////////////////DecodedArray////////////////////
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

///////////////////////Student////////////////////
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

var jsonString = """
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

var jsonData = Data(jsonString.utf8)

// Ask JSONDecoder to decode the JSON data as DecodedArray
let decodedResult = try! JSONDecoder().decode(DecodedArray<Student>.self, from: jsonData)

dump(decodedResult)

///////////////////////Food////////////////////
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

jsonString = """
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

jsonData = Data(jsonString.utf8)

// Define DecodedArray type using the angle brackets (<>)
let decodedResult2 = try! JSONDecoder().decode(DecodedArray<[Food]>.self, from: jsonData)

// Perform flatmap on decodedResult to convert [[Food]] to [Food]
let allFood = decodedResult2.flatMap{ $0 }

dump(allFood)
