#Networking - работа с данни от "мрежата"

В тази лекция ще обсъдим как можете да използвате URLSession, класове и функции, за да правите HTTP GET и POST мрежови заявки. Ще валидираме данните от отговорите ще разгледаме как се предават параметри.

Почти всяко iOS приложение комуникира с интернет в даден момент.

Извличането и изтеглянето на данни от и към уеб услуги е нещо, което всеки прагматичен iOS програмист трябва да овладее, а URLSession предлага първокласен API за отправяне на мрежови заявки.

Ще разгледаме и новостите от Swift 5.5 за асинхронно изпълнение на код.

##Как работи отправянето на HTTP заявки в iOS

Да си представим, че правим Twitter приложение. Потребителят ще иска да разглежда стената си, като за целта ще трябва да достъпим данни за неговите постове.

Приложно-програмния интерфейс (API) на Twitter е уебуслуга, която отговаря на HTTP(S) заявки. За отправянето на такива заявки в нашето iOS приложение използваме URLSession класа. Той всъщност е само една част от група класове и функции, които работят заедно за отправянето и обработването на заявки към уебуслуги.

Съществуват и външни библиотеки като Alamofire, но URLSession ни е повече от достатъчен.

Поглед отгоре как се работи с URLSession:

* Използваме URLSession инициализаторите за създаване на инстация или "уебсесия". Може да си правим аналог с уеб браузър приложение, като сесията е прозорец, който групира много табове (HTTP(s) заявки).
* URLSession се използав за създаването на URLSessionTask обекти, чрез които можем да теглим данни от чрез уеб услуги, да сваляме или пък качваме файлове.
* За конфигурирането на URLSession пък използваме URLSessionConfiguration обект. Тази конфигурация управлява кеширането, бисквитки, интернет свързаността и данни като пароли и други.
* За да отправим заявка, създаваме "задача" - URLSessionDataTask, която конфигурираме с URL, като например https://twitter.com/api/, и кложър*, с който да обработим отговора.
* Когато кложърът* бива извикат, можем да инспектираме данните и да предприемем действия и обновим потребитлеския интерфейс (като например зареждането на списък).

Използваме една инстанция на URLSession, за да отправяме множество последователни заявки/задачи - URLSessionTask. Една задача (URLSessionTask) винаги е част от сесията, която от своя страна играе ролята на "фабрика" за задачи и изпълнението им на базата на входните параметри, които подаваме.

Различаваме три различни задачи (URLSessionTask), създавани от една сесия (URLSession):

* За данни - URLSessionDataTask, използвайки Data обекти. Тези са най-често използваните, когато работим с JSON.
* За качване на файлове към уеб сървър - URLSessionUploadTask. Подобни на задачите за данни, но инстанциите на URLSessionUploadTask могат да качват данни и докато нашето приложение е на заден режим (background/suspended).
* За сваляне на файлове от уеб сървър - URLSessionDownloadTask. Може да следим прогресът, да ги паузираме и подновяваме.

Създаването на URLSession инстация става по следния начин:

```swift
// Конфигурация по подразбиране: кеширане на данните и бисквитките на диска. Може да се достъпят и от други сесии
let config = URLSessionConfiguration.default
let session = URLSession(configuration: config)
``` 

