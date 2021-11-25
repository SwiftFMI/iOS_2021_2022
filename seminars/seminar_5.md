## Семинар 5 - UITableView/UICollectionView

## Задача 1:

На следният път `files/EmailModel.swift`, в това репозитори, ще намерите swift файл, който имитира списъка от съобщения в Mail клиента на iOS. Създайте проект с едни ViewController, който да е максимално близък до картинката долу. 

За да решите задача изпозлвайте `UITableView`.

![задача 1](assets/seminar_5_example.png)

## Задача 2:

За да решите задачата използвайте `UICollectionView`.

## Задача 3:

За да направи галерия от картинки по три на ред. За целта използвайте `UICollectionView`.
На следния път `files/images` ще намерите картинки и `.json` файл, който ги описва.

Може да ползвате парсване от рода:
```swift
let JSON = """

"""//тук пействате всичко от JSON-а
let jsonData = JSON.data(using: .utf8)!
let images: [ImageDescriptor] = try! JSONDecoder().decode([ImageDescriptor].self, from: jsonData)
print(images.count)
```