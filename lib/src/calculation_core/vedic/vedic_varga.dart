import 'vedic_engine.dart';

final class VedicVargaPlacement {
  const VedicVargaPlacement({required this.placement,required this.division,required this.divisionIndex,required this.vargaRashiIndex,required this.degreesWithinVargaRashi});
  final VedicPlacement placement; final int division; final int divisionIndex; final int vargaRashiIndex; final double degreesWithinVargaRashi;
}

final class VedicVargaChart {
  VedicVargaChart({required this.jdTt,required this.ephemerisSourceId,required this.ephemerisDataVersion,required this.ayanamshaId,required this.ayanamshaDataVersion,required this.division,required List<VedicVargaPlacement> placements}) : placements=List<VedicVargaPlacement>.unmodifiable(placements);
  final double jdTt; final String ephemerisSourceId; final String ephemerisDataVersion; final String ayanamshaId; final String ayanamshaDataVersion; final int division; final List<VedicVargaPlacement> placements;
}

/// Explicit D60 sign-mapping convention.
///
/// Classical translations/implementations disagree on whether the D60 sign
/// count starts from the natal Rashi or from Aries. The engine never hides
/// that fork: callers select a convention and the default is the commonly
/// implemented count-from-natal-Rashi reading.
enum VedicShashtiamsaSignConvention { countFromNatalRashi, signIndependent }

/// Definition used by the systematic equal-Varga extension path (RC-0104).
/// Every new rule must still be backed by its own requirement evidence/tests.
final class VedicEqualVargaDefinition {
  VedicEqualVargaDefinition({required this.id,required this.division,required List<int> startRashiByNatalRashi})
      : startRashiByNatalRashi=List<int>.unmodifiable(startRashiByNatalRashi) {
    if(id.trim().isEmpty) throw ArgumentError.value(id,'id','Varga definition id is required.');
    if(division<=0) throw ArgumentError.value(division,'division','Division must be positive.');
    if(this.startRashiByNatalRashi.length!=12||this.startRashiByNatalRashi.any((v)=>v<0||v>11)) {
      throw ArgumentError.value(startRashiByNatalRashi,'startRashiByNatalRashi','Exactly twelve normalized Rashi starts are required.');
    }
  }
  final String id; final int division; final List<int> startRashiByNatalRashi;
  int map(int natalRashi,int part)=>(startRashiByNatalRashi[natalRashi]+part)%12;
}

/// Classical Parashari Varga core for RC-0092 onward.
abstract final class VedicVargaBuilder {
  static VedicVargaChart navamsaD9(VedicCalculationSnapshot s)=>_build(snapshot:s,division:9,mapper:_navamsaRashi);
  static VedicVargaChart horaD2(VedicCalculationSnapshot s)=>_build(snapshot:s,division:2,mapper:_horaRashi);
  static VedicVargaChart drekkanaD3(VedicCalculationSnapshot s)=>_build(snapshot:s,division:3,mapper:_drekkanaRashi);
  static VedicVargaChart chaturthamsaD4(VedicCalculationSnapshot s)=>_build(snapshot:s,division:4,mapper:_chaturthamsaRashi);
  static VedicVargaChart saptamsaD7(VedicCalculationSnapshot s)=>_build(snapshot:s,division:7,mapper:_saptamsaRashi);
  static VedicVargaChart dasamsaD10(VedicCalculationSnapshot s)=>_build(snapshot:s,division:10,mapper:_dasamsaRashi);
  static VedicVargaChart dwadasamsaD12(VedicCalculationSnapshot s)=>_build(snapshot:s,division:12,mapper:_dwadasamsaRashi);
  static VedicVargaChart shodasamsaD16(VedicCalculationSnapshot s)=>_build(snapshot:s,division:16,mapper:_shodasamsaRashi);
  static VedicVargaChart vimshamsaD20(VedicCalculationSnapshot s)=>_build(snapshot:s,division:20,mapper:_vimshamsaRashi);
  static VedicVargaChart chaturvimshamsaD24(VedicCalculationSnapshot s)=>_build(snapshot:s,division:24,mapper:_chaturvimshamsaRashi);

  /// RC-0102: classical Trimshamsa D30 uses five unequal spans, not thirty
  /// equal one-degree slices. `divisionIndex` therefore identifies the
  /// classical unequal span (0..4), while `division` remains the chart's D30.
  static VedicVargaChart trimshamsaD30(VedicCalculationSnapshot s) {
    _validateSnapshot(s); final placements=<VedicVargaPlacement>[]; final seen=<Object>{};
    for(final placement in s.placements){
      if(!seen.add(placement.body)) throw StateError('Varga chart contains duplicate Graha placements.');
      final longitude=placement.siderealLongitudeDegrees; if(!longitude.isFinite||longitude<0||longitude>=360) throw StateError('Varga chart requires normalized sidereal longitudes.');
      final rashi=(longitude/30.0).floor(); final within=longitude-rashi*30.0; final oddRashi=rashi.isEven;
      late final int segment; late final double start; late final double width; late final int target;
      if(oddRashi){
        if(within<5){segment=0;start=0;width=5;target=0;}
        else if(within<10){segment=1;start=5;width=5;target=10;}
        else if(within<18){segment=2;start=10;width=8;target=8;}
        else if(within<25){segment=3;start=18;width=7;target=2;}
        else {segment=4;start=25;width=5;target=6;}
      } else {
        if(within<5){segment=0;start=0;width=5;target=1;}
        else if(within<12){segment=1;start=5;width=7;target=5;}
        else if(within<20){segment=2;start=12;width=8;target=11;}
        else if(within<25){segment=3;start=20;width=5;target=9;}
        else {segment=4;start=25;width=5;target=7;}
      }
      placements.add(VedicVargaPlacement(placement:placement,division:30,divisionIndex:segment,vargaRashiIndex:target,degreesWithinVargaRashi:(within-start)/width*30.0));
    }
    return _chartFrom(s,30,placements);
  }

  /// RC-0103: D60 uses sixty 0.5-degree portions. The sign-mapping convention
  /// is explicit so a disputed classical reading can never change silently.
  static VedicVargaChart shashtiamsaD60(VedicCalculationSnapshot s,{VedicShashtiamsaSignConvention convention=VedicShashtiamsaSignConvention.countFromNatalRashi})=>_build(snapshot:s,division:60,mapper:(r,p)=>switch(convention){VedicShashtiamsaSignConvention.countFromNatalRashi=>(r+p)%12,VedicShashtiamsaSignConvention.signIndependent=>p%12});

  /// RC-0104: controlled equal-Varga extension point. This does not assert
  /// that an arbitrary definition is classical; each added definition still
  /// requires its own exact source, regression and requirement gate.
  static VedicVargaChart buildSystematicEqualVarga(VedicCalculationSnapshot s,VedicEqualVargaDefinition definition)=>_build(snapshot:s,division:definition.division,mapper:definition.map);

  static VedicVargaChart _build({required VedicCalculationSnapshot snapshot,required int division,required int Function(int,int) mapper}) {
    _validateSnapshot(snapshot); final partSize=30.0/division; final placements=<VedicVargaPlacement>[]; final seen=<Object>{};
    for(final placement in snapshot.placements){
      if(!seen.add(placement.body)) throw StateError('Varga chart contains duplicate Graha placements.');
      final longitude=placement.siderealLongitudeDegrees; if(!longitude.isFinite||longitude<0||longitude>=360) throw StateError('Varga chart requires normalized sidereal longitudes.');
      final rashi=(longitude/30.0).floor(); final within=longitude-rashi*30.0; var part=(within/partSize).floor(); if(part>=division) part=division-1; final offset=within-part*partSize;
      placements.add(VedicVargaPlacement(placement:placement,division:division,divisionIndex:part,vargaRashiIndex:mapper(rashi,part),degreesWithinVargaRashi:offset/partSize*30.0));
    }
    return _chartFrom(snapshot,division,placements);
  }

  static VedicVargaChart _chartFrom(VedicCalculationSnapshot snapshot,int division,List<VedicVargaPlacement> placements){
    placements.sort((a,b)=>a.placement.body.index.compareTo(b.placement.body.index));
    return VedicVargaChart(jdTt:snapshot.jdTt,ephemerisSourceId:snapshot.ephemerisSourceId,ephemerisDataVersion:snapshot.ephemerisDataVersion,ayanamshaId:snapshot.ayanamshaId,ayanamshaDataVersion:snapshot.ayanamshaDataVersion,division:division,placements:placements);
  }

  static int _navamsaRashi(int r,int p){final start=switch(r%3){0=>r,1=>(r+8)%12,_=>(r+4)%12}; return (start+p)%12;}
  static int _horaRashi(int r,int p){final odd=r.isEven; final sun=odd?p==0:p==1; return sun?4:3;}
  static int _drekkanaRashi(int r,int p){const o=<int>[0,4,8]; return (r+o[p])%12;}
  static int _chaturthamsaRashi(int r,int p){const o=<int>[0,3,6,9]; return (r+o[p])%12;}
  static int _saptamsaRashi(int r,int p){final start=r.isEven?r:(r+6)%12; return (start+p)%12;}
  static int _dasamsaRashi(int r,int p){final start=r.isEven?r:(r+8)%12; return (start+p)%12;}
  static int _dwadasamsaRashi(int r,int p)=>(r+p)%12;
  static int _shodasamsaRashi(int r,int p){final start=switch(r%3){0=>0,1=>4,_=>8}; return (start+p)%12;}
  static int _vimshamsaRashi(int r,int p){final start=switch(r%3){0=>0,1=>8,_=>4}; return (start+p)%12;}
  static int _chaturvimshamsaRashi(int r,int p){final start=r.isEven?4:3; return (start+p)%12;}

  static void _validateSnapshot(VedicCalculationSnapshot snapshot){
    if(!snapshot.jdTt.isFinite||snapshot.ephemerisSourceId.trim().isEmpty||snapshot.ephemerisDataVersion.trim().isEmpty||snapshot.ayanamshaId.trim().isEmpty||snapshot.ayanamshaDataVersion.trim().isEmpty||!snapshot.ayanamshaDegrees.isFinite) throw StateError('Varga chart requires explicit Vedic provenance.');
    if(snapshot.placements.isEmpty) throw StateError('Varga chart requires at least one Graha placement.');
  }
}
