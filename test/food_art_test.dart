import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/widgets/food_art.dart';

void main() {
  test('picks an icon from words in the title', () {
    expect(foodIconFor('Fluffy pancakes'), Icons.bakery_dining);
    expect(foodIconFor('Tomato Soup'), Icons.soup_kitchen);
    expect(foodIconFor('Spaghetti carbonara'), Icons.ramen_dining);
    expect(foodIconFor('Pannenkoeken'), Icons.bakery_dining);
  });

  test('understands Dutch compound words', () {
    expect(foodIconFor('Kipsoep'), Icons.soup_kitchen);
  });

  test('does not match inside other words', () {
    expect(foodIconFor('Fried rice'), Icons.rice_bowl); // not "ice" cream
    expect(foodIconFor('Something new'), Icons.restaurant);
  });

  test('understands German and Arabic titles', () {
    expect(foodIconFor('Kartoffelsuppe'), Icons.soup_kitchen);
    expect(foodIconFor('Milchreis'), Icons.rice_bowl);
    expect(foodIconFor('Apfelkuchen'), Icons.cake);
    expect(foodIconFor('Hähnchen mit Gemüse'), Icons.eco);
    expect(foodIconFor('شوربة عدس'), Icons.soup_kitchen);
    expect(foodIconFor('كبسة الدجاج'), Icons.rice_bowl);
    expect(foodIconFor('الدجاج المشوي'), Icons.outdoor_grill);
    expect(foodIconFor('سلطة فتوش'), Icons.eco);
  });

  test('a name always gets the same colour', () {
    expect(colorIndexFor('Breakfast'), colorIndexFor('breakfast'));
    expect(colorIndexFor('Breakfast'), inInclusiveRange(0, 5));
  });
}
