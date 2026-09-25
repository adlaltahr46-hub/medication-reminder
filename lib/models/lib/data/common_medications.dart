class CommonMedication {
  final String name;
  final String defaultDosage;

  const CommonMedication(this.name, this.defaultDosage);
}

const List<CommonMedication> commonMedications = [
  CommonMedication('باراسيتامول', 'حبة واحدة'),
  CommonMedication('إيبوبروفين', 'حبة واحدة'),
  CommonMedication('أموكسيسيلين', 'كبسولة واحدة'),
  CommonMedication('فيتامين د', 'حبة واحدة'),
  CommonMedication('فيتامين ب12', 'حبة واحدة'),
  CommonMedication('أوميغا 3', 'كبسولة واحدة'),
  CommonMedication('أسبرين', 'حبة واحدة'),
  CommonMedication('ميتفورمين', 'حبة واحدة'),
  CommonMedication('أتورفاستاتين', 'حبة واحدة'),
  CommonMedication('أوميبرازول', 'كبسولة واحدة'),
  CommonMedication('لوسارتان', 'حبة واحدة'),
  CommonMedication('سيتيريزين', 'حبة واحدة'),
];
