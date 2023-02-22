
import 'package:flutter/material.dart';
import 'classFields.dart';

import'classParameterSet.dart';
import 'dart:math';

class SimulationModel {
  ParameterSet _ps;
  double _appi = 0.80 * 1.00; // Area per plant (row x interrow spacing) (m2);
  double _nsl = 3; //number of soil layers
  double _depth = 1.2; //soil depth in m
  double _lw = 0.9 / 3; //thickness of a layer in m
  double _lvol = 0.9 * (0.80 * 1.00) / 3; //volume of one soil layer
  double _rgr = 0;
  double _maxy = 1;
  double _iLA = 0;
  double _istart = 0;
  double _iend = 0;
  double _igstart = 0;
  double _igend = 0;
  double _dt = 1; // frequency of output in days
  double _itheta = 0.10;
  double _thm = 0.2;
  double _thg = 0.02; // hàm lượng nước sai lệch do trọng lượng
  double _ths = 0.32; // saturated water content     //field capacity, not saturation todo rename
  double _thr = 0.0224; // residual water content // lượng nước bị giữ lại trong đất mà cây ko hấp thụ được
  double _rateFlow = 1.3; // (Q trong công thức: lưu lượng dòng chảy)
  double _rateDrain = 3.25;
  double _drainageFactor = 1.3;
  //double _soilvolume = 900;
  List<int> _rainDays = [];
  List<double> _rain = [];
  List<int> _DAP = [];
  List<double> _th30 = [];
  List<double> _th60 = [];
  double _fcThreshHold = 0;
  double _autoIrrigate = 50;
  double _autoIrrigateTime = -1;
  double _autoIrrigationDuration = 1;
  //List<double> _irrigationDays = [0, 10, 100];
  //List<double> _irrigation = [20, 20, 20];

  static const int printSize = 51;
  bool _hasRun = false;
  List<double> _results = List<double>.filled(printSize, 0);
  List<double> _theta = List<double>.filled(printSize, 0);
  SimulationModel(ParameterSet ps) : _ps = ps;

  //thai use other units then metric
  //will only convert them once the result is requested
  static double _convfact = 1;
  static setConversionFactors(BuildContext context) {
    _convfact = 1 * ParameterNames.potentialYield.unitConv(context);
  }

  void _updateParameters() async {
    //todo get rid of code repetitions.
    var a = _ps.getSimulationParameter(ParameterNames.RGR);
    if (a != _rgr) {
      _rgr = a;
      _hasRun = false;
      //print('rgr is changed $_rgr');
    } //else {
    //print('rgr is unchanged $_rgr');
    //}
    a = _ps.getSimulationParameter(ParameterNames.potentialYield);
    if (a != _maxy) {
      _maxy = a;
      _hasRun = false;
    }
    a = _ps.getSimulationParameter(ParameterNames.iLA);
    if (a != _iLA) {
      _iLA = a;
      _hasRun = false;
    }
    a = _ps.getSimulationParameter(ParameterNames.istart);
    if (a != _istart) {
      _istart = a;
      _hasRun = false;
    }
    a = _ps.getSimulationParameter(ParameterNames.iend);
    if (a != _iend) {
      _iend = a;
      _hasRun = false;
    }
    a = Fields.getStartTime(); //global start time
    if (a != _igstart) {
      _igstart = a;
      _hasRun = false;
    }
    a = Fields.getEndTime(); //global end time
    if (a != _igend) {
      _igend = a;
      _hasRun = false;
    }
    a = _ps.getSimulationParameter(ParameterNames.fcThreshHold);
    print('a = $a');
    a *= (_ths - _thr) / 100;
    print('a5 = $a');
    a += _thr;
    print('a6 = $a');
    if ((a - _fcThreshHold).abs() > 1e-5) {
      _fcThreshHold = a;
      _hasRun = false;
      print('fcThreshHold is changed $_fcThreshHold');
    } //else {
    //print('fcThreshHold is unchanged $_fcThreshHold');
    //}
    _autoIrrigateTime = -1; //reset

    int index = 0;
    int idx = 0;
    if (num == 0) {
      for (int i = 0; i < Fields.listField.length; i++) {
        if (_rainDays.length > 0) {
          _rainDays.removeRange(0, _rainDays.length);
          _rain.removeRange(0, _rain.length);
        }
        if (_DAP.length > 0) {
          _DAP.removeRange(0, _DAP.length);
          _th30.removeRange(0, _th30.length);
          _th60.removeRange(0, _th60.length);
        }
        int k = index;
        index += Fields.numberDays[i];
        int ki = idx;
        idx += Fields.numDays[i];
        if (Fields.listField[i] == _ps.fieldName) {
          for (int j = k; j < index; j++) {
            _rainDays.add(Fields.rainDays[j]);
            _rain.add(Fields.rain[j]);
          }
          for (int p = ki; p < idx; p++) {
            _DAP.add(Fields.DAP[p]);
            _th30.add(Fields.Th30[p]);
            _th60.add(Fields.Th60[p]);
          }
          // print('karina: ${_rainDays}');
          // print('karinaa: ${_rain}');
          // print('karinaa: ${_rain.length}');
        }
      }
    }
    num++;
  }

