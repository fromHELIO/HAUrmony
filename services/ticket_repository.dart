import 'package:flutter/foundation.dart';
import '../models/ticket.dart';

class TicketRepository {
  TicketRepository._();
  static final TicketRepository instance = TicketRepository._();

  final ValueNotifier<List<Ticket>> ticketsNotifier = ValueNotifier<List<Ticket>>([]);

  List<Ticket> get all => List.unmodifiable(ticketsNotifier.value);

  void add(Ticket t) => ticketsNotifier.value = [t, ...ticketsNotifier.value];
  void remove(Ticket t) {
    final list = List<Ticket>.from(ticketsNotifier.value)..remove(t);
    ticketsNotifier.value = list;
  }
  void clear() => ticketsNotifier.value = [];
}