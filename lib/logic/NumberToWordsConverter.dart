import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Function to convert number to words
class NumberToWordsConverter {
  static String convert(int number) {
    if (number == 0) return 'Zero';

    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];

    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    const thousands = ['', 'Thousand', 'Million', 'Billion', 'Trillion'];

    String result = '';
    int index = 0;

    while (number > 0) {
      if (number % 1000 != 0) {
        result = _convertHundreds(number % 1000) +
            (thousands[index] != '' ? ' ${thousands[index]}' : '') +
            ' ' +
            result;
      }
      number ~/= 1000;
      index++;
    }

    return result.trim();
  }

  static String _convertHundreds(int number) {
    const ones = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];

    const tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    String result = '';

    if (number >= 100) {
      result += ones[number ~/ 100] + ' Hundred ';
      number %= 100;
    }

    if (number >= 20) {
      result += tens[number ~/ 10] + ' ';
      number %= 10;
    }

    if (number > 0) {
      result += ones[number] + ' ';
    }

    return result;
  }
}


