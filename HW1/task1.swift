func permutation(_ str: String, result: inout [String], _ prefix: String = "") {
    let n = str.characters.count
    if n == 0 {
        result.append(prefix)
    } else {
        for i in 0..<n {
            let id = str.index(str.startIndex, offsetBy: i)
            let id_next = str.index(str.startIndex, offsetBy: i+1)
            var prefix_copy = prefix
            prefix_copy.append(str[id])
            permutation(str[str.startIndex..<id] + str[id_next..<str.endIndex], result:&result, prefix_copy)
        }
    }
}

var str = "abc"
var res = [String]()
permutation(str, result:&res)
print(Set(res))
