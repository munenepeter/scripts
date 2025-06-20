#include <stdio.h>
#include <string.h>

typedef struct {
    char street[100];
    char city[50];
    char country[50];
} Address;

typedef struct {
    char name[50];
    Address work_address;
    int employee_id;
} Employee;

void print_employee_details(Employee *employee){
    printf("Name: %s\n", employee->name);
    printf("Address: street: %s, city: %s, country: %s\n", employee->work_address.street, employee->work_address.city, employee->work_address.country);
    printf("ID: %d\n", employee->employee_id);
}

int main() {
    // TODO:
    // 1. Create an Employee struct
    Employee employee1;
    // 2. Populate all fields of the employee, including nested address
    strcpy(employee1.name, "Eljones");
    strcpy(employee1.work_address.street, "Mpesi");
    strcpy(employee1.work_address.city, "Nairobi");
    strcpy(employee1.work_address.country, "Kenya");
    employee1.employee_id = 23;
    // 3. Print out complete employee details including full address
    print_employee_details(&employee1);
    return 0;
}