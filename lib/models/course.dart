class Course {
  final String id;
  final String code;
  final String name;
  final String professor;
  final String period;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.professor,
    this.period = '2026-C-3',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'professor': professor,
        'period': period,
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] ?? '',
        code: json['code'] ?? '',
        name: json['name'] ?? '',
        professor: json['professor'] ?? '',
        period: json['period'] ?? '2026-C-3',
      );

  // Los 7 cursos oficiales vigentes (Redacción Castellana fue retirada)
  static List<Course> defaultCourses = [
    Course(
      id: 'ing001',
      code: 'ING-001',
      name: 'Inglés Nivel 1-3',
      professor: 'Sandra Polanco De Leon',
    ),
    Course(
      id: 'tds001',
      code: 'TDS-001',
      name: 'Algoritmos',
      professor: 'Jose de Jesus Alcantara',
    ),
    Course(
      id: 'ti101',
      code: 'TI-101',
      name: 'Fundamentos del Computador',
      professor: 'Gabriel Perez de los Santos',
    ),
    Course(
      id: 'his101',
      code: 'HIS-101',
      name: 'Historia Universal',
      professor: 'Ursulina Inoa Pitta',
    ),
    Course(
      id: 'cbg010',
      code: 'CBG-010',
      name: 'Educacion Constitucional',
      professor: 'Ibis Santiago Ferrerias',
    ),
    Course(
      id: 'oai001',
      code: 'OAI-001',
      name: 'Orientacion Institucional',
      professor: 'Marlen Perez Dorville',
    ),
    Course(
      id: 'mat001',
      code: 'MAT-001',
      name: 'Precalculo',
      professor: 'Antonio Rojas Taveras',
    ),
  ];
}
