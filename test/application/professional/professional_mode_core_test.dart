import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/application/professional/professional_mode_core.dart';

void main() {
  BirthProfile profile(String id,String name)=>BirthProfile(id:id,displayName:name,birthInstantUtc:DateTime.utc(1990,1,1,12),latitude:36.88,longitude:30.70,timeZoneId:'Europe/Istanbul');

  test('simple mode remains simple and cannot open professional workspace',(){
    const access=ProfessionalAccessPolicy(mode:ExperienceMode.simple,isPro:true);
    expect(access.simpleExperience,isTrue); expect(access.professionalToolsVisible,isFalse);
    expect(()=>ProfessionalWorkspace(role:ProfessionalRole.astrologer,clients:const [],settings:ProfessionalCalculationSettings(houseSystem:HouseSystem.wholeSign,aspectOrbDegrees:6,ayanamshaId:'lahiri',nodeMethod:NodeMethod.trueNode),access:access),throwsStateError);
  });

  test('PRO professional workspace stores multiple profiles notes tags analyses and transit history',(){
    final c=ProfessionalClient(id:'c1',displayName:'Ada',profiles:[profile('p1','Ada natal'),profile('p2','Ada alternate')],notes:[ClientNote(id:'n1',body:'follow up',createdAtUtc:DateTime.utc(2026,9,7))],tags:const ['vip','career'],analyses:[AnalysisRecord(id:'a1',kind:'natal',resultRef:'manifest:natal-1',createdAtUtc:DateTime.utc(2026,9,7))],transitHistory:[TransitRecord(id:'t1',targetInstantUtc:DateTime.utc(2027,1,1),resultRef:'manifest:transit-1')]);
    final w=ProfessionalWorkspace(role:ProfessionalRole.astrologer,clients:[c],settings:ProfessionalCalculationSettings(houseSystem:HouseSystem.placidus,aspectOrbDegrees:7,ayanamshaId:'lahiri',nodeMethod:NodeMethod.meanNode),access:const ProfessionalAccessPolicy(mode:ExperienceMode.professional,isPro:true));
    expect(w.searchClients('career').single.id,'c1'); expect(w.searchClients('alternate').single.id,'c1'); expect(c.profiles.length,2); expect(c.analyses.single.resultRef,'manifest:natal-1'); expect(c.transitHistory.single.targetInstantUtc.year,2027);
  });

  test('synastry requires two distinct stored profiles',(){
    final c=ProfessionalClient(id:'c1',displayName:'Clients',profiles:[profile('p1','One'),profile('p2','Two')],notes:const [],tags:const [],analyses:const [],transitHistory:const []);
    final w=ProfessionalWorkspace(role:ProfessionalRole.astrologer,clients:[c],settings:ProfessionalCalculationSettings(houseSystem:HouseSystem.equal,aspectOrbDegrees:5,ayanamshaId:'fagan-bradley',nodeMethod:NodeMethod.trueNode),access:const ProfessionalAccessPolicy(mode:ExperienceMode.professional,isPro:true));
    final pair=w.synastryPair('p1','p2'); expect(pair.left.id,'p1'); expect(pair.right.id,'p2'); expect(()=>w.synastryPair('p1','p1'),throwsArgumentError);
  });

  test('invalid calculation settings and duplicate identities fail closed',(){
    expect(()=>ProfessionalCalculationSettings(houseSystem:HouseSystem.koch,aspectOrbDegrees:0,ayanamshaId:'lahiri',nodeMethod:NodeMethod.trueNode),throwsArgumentError);
    expect(()=>ProfessionalClient(id:'c1',displayName:'A',profiles:[profile('p1','One'),profile('p1','Duplicate')],notes:const [],tags:const [],analyses:const [],transitHistory:const []),throwsArgumentError);
  });

  test('professional result tables carry already-computed rows without calculation logic',(){
    final t=ProfessionalResultTables(rawDegreeRows:const ['Sun 10.0'],aspectRows:const ['Sun trine Moon'],transitTimelineRows:const ['2026-09-07 transit']);
    expect(t.rawDegreeRows.single,'Sun 10.0'); expect(t.aspectRows.length,1); expect(t.transitTimelineRows.length,1);
  });
}
