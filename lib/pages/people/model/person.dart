class Person {
  Person(
      {this.name,
      this.email,
      this.phone,
      this.office,
      this.position,
      this.photo,
      this.source});

  final String name;
  final String email;
  final String phone;
  final String office;
  final String position;
  final String photo;
  final String source;

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Person) {
      return other.name == name;
    }
    return false;
  }
}
