## Семинар 7 - Autolayout

На следния път ```files/Autolayout``` ще намерите проект, който имитира външния вид на Control Center в iOS 10. Той е изработен така, че да изглежда добре само на iPhone 8 (и сходните резолюции) в портретен режим.

Ето и пример как изглежда на iOS 9 и iPhone 5/5S.
![задача 1](assets/seminar_7_example.png)


## Задача 1:
Добавете Autolayout constraint-и така, че да се спазят следните правила:

* Ширината на controlCenterView трябва да зависи от ширината на екрана, на който се показва, като има отстояние 20 точки по хоризонталата;
* Височината му трябва да е 50% от екрана;
* controlCenterView трябва да бъде позиционирано в долната част на екрана;
* Разстоянията между бутоните по хоризонтала трябва да е еднакво между всички, които се намират на една хоризонтална линия;
* Височината и ширината на бутоните трябва да е 50 на 50, но само един от хоризонтала може да има забити размери;
* Картинките към AirDrop и Night Shift трябва да се движат със съответните бутони, но не трябва да застъпват текста при въртене и при различни размери на екрана;
* Картинките трябва да имат забити размери 20 на 20 и 30 на 30, а слайдерът трябва да се разширява между тях, като запазва разстояние между тях от 10 точки;
* Лявата и дясната подредба на всички странични бутони и картинки трябва да е 20 точки, но трябва да зависи от до 2 view-та.

Целта е да изглежда добре на всички резолюции, като включваме и таблетите, както и в пейзажен режим.
