import 'package:equatable/equatable.dart';

class ReviewEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class FetchReviewEvent extends ReviewEvent{
  final userId;
  final productId;
  final pageNo;
  FetchReviewEvent(this.userId,this.productId,this.pageNo);
  @override
  List<Object> get props => [userId,productId,pageNo];
  
}

class LoadMoreReviewEvent extends ReviewEvent{

}