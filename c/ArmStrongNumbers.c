#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

// check if a number is the sum of its own digits each raised to the power of the number of digits.
// e.g  9 = 9^1 = 9 || 10 != 1^2 + 0^2 = 1
bool is_armstrong_number(int candidate);

//calculate the power of a number ( number^n)
// e.g 1^3 = 1
int power(int base, int exponent);

// perform an operation on a number ( number)
// in this case calcuate the armstrong value of a number
int operate_on_digits(int number, int (*operation)(int, int));


int main(void)
{

    //test_zero_is_an_armstrong_number
    assert(is_armstrong_number(0));

    //test_single_digit_numbers_are_armstrong_numbers
    assert(is_armstrong_number(5));

    //test_there_are_no_two_digit_armstrong_numbers
    assert(!is_armstrong_number(10));

    //test_three_digit_number_that_is_an_armstrong_number
    assert(is_armstrong_number(153));

    //test_three_digit_number_that_is_not_an_armstrong_number
    assert(!is_armstrong_number(100));

    //test_four_digit_number_that_is_an_armstrong_number
    assert(is_armstrong_number(9474));

    //test_four_digit_number_that_is_not_an_armstrong_number
    assert(!is_armstrong_number(9475));

    //test_seven_digit_number_that_is_an_armstrong_number
    assert(is_armstrong_number(9926315));

    //test_seven_digit_number_that_is_not_an_armstrong_number
    assert(!is_armstrong_number(9926314));

    return 0;
}


int power(int base, int exponent) {
    int power = 1;
    for (int i = 0; i < exponent; i++) {
        power *= base;
    }
    return power;
}
int operate_on_digits(int number, int (*operation)(int, int)) {

    char number_str[12]; // 12 so that we can handle big numbers
    // type cast number to string
    sprintf(number_str, "%d", number);

    int sum = 0;

    int len = strlen(number_str);

    // 153 = 1^3 + 5^3 + 3^3 = 1 + 125 + 27 = 153
    for (int i = 0; i < len; i++) {
        int digit = number_str[i] - '0';
        sum += operation(digit, len);
    }
    return sum;
}

bool is_armstrong_number(int candidate) {
    return operate_on_digits(candidate, &power) == candidate;
}