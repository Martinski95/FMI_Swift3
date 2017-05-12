/*Пример:
 ^ 0 0 0 0 0 0 1
 0 1 1 1 1 1 0 0
 0 0 0 0 0 1 1 1
 0 1 1 1 0 1 0 0
 0 1 0 1 0 0 0 1
 0 0 0 1 0 1 0 *
Където:
 0 е проходимо поле
 1 е непроходимо поле
 ^ е началната позиция
 * е крайната позиция
 */

func findPath(maze: inout [[String]], result: inout [(x: Int, y: Int)], _ startX: Int, _ startY: Int, _ endX: Int, _ endY: Int) -> Bool {
    if startX < 0 || startY < 0 || startX >= maze[0].count || startY >= maze.count {
        return false
    }

    if startX == endX && startY == endY {
        result.insert((x: startX, y: startY), at: 0)
        return true
    }

    if maze[startY][startX] != "0" {
        return false
    }

    maze[startY][startX] = " "

    if findPath(maze: &maze, result: &result, startX+1, startY, endX, endY) {
        result.insert((x: startX, y: startY), at: 0)
        return true
    }

    if findPath(maze: &maze, result: &result, startX, startY+1, endX, endY) {
        result.insert((x: startX, y: startY), at: 0)
        return true
    }

    if findPath(maze: &maze, result: &result, startX-1, startY, endX, endY) {
        result.insert((x: startX, y: startY), at: 0)
        return true
    }

    if findPath(maze: &maze, result: &result, startX, startY-1, endX, endY) {
        result.insert((x: startX, y: startY), at: 0)
        return true
    }

    maze[startY][startX] = "X"

    return false
}

func findPath(maze: inout [[String]]) -> [(x: Int, y: Int)] {
    var startX, startY, endX, endY: Int?
    for (y,col) in maze.enumerated() {
        for (x, _) in col.enumerated() {
            if maze[y][x] == "^" {
                startX = x
                startY = y
                maze[y][x] = "0"
            } else if maze[y][x] == "*" {
                endX = x
                endY = y
                maze[y][x] = "0"
            }
        }
    }

    var result = [(x: Int, y: Int)]()
    if(findPath(maze: &maze, result: &result, startX!, startY!, endX!, endY!)) {
        return result
    }
    return []
}

var maze = [
    ["0", "0", "0", "0", "^", "0", "0", "1"],
    ["0", "1", "1", "1", "1", "1", "0", "0"],
    ["0", "0", "0", "0", "0", "1", "1", "1"],
    ["0", "1", "1", "1", "0", "1", "0", "0"],
    ["0", "1", "*", "1", "0", "0", "0", "1"],
    ["0", "0", "0", "1", "0", "1", "0", "1"]
]

print(findPath(maze:&maze))
