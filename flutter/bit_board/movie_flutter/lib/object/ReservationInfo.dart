// reservation_info.dart

class ReservationInfo {
  final String movieTitle;
  final int movieId;
  final String spotName;
  final String selectTime;
  final List<String> selectedSeats;
  final int roomsId;
  final int generalCount;
  final int teenagerCount;

  ReservationInfo({
    required this.movieTitle,
    required this.movieId,
    required this.spotName,
    required this.selectTime,
    required this.selectedSeats,
    required this.roomsId,
    required this.generalCount,
    required this.teenagerCount,
  });
}