  List<double> getResults() {
    _simulate();
    if (_convfact != 1) {
      var cr = _results.map((e) => e * _convfact);
      return cr.toList();
    } else {
      return _results;
    }
  }

  List<double> getResults2() {
    //todo implement theta simulation
    _simulate();
    return _theta; //todo this exposes theta, as the array pointer is returned
  }

  //model
  void _simulate() {
    //print( 'Simulate is called with iLA=$_iLA rgr=$_rgr istart=$_istart iend=$_iend');
    _updateParameters();
    if (_hasRun) return;
    //print('Simulating with iLA=$_iLA rgr=$_rgr istart=$_istart iend=$_iend');
    print("running simulation for ${_ps.fieldName}");

    double t = _istart;
    var w = [_iLA, _itheta];
    const double dt = 0.01;

    //todo ptime needs to be set as static member so it is the same for all fields?
    double pdt = (_igend - _igstart) / (printSize - 1);
    print('pdt=$pdt');

    var ptime = List<double>.generate(
        printSize,
            (index) =>
        _istart + index.toDouble() *
            pdt); //todo not used not checked but recalculated when generating the features
    print('ptime=$ptime');

    for (int i = 0; i < printSize; ++i) {
      if (ptime[i] < _istart - 0.5 * dt) {
        //simulation starts later
        _results[i] = 0;
        _theta[i] = 0; //theta simulation can start before planting, reimplement this.
      } else if (ptime[i] > _iend + 0.5 * dt) {
        //store simulation result
        _results[i] = 0;
        _theta[i] = 0;
      } else {
        //forward simulation

        while (t < ptime[i] - 0.5 * dt) {
          rk4Step(t, w, dt);
          t += dt;
        }
        _results[i] = w[0];
        _theta[i] = w[1];
      }
    }

    _hasRun = true;
  }

  void rk4Step(double t, List<double> y, double dt) {
    var yp =
    List<double>.from(y, growable: false); // needs to be an explicit copy
    //print('y0=$y');
    var r1 = ode(t, yp);
    var t1 = t + 0.5 * dt;
    var t2 = t + dt;
    intStep(yp, r1, 0.5 * dt);
    var r2 = ode(t1, yp);
    for (int i = 0; i < y.length; i++) yp[i] = y[i]; //reset
    intStep(yp, r2, 0.5 * dt);
    var r3 = ode(t1, yp);
    for (int i = 0; i < y.length; i++) yp[i] = y[i]; //reset
    intStep(yp, r3, dt);
    var r4 = ode(t2, yp);
    for (int i = 0; i < r4.length; i++)
      r4[i] = (r1[i] + 2 * (r2[i] + r3[i]) + r4[i]) / 6; //rk4
    //print('y1=$y');
    intStep(y, r4, dt); //final integration
    //print('y2=$y');
  }

  void intStep(final List<double> y, final List<double> r, final double dt) {
    assert(y.length == r.length);
    for (int i = 0; i < y.length; i++) {
      y[i] += dt * r[i];
    }
  }

