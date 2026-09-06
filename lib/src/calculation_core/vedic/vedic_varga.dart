import 'vedic_engine.dart';

final class VedicVargaPlacement {
  const VedicVargaPlacement({required this.placement,required this.division,required this.divisionIndex,required this.vargaRashiIndex,required this.degreesWithinVargaRashi});
  final VedicPlacement placement; final int division; final int divisionIndex; final int vargaRashiIndex; final double degreesWithinVargaRashi;
}

final class VedicVargaChart {
  VedicVargaChart({required this.jdTt,required this.ephemerisSourceId,required this.ephemerisDataVersion,required this.ayanamshaId,required this.ayanamshaDataVersion,required this.division,required List<VedicVargaPlacement> placements}) : placements=List<VedicVargaPlacement>.unmodifiable(placements);
  final double jdTt; final String ephemerisSourceId; final String ephemerisDataVersion; final String ayanamshaId; final String ayanamshaDataVersion; final int division; final List<VedicVargaPlacement> placements;
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

  static VedicVargaChart _build({required VedicCalculationSnapshot snapshot,required int division,required int Function(int,int) mapper}) {
    _validateSnapshot(snapshot); final partSize=30.0/division; final placements=<VedicVargaPlacement>[]; final seen=<Object>{};
    for(final placement in snapshot.placements){
      if(!seen.add(placement.body)) throw StateError('Varga chart contains duplicate Graha placements.');
      final longitude=placement.siderealLongitudeDegrees; if(!longitude.isFinite||longitude<0||longitude>=360) throw StateError('Varga chart requires normalized sidereal longitudes.');
      final rashi=(longitude/30.0).floor(); final within=longitude-rashi*30.0; var part=(within/partSize).floor(); if(part>=division) part=division-1; final offset=within-part*partSize;
      placements.add(VedicVargaPlacement(placement:placement,division:division,divisionIndex:part,vargaRashiIndex:mapper(rashi,part),degreesWithinVargaRashi:offset/partSize*30.0));
    }
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
