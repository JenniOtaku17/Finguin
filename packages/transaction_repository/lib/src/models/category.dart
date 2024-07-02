import '../entities/entities.dart';

class Category {
  String categoryId;
  String name;
  String icon;
  String type;
  double maxAmount;
  int color;

  Category({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.type,
    required this.maxAmount,
    required this.color
  });

  static final empty = Category(
    categoryId: '',
    name: '',
    icon: '',
    type: '',
    maxAmount: 0,
    color: 0
  );

  CategoryEntity toEntity(){
    return CategoryEntity(
      categoryId: categoryId,
      name: name,
      icon: icon,
      type: type,
      maxAmount: maxAmount,
      color: color
    );
  }

  static Category fromEntity(CategoryEntity entity){
    return Category(
      categoryId: entity.categoryId,
      name: entity.name,
      icon: entity.icon,
      type: entity.type,
      maxAmount: entity.maxAmount,
      color: entity.color
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'],
      name: json['name'],
      icon: json['icon'],
      type: json['type'],
      maxAmount: json['maxAmount'],
      color: json['color']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'icon': icon,
      'type': type,
      'maxAmount': maxAmount,
      'color': color
    };
  }

}