  List<double> ode(final double t, final List<double> y) {
    var r = List<double>.filled(y.length, 0);
    var waterStress = max(0, 1 - exp((y[1] - _thr) * -40)); // cạn kiệt 40%
    r[0] = _rgr * y[0] * (1 - y[0] / _maxy) * waterStress; // sản lượng ngày đầu tiên (y[0] = ila)
    double soilVolume = _depth * _appi * 1000; // cm3

    //days after planting
    double lt = max(t - _istart, 0);

    //evapotranspiration
    double et0 = 3; //for now fixed mm/ ngày
    double cropfactor = 0.3 + 0.5 * max(lt / 45, 1); //FAO//Kc(Hệ số cây trồng)
    //0.3: hệ số cây trồng ban đầu
    //soil water content

    for (int i = 0; i < _DAP.length; i++) {
      double ti = t - _DAP[i];
      if (ti > 0 && ti < 1) {
        var th120 = _thm - _thg;
        var th90 = th120 - _thg;
        var flow36 = (_th60[i] - (_th30[i] + _thg)) * _rateFlow * (_th60[i] / _ths) -
            400 * max((_th30[i] - _ths), 0); // lưu lượng nước chảy từ lớp đất có độ sâu 30 xuống lớp 60)
        var flow69 = (th90 - (_th60[i] + _thg)) * _rateFlow * (th90 / _ths) -
            400 * max((_th60[i] - _ths), 0);
        var flow912 = (th120 - (th90 + _thg)) * _rateFlow * (th120 / _ths) -
            400 * max((_th60[i] - _ths), 0);
        var drain = (_thm - th120) * _drainageFactor - 400 * max((th120 - _ths), 0);
        var rate30 = _th30[i] - flow36;
        var rate60 = _th60[i] - flow69 + flow36;
        var rate90 = th90 - flow912 + flow69;
        var rate120 = th120 - drain + flow912;
        r[1] += (rate30 + rate60 + rate90 + rate120) / soilVolume;
      }
    }

    r[1] = r[1] - (et0 * cropfactor) / soilVolume;

    // r[1] = _drainageFactor * (_thm - y[1]); //soil capacity
    // r[1] -= 400 * max(y[1] - _ths, 0);
    // r[1] -= et0 * cropfactor / _soilvolume; //evapotranspiration

    for (int i = 0; i < _rainDays.length; i++) {
      double ti = t - _rainDays[i];
      if (ti > 0 && ti < 1) {
        //raining that day
        r[1] += _rain[i] / soilVolume;
      }
    }

    //print('karina: ${Fields.rainDays}');
    //print('karinaa: ${Fields.rain.length}');


    // for (int i = 0; i < 276; i++) {
    //   double ti = t - Fields.rainDays[i];
    //   if (ti > 0 && ti < 1) {
    //     //raining that day
    //     r[1] += Fields.rain[i] / soilVolume;
    //   }
    // }
    //print("num: $num");
    // for (int i = 0; i < _irrigationDays.length; i++) {
    //   double ti = t - _irrigationDays[i];
    //   if (ti > 0 && ti < 1) {
    //     //irrigating
    //     r[1] += _irrigation[i] / _soilvolume;
    //   }
    // }
    //auto irrigation
    //print('_autoIrrigateTime = $_autoIrrigateTime');
    //todo this only works if t only increases, should be ok with RK4
    if (_autoIrrigateTime < 0 && _fcThreshHold > _thr && y[1] < _fcThreshHold) {
      //
      _autoIrrigateTime = t;
      //print("irrigating ${_ps.fieldName} at $t");
    }
    if (_autoIrrigateTime > -0.5) {
      double it = t - _autoIrrigateTime;
      if (it >= 0 && it < _autoIrrigationDuration)
        r[1] += _autoIrrigate / soilVolume;
      if (it >= _autoIrrigationDuration) {
        if (y[1] < _fcThreshHold) {
          _autoIrrigateTime = t; // keep irrigating for another day
        } else {
          _autoIrrigateTime = -1; // stop irrigating
        }
      }
    }

    //add other ODE's
    return (r);
  }
}