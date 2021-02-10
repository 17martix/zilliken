import 'Person.dart';
import 'addition.dart';

void main() {
  int nombre1 = 2;
  int nombre2 = 10;
  int abc = addition(nombre1, nombre2);
  int mult = abc * 3;
  double div = division(6);
  //int resultat = nombre1 + nombre2;
  //String text = "Le resultat est ";
  //print("${text.toString} ${resultat}");

  Person soso = Person(nombre: 20);
  soso.multiplication(5);
}

double division(int b) {
  int a = 6;
  double division = a / b;
  return division;
}
