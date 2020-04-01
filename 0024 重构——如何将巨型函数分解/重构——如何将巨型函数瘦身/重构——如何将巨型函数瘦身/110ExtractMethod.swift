/**
 动机：如果每个函数的粒度都很小，那么函数被复用的机会就更大；其次，这会使高层函数读起来就像一系列注释；再其次，如果函数都是细粒度，那么函数的覆写也会更容易些。
 做法：
 */

// 以它做什么来命名，而不是以它怎么做命名
// 将提炼出的代码从源函数复制到新建的目标函数中
// 注意局部变量和源函数参数
// 检查是否有“仅用于被提炼代码段”的临时变量。如果有，在目标函数中将它们声明为临时变量。
// 检查被提炼代码段，看看是否有任何局部变量的值被它改变。如果一个临时变量值被修改了，看看是否可以将被提炼代码段处理为一个查询，并将结果赋值给相关变量，参看范例3。
// 将被提炼代码段中需要读取的局部变量，当作参数传给目标函数。
// 处理完所有局部变量之后，进行编译。
// 在源函数中，将被提炼代码段替换为对目标函数的调用。

class ExtractMethod {
    class Demo1 {
        
        var orders = [Order]()
        
        var name = ""
        
        func printOwing() {
            var outstanding = 0.0
            // 打印banner
            print("***********************")
            print("**** Customer Owes ****")
            print("***********************")
            
            for aOrder in orders {
                outstanding += aOrder.getAmount()
            }
            
            // 打印详情
            print("name: " + name)
            print("amount" + "\(outstanding)")
        }
        
        class Order {
            func getAmount() -> Double {
                return 0.0
            }
        }
    }
}

