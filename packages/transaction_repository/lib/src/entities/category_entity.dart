class CategoryEntity {
  String categoryId;
  String name;
  String icon;
  String type;
  double maxAmount;
  int color;

  CategoryEntity({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.type,
    required this.maxAmount,
    required this.color
  });

  Map<String, Object> toDocument(){
    return{
      'categoryId': categoryId,
      'name': name,
      'icon': icon,
      'type': type,
      'maxAmount': maxAmount,
      'color': color
    };
  }

  static CategoryEntity fromDocument(Map<String, dynamic> doc){
    return CategoryEntity(
      categoryId: doc['categoryId'], 
      name:  doc['name'],
      icon:  doc['icon'], 
      type: doc['type'],
      maxAmount: doc['maxAmount'],
      color:  doc['color']
    );
  }
}