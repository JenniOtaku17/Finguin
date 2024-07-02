part of 'delete_category_bloc.dart';

sealed class DeleteCategoryEvent extends Equatable {
  const DeleteCategoryEvent();

  @override
  List<Object> get props => [];
}

class DeleteCategory extends DeleteCategoryEvent {
  final Category category;

  const DeleteCategory(this.category);

  @override
  List<Object> get props => [category];
}