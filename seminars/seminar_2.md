# Семинар - практика със Swift 

В днешния семинар ще се фокусираме над писането на програмен код със Swift.

## Задачи:

Дадени са следните протоколи (интерфейси):

`Visual`

```swift
    protocol Visual {
        var text: String { get }
        func render()
    }
```

`VisualComponent`

```swift

    protocol VisualComponent {
        //минимално покриващ правоъгълник
         var boundingBox: Rect { get }
         var parent: VisualComponent? { get }
        func draw()
    }
```
`VisualGroup`

```swift
    protocol VisualGroup: VisualComponent {
        //броят деца
         var numChildren: Int { get }
         //списък от всички деца
        var children: [VisualComponent] { get }
        //добавяне на дете
        func add(child: VisualComponent)
        //премахване на дете
        func remove(child: VisualComponent)
        //премахване на дете от съответния индекс - 0 базиран
        func removeChild(at: Int)
    }
```
и следните помощни структури

```swift    
    struct Point {
        var x: Double
        var y: Double
    }
    
    struct Rect {
        //top-left
        var top:Point
        var width: Double
        var height: Double
        
        init(x: Double, y: Double, width: Double, height: Double) {
            top = Point(x: x, y: y)
            self.width = width
            self.height = height
        }
    }
```
1. Да се имплементират следните класове (или структури, _по избор_):
    * `Triangle: VisualComponent, Visual `
        *     коструктор `Trinagle(a: Point, b: Point, c: Point)`
    * `Rectangle: VisualComponent, Visual `
        *     коструктор `Rectangle(x: Int, y: Int, width: Int, height: Int)`         
    * `Circle: VisualComponent, Visual `
        *  конструктор `Circle(x: Int, y:Int, r: Double)`
    *  `Path: VisualComponent, Visual `
        *  конструктор `Path(points: [Point])`
    * `HGroup: VisualGroup, Visual `
        *  конструктор `HGroup()`
    * `VGroup: VisaulGroup, Visual `
        *  конструктор `VGroup()`

2.  Да се напише функция, която намира най-малкия покриващ правоъгълник на `VisualComponent`.

    ```swift
    func cover(root: VisualComponent?) -> Rect
    ```    
        
    Пример:
    
        Ако    
        root = 
            HGroup
                VGroup
                    Circle (x:0, y:0, r:1)
        тогава
        cover(root: roоt) трябва да оцени до Rect(x: -1, y: 1, width: 2, height: 2)

3. Да се имплементира шаблонен свързан списък със съответния интерфейс. 
```swift 
    class List<T> {
        var value: T
        var next: List<T>?
    }

    extension List {
        subscript(index: Int) -> T? {
        //TODO: implementation
        }
    }

    extension List {
        var length: Int {
        //TODO: implementation
        }
    }

    extension List {
        func reverse() {
        //TODO: implementation
        }
    }
```
4. Да се имплемнтира функция, която от списък от вложени списъци (може да решите задачата и за произволно ниво на влагане) генерира списък с всички елементи.

```swift 
        extension List {
            func flatten() -> List {
            //TODO: implementation
            }
        }
```
Пример:
```swift 
    List<Any>(List<Int>(2, 2), 21, List<Any>(3, List<Int>(5, 8))).flatten()

    List(2, 2, 21, 3, 5, 8)
```
