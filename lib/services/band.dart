import 'package:band_names/models/band.dart';
import 'package:flutter/material.dart';

class BandService with ChangeNotifier {
  List<Band> _bands = [];

  List<Band> get bands => this._bands;

  set bands(List<dynamic> newBands) {
    this._bands = [];
    newBands.forEach((band) {
      var newBand =
          Band(id: band['_id'], name: band['name'], votes: band['votes']);
      this._bands.add(newBand);
    });
    notifyListeners();
  }
}