[URLSessionConfiguration](https://developer.apple.com/documentation/foundation/urlsessionconfiguration) има три типа:

1. **.default** - По подразбиране. Данните и бисквитките се кешират на диска, а паролите в Keychain
1. **.background** - Позволява работата на сесията дори в заден режим (background mode).
1. **.ephemeral** - Подобно на отварянето на Инкогнито таб в браузъра, кешът, бисквитките и паролите се помнят само докато сесията е "жива"

Чрез конфигурацията можем да задаваме и параметри като изчакване, политика за кеширане и др.

```swift
let config = URLSessionConfiguration.default
config.httpAdditionalHeaders = ["User-Agent":"Swift FMI", "Authorization" : "Bearer key20212022"]
config.timeoutIntervalForRequest = 30
// Използвай данните, кеширани на диска и отправи заявка само ако липсват
config.requestCachePolicy = .returnCacheDataElseLoad //NSURLRequest.CachePolicy.returnCacheDataElseLoad
```

Различните политики за кеширане може да откриете [в документацията](https://developer.apple.com/documentation/foundation/nsurlrequest/cachepolicy).

###URLSessionTask
Отправяне на GET заявки, използвайки URLSession:

```swift
let config = URLSessionConfiguration.default
let session = URLSession(configuration: config)
let url = URL(string: "https://httpbin.org/anything")! // Не всеки String е валиден URL

let task = session.dataTask(with: url) { data, response, error in
    // Уверяваме се, че отговорът от HTTP заявката не е грешка
    if let error = error {
        print ("error: \(error)")
        return
    }
	
    // Уверяваме се, че сървърът е върнал данни
    guard let content = data else {	
        print("No data")
        return
    }
	
    // Сериализираме данните (Data) като Dictionary<String, Any>
    guard let json = (try? JSONSerialization.jsonObject(with: content, options: [])) as? [String: Any] else {
        print("Not JSON")
        return
    }
	
    print("отговор \n \(json)")
    //...
}

// Изпълнява се самата HTTP заявка чрез извикването на "resume". Често се забравя.
task.resume()
```

`session.dataTask(with: url)` функцията изпълнява GET заявка към даден url и извиква своя completion кложър, когато получи отговор от сървъра - `({ data, response, error in })`. Този отговор може да се състои от грешка, очакваните или неочаквани данни.

Създадената задача изпълняваме чрез извикване на `resume` функцията.

#####!!!Използваме JSONSerialization за сериализация, но това не е за предпочитане. Swift е строго типизиран език!!!

Отправяне на POST заявки, използвайки URLSession:

```swift
let config = URLSessionConfiguration.default
let session = URLSession(configuration: config)
let url = URL(string: "https://httpbin.org/anything")!

var urlRequest = URLRequest(url: url)
urlRequest.httpMethod = "POST" // GET по подразбиране

// Параметрите за нашата POST заявка
let postDict: [String: Any] = ["email": "swift.fmi@gmial.com",
                                "handle": "SwiftFMI"]

guard let postData = try? JSONSerialization.data(withJSONObject: postDict, options: []) else {
    return
}

urlRequest.httpBody = postData // Изпращаме параметрите си като "raw data"

let task = session.dataTask(with: urlRequest) { data, response, error in
    // Уверяваме се, че отговорът от HTTP заявката не е грешка
    if let error = error {
        print ("error: \(error)")
        return
    }
	
    // Уверяваме се, че сървърът е върнал данни
    guard let content = data else {	
        print("No data")
        return
    }
	
    // Сериализираме данните (Data) като Dictionary<String, Any>
    guard let json = (try? JSONSerialization.jsonObject(with: content, options: .mutableContainers)) as? [String: Any] else {
        print("Not JSON")
        return
    }
	
    print("отговор \n \(json)")
}

// Изпълнява се самата HTTP заявка чрез извикването на "resume". Често се забравя.
task.resume()
```

За да изпълним заявка към уеб съвръв, различна от GET, трябва да създадем URLRequest обект и да зададем неговия httpMethod. В случая използваме POST като правим `urlRequest.httpMethod = "POST"`. Може също да задаваме PUT, DELETE и т.н.

Конвертираме данните, които искаме да изпратим към сървъра, в JSON формат, използвайки `JSONSerialization`. Това е остарял похват и по-долу ще разгледаме неговата алтернатива.

Добавяме конвертираните данни към тялото(httpBody) на нашия обект и изпращаме към сървъра.

Създаваме "задача" чрез `urlSession.dataTask(with: request)`.

Отново обработваме отговора, получен от сървъра, в completion кложъра - `({ data, response, error in })`. 

Създадената задача изпълняваме чрез извикване на `resume` функцията.

###Споделена URLSession

URLSession.shared, подбно на UIApplication.shared, е сингълтън инстанция, която използваме за изпълнението на прости GET / POST / PUT / DELETE заявки. Вместо да създаваме сесия, използваме:

```swift
let taskA = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
...
}

let taskB = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
...
}
```

Трябва да се стараем винаги да преизползваме сесията, за да пестим памет и трафик. Също като един браузър прозорец (сесията) и много отворени табове (задачите/заявките), вместо прозорци за всеки таб.

## JSON
JSON, или JavaScript Object Notation, е текстово базиран отворен стандарт създаден за човешки четим обмен на данни. Произлиза от скриптовия език JavaScript, за да представя прости структури от данни и асоциативни масиви, наречени обекти. Въпреки своята връзка с JavaScript, това е езиково независима спецификация, с анализатори, които могат да преобразуват много други езици в JSON.

Форматът на JSON често е използван за сериализация и предаване на структурирани данни през Интернет връзка. Използва се главно, за да предаде данни между сървър и Интернет приложение, изпълнявайки функциите на алтернатива на XML.

Базовите типове данни на JSON са Number(число), String(символен низ), Boolean (true/false), Array(списък, записва се с квадратни скоби, елементите са разделени със запетая), Object (записва се с къдрави скоби, неопределена колекция от двойки ключ-стойност, които се разделят с ":", елементите са разделени със запетая) и null (празна стойност).

### JSON примери
```json
{
    "name": "Ivancho",
    "id": 1,
    "favoriteToy": {
        "name":"Robot"
    }
}
```

```json
{
    "firstName": "John",
    "lastName": "Smith",
    "age": 25,
    "address": {
        "streetAddress": "21 2nd Street",
        "city": "New York",
        "state": "NY",
        "postalCode": "10021"
    },
    "phoneNumber": [
        {
            "type": "home",
            "number": "212 555-1234"
        },
        {
            "type": "fax",
            "number": "646 555-4567"
        }
    ]
}
```

## Codable
Преди Swift 4, за да сериализираме някой обект, той трябваше да е наследник на `NSObject` (Objective-C клас) и да имплементира `NSCoding` протокола, а за типове като `struct` и `enum` се използваха различни хакове.
В Swift 4 е добавена сериализация на всички наименовани типове - структури, изборени типове и класове.

```swift
struct FoodLog: Codable {
    enum Food: String, Codable {
        case doner, pizza, tarator
    }
    
    var day: Int
    var eaten: [Food]
}

// Съставяме си дневник от храни
let log = FoodLog(day: 1, eaten: [.doner, .tarator])
```

От горния пример виждаме, че за да имплементираме `Encodable` и `Decoadable` протоколите е нужно всички член данни на типа да имплементират тези два протокола. Именно чрез тези два протокола можем да архивираме и сериализираме нашите типове. Самата сериализация се извършва от обект от тип `JSONEncoder`. Той автоматично сериализира нашата инстнация в JSON обект.


```swift
import Foundation 

let jsonEncoder = JSONEncoder() // Един от вградените сериализатори

// Сериализираме данните
let jsonData = try jsonEncoder.encode(log)
// Създаваме символен низ от сериализираните данни
let jsonString = String(data: jsonData, encoding: .utf8) // "{"day":1,"eaten":["doner","tarator"]}"
```

Обратния процес - десериализация се извършва от `JSONDecoder` класа.

```swift
let jsonDecoder = JSONDecoder() // Противоположният поцес на JSONEncoder

// Опитваме се да десериализираме данните от по-горе
let decodedLog = try jsonDecoder.decode(FoodLog.self, from: jsonData)
decodedLog.day         // 1
decodedLog.eaten // [doner, tarator]
```

##async/await и нововъведенията в swift 5.5

###async/await
Несъмнено сте чували хора да използват термини като асинхронност и конкурентно изпълнение на код. Пример за асинхронност е изпълнението на заявка към уеб сървър и изчакването на отговора. Също вероятно сте чували за async/await в други програмни езици. Със Swift 5.5 са въведени тези запазени думи, които инструктират компилатора, че това е блок от код, който ще трябва да се изпълни асинхронно.

Да предположим, че имаме функция, която изпълнява тежка задача. Или понеже става въпрос за мрежови заявки - отправя заявка към уеб сървър и чакаме отговора. Маркираме функцията с `async`:

```swift
func doSomethingHeavy() async {
	//so heavy
}

func makeNetworkCall() async {
	//twitter.com -> get posts
}
```


Асинхронната функия е специален вид функция, която може да блокира по време на изпълнението си. Както и нормалните функции във Swift, може да връща резултат или дори да хвърля грешки:

```swift
func performThrowingHeavyTask() async throws -> String {
    
    // Run some heavy tasks here...
    
    return ""
}
```

Ако една функция е маркирана като асинхронна чрез `async`, то следва да я извикаме със запазената дума `await`:

```swift
await makeNetworkCall()
```

Запазената дума `await` означава, че функцията `makeNetworkCall()` може да блокира изпълнението си поради асинхронния си характер. Ако опитаме да извикаме `makeNetworkCall ()`, както и обикновена функция, то компилаторът ще възникне грешка при компилирането.

```
`async` call in function that does not support concurrency
```

Тъй като за изпълнението на асинхронен код е необходим асинхронен контекст, извикващата функция също трябва да е маркирана като async. За да извикаме такава функция от синхронен контекст, изполваме Task

```swift
func callAsync() {
    Task {
        await makeNetworkCall()
    }
}
```

Изпълнението на асинхронен код чрез async/await изисква използването на [Task](https://developer.apple.com/documentation/swift/task) и/или Actors.

Повече за тях може да прочетете на [https://developer.apple.com/documentation/swift/swift_standard_library/concurrency](https://developer.apple.com/documentation/swift/swift_standard_library/concurrency)

###Използване на CheckedContinuation за използване на async/await вместо кложъри

####Пример за използването на URLSession за отправяне на заявки към iTunes API

В долния пример е изпълнена част от приложение за показване на албумите на изпълнител в таблица (UITableView) или колекция (UICollectionView)

```swift
// Моделите според очакваните данни, имплементиращи Decodable протокола (по подразбиране)
struct ITunesResult: Decodable {
    let results: [Album]
}

struct Album: Decodable, Hashable {
    let collectionId: Int
    let collectionName: String
    let collectionPrice: Double
}

// Абстрация около URLSession, служеща за енкапсулиране на логиката по отправяне на заявки и обработка на данните
struct AlbumsFetcher {
    enum AlbumsFetcherError: Error {
        case invalidURL
        case missingData
    }
    
    static func fetchAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        
        // Създаваме URL обект от символен низ. Използваме query параметри според документацията
        guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=album") else {
            completion(.failure(AlbumsFetcherError.invalidURL))
            return
        }
        
        // Създаваме задача за отправяне на заявката
        URLSession.shared.dataTask(with: url) { data, _, error in
            // Проверка за грешка
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Валидиране на данните
            guard let data = data else {
                completion(.failure(AlbumsFetcherError.missingData))
                return
            }
            
            // Десериализация чрез Decodable
            do {
                // Прочитане на JSON данните
                let iTunesResult = try JSONDecoder().decode(ITunesResult.self, from: data)
                completion(.success(iTunesResult.results))
            } catch {
                completion(.failure(error))
            }
            
        }.resume() // Да не забравяме извикването на resume!
    }
}
```

Използването в контролера става по следния начин:

```swift
///...
AlbumsFetcher.fetchAlbums { [weak self] result in
    switch result {
    case .success(let albums):
        // Обновяваме потребителския интерфейс винаги в главната нишка!
        DispatchQueue.main.async {
            // Презареждаме данните
            reloadCollectionView(albums) //reloadTableView(albums)
        }
        
    case .failure(let error):
        print("Error: \(error)")
    }
}
```
Да обърнем внимание на `reloadCollectionView/reloadTableView` функцията, която е помощна функция. Тя се извиква, за да обнови списъка с албумите, които показваме на потребителя, според върнатия масив от заявката. ***_Извикването на UI функциите задължително трябва да е на главната нишка_***.

Дотук използвахме "традиционния" стил на имплементиране на мрежви заявки. Да видим как може да използваме новите async/await.

####CheckedContinuation

CheckedContinuation е нов механизъм в Swift 5.5, който може да ни помогне за изпълнението на асинхронен код от синхронен. Използваме CheckedContinuation чрез фукнцията `withCheckedThrowingContinuation(function:_:)` или `withCheckedContinuation(function:_:)`.

Тъй като изпълнението на заявката може да върне грешка, трябва да използваме "хвърлящия" вариант на функцията:

```swift
static func fetchAlbumWithContinuation() async throws -> [Album] {
    // "Мостът" между синхронния и асинхронния код чрез CheckedContinuation
    let albums: [Album] = try await withCheckedThrowingContinuation({ continuation in
        // Асинхронен контекст за извикването на `fetchAlbums(completion:)` функцията, която работи с кложъри
        fetchAlbums { result in
            switch result {
            case .success(let albums):
                // Продължаваме с върнатите и обработени албуми
                continuation.resume(returning: albums)
                
            case .failure(let error):
                // Продължаваме, хвърляйки грешка
                continuation.resume(throwing: error)
            }
        }
    })
    
    // Връщаме албумите
    return albums
}
```

Функцията `withCheckedThrowingContinuation(function:_:)` има кложър параметър, който от своя страна приема "continuation" параметър, с който работим в тялото на кложъра. Създава асинхронен Task, който изпълнява `fetchAlbums(completion:)` функцията за да отправи заявка към уеб сървъра асинхронно.

Трябва да отбележим няколко важни неща:

1. Функцията `withCheckedThrowingContinuation(function:_:)` е дефинирана като `async`, затова се извиква чрез запазената дума `await`. В допълнение ползваме `try`, защото използваме "хвърлящия" вариант на `CheckedContinuation` (обозначена е като throws). Също като синхронна хвърляща функция.
1. Извикваме функцията `resume` само веднъж за всяко разклонение на асинхронната задача - грешка или валиден резултат. При повече от едно извикване на resume, поведението е непредсказуемо. Ако пък никога не извикаме `resume`, нашата асинхронна задача ще "зависне" без край (continuation leak).
1. Връщания тип на `withCheckedThrowingContinuation(function:_:)` трябва да съвпада с типа на `resume(returning:)` - масив от Album обекти - `[Album]`.

Самото извикване в контролера се извършва по слединя начин:

```swift
// Дефинираме асинхронен контекст чрез Task
Task {
    do {
        // Използваме try await, защото нашата функция е дефинирана като хвърляща и асинхронна
        let albums = try await AlbumsFetcher.fetchAlbumWithContinuation()
        
        // Презареждаме данните
        reloadCollectionView(albums) //reloadTableView(albums)
    } catch {
        print("Error: \(error)")
    } 

}
```

Забележете, че връщането в главната нишка става автоматично, тъй като нашият контролер е обявен за `MainActor`.

####async и URLSession

Със Swift 5.5, освен добавянето на async и await запазените думи keywords, Епъл обновяват и URLSession класа, за да ги поддържа.

Добавена е нова функция `data(url:)`, която е еквивалент на "традиционната" `dataTask(with:completionHandler:)`, използвана по-рано. Това е хвърляща асинхронна функция (async throws), която връща n-торка (tuple) с данните и URLRespons обект (обикновено игнориран в най-простите случаи). Ето как става отправянето на GET заявка:

```swift
static func fetchAlbumWithAsyncURLSession() async throws -> [Album] {
    guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=album") else {
        throw AlbumsFetcherError.invalidURL
    }

    // Използваме async варианта на функциите от URLSession, за да вземем данните
    // Функцията може да блокира изпълнението си тук
    let (data, _) = try await URLSession.shared.data(from: url)

    // Десериализираме JSON данните към обекти от нашите типове (хвърля се грешка при невъзможна сериализация поради невалидни данни)
    let iTunesResult = try JSONDecoder().decode(ITunesResult.self, from: data)
    // Връщаме резултата
    return iTunesResult.results
}
```

Извикването в контролера остава почти непроменено:

```swift
// Дефинираме асинхронен контекст чрез Task
Task {
    do {
        // Използваме try await, защото нашата функция е дефинирана като хвърляща и асинхронна
        let albums = try await AlbumsFetcher.fetchAlbumWithAsyncURLSession()
        
        // Презареждаме данните
        reloadCollectionView(albums) //reloadTableView(albums)
    } catch {
        print("Error: \(error)")
    } 

}
```

Използваме `CheckedContinuation` главно като помощно средство за функции, които все още не са мигрирани към новия async/await синтаксис.
