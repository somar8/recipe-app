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

  test('a name always gets the same colour', () {
    expect(colorIndexFor('Breakfast'), colorIndexFor('breakfast'));
    expect(colorIndexFor('Breakfast'), inInclusiveRange(0, 5));
  });
}
