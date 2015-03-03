/*   Copyright (C) 2013-2014 Computer Sciences Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. */

include "EzBakeBase.thrift"

namespace * ezbake.services.geospatial.thrift
namespace py ezbake.services.geospatial.thriftapi
namespace go ezbake.services.geospatial.thriftapi

const string SERVICE_NAME = "GeospatialExtractorService"

enum GeoType {
    Dot,
    Gaussian,
    Polygon
}

/**
 * Structure representing place information.
 */
struct ConjunctType {
    1: string name;
    2: string countryCode;
    3: string countryName
    4: string countryConfidence;
    5: string province;
    6: string provinceName;
    7: string provinceConfidence;
    8: string latitude;
    9: string longitude;
    10: GeoType type;
    11: i32 population;
}

struct Language {
	1: string name;
	2: string code;
}

struct DocumentLanguage {
	2: string fallbackLanguage;
	3: string fallbackCharset;
	4: bool overrideLanguage;
	5: bool overrideCharset;
}

struct DisjunctType {
    /**
     * Expresses the latitude and longitude of the associated disjunct, as well as enclosing country and province
     * information
     */
    1: list<ConjunctType> conjuncts;
}

struct Place {
    /**
     * Strings of geographic text
     */
	1: list<string> textComponents;

	/**
	 * Potential places to which the text extent might refer
	 */
    2: list<DisjunctType> disjuncts;
}

struct TQuery {
	1: string placeName;
}

/**
 * Geographic bounding box
 */
struct TBBox {
	1: required double minLatitude;
  	2: required double maxLatitude;
  	3: required double minLongitude;
  	4: required double maxLongitude;
}

struct TCentroid {
	1: required double latitude;
  	2: required double longitude;
}

struct TCircle {
	1: TCentroid point;
  	3: required i16 radius;
}

/**
 * Location Finder API input structure. TLocationFinderInput structure should have any one of query, bbox or circle.
 */
struct TLocationFinderInput {
	1: optional TQuery query;
	2: optional TBBox bbox;
	3: optional TCircle circle;
}

/**
 * Query Parser API input structure. TQueryParserInput structure should have query. query can be a location name like
 * "Dallas" or "Houses In Maine" or "Restaurants in Dallas" so on.
 */
struct TQueryParserInput {
	1: TQuery query;
	2: optional TBBox bbox;

	/**
	 * If a query has a confidence lower than minqueryconfidence, it will not be returned. Note that this may be
	 * limited by axqueries. Allowed values: floating-point number x: 0.0 <= x <= 1.0
	 */
	3: optional double minQueryConfidence;

	/**
	 * No locations with a weight lower than minlocationweight will be returned. Note that this may be limited by
	 * maxlocations. We recommend that you use a weight of at least 0.5 in order to get maximum performance.
	 * Allowed values: floating-point number x: 0.0 <= x <= 1.0
	 */
	4: optional double minLocationWeight;
}

/**
 * Paths is an object containing information for the location. One value it will contain is ‘Administrative,’ which
 * gives administrative district data for the location.
 */
struct TPaths {
	1:list<string> administrative;
}

/**
 * Types is a dictionary providing extended descriptions for the ‘Type’ codes given for the set of location results.
 */
enum TLocationType {
	ADM1,
	ADM2,
	ADM3,
	ADM4,
	ADMD,
	ADMF,
	AGRC,
	AGRF,
	AIRB,
	AIRF,
	AIRH,
	AIRP,
	AIRQ,
	AIRS,
	AMTH,
	ANCH,
	ANS,
	APNU,
	ARCH,
	ARCU,
	AREA,
	ARRU,
	ASPH,
	ASTR,
	ASYL,
	ATHF,
	ATOL,
	BAN,
	BAR,
	BAY,
	BAYS,
	BCH,
	BCHS
	BCN,
	BDG,
	BDGQ,
	BDLD,
	BDLU,
	BGHT,
	BKSU,
	BLDG,
	BLDR,
	BLHL,
	BLOW,
	BNCH,
	BNCU,
	BNK,
	BNKR,
	BNKU,
	BNKX,
	BOG,
	BP,
	BRKS,
	BRKW,
	BSND,
	BSNP,
	BSNU,
	BSTN,
	BTL,
	BTYD,
	BUR,
	BUSH,
	BUTE,
	CAPE,
	CAPG,
	CARN,
	CAVE,
	CDAU,
	CFT,
	CH,
	CHN,
	CHNL,
	CHNM,
	CHNN,
	CLDA,
	CLF,
	CLG,
	CMN,
	CMP,
	CMPL,
	CMPLA,
	CMPMN,
	CMPO,
	CMPQ,
	CMPRF,
	CMTY,
	CNFL,
	CNL,
	CNLA,
	CNLB,
	CNLD,
	CNLI,
	CNLN,
	CNLQ,
	CNLSB,
	CNLX,
	CNS,
	CNSU,
	CNYN,
	CNYU,
	COLF,
	COMC,
	CONE,
	COVE,
	CRDR,
	CRKT,
	CRNT,
	CRQ,
	CRQS,
	CRRL,
	CRSU,
	CRTR,
	CSNO,
	CST,
	CSTL,
	CSTM,
	CSWY,
	CSWYQ,
	CTHSE,
	CTRA,
	CTRB,
	CTRCM,
	CTRF,
	CTRM,
	CTRR,
	CTRS,
	CUET,
	CULT,
	CUTF,
	CVNT,
	DAM
	DAMQ,
	DAMSB,
	DARY,
	DCK,
	DCKB,
	DCKD,
	DCKY,
	DEPU,
	DEVH,
	DIKE,
	DLTA,
	DOMG,
	DPOF,
	DPR,
	DPRG,
	DSRT,
	DTCH,
	DTCHD,
	DTCHI,
	DTCHM,
	DUNE,
	DVD,
	EDGU,
	ERG,
	ESCU,
	EST,
	ESTB,
	ESTC,
	ESTO,
	ESTR,
	ESTSG,
	ESTSL,
	ESTT,
	ESTX,
	ESTY,
	FAN,
	FANU,
	FCL
	FISH,
	FJD,
	FJDS,
	FLD,
	FLDI,
	FLLS,
	FLLSX,
	FLTM,
	FLTT,
	FLTU,
	FNDY,
	FORD,
	FRKU,
	FRM,
	FRMQ,
	FRMS,
	FRMT,
	FRST,
	FRSTF,
	FRSU,
	FRZU,
	FSR,
	FT,
	FURU,
	FY,
	GAP,
	GAPU,
	GASF,
	GATE,
	GDN,
	GHSE,
	GLCR,
	GLYU,
	GOSP,
	GRAZ,
	GRGE,
	GRSLD,
	GRVC,
	GRVE,
	GRVO,
	GRVP,
	GRVPN,
	GULF,
	GVL,
	GYSR,
	HBR,
	HBRX,
	HDLD,
	HERM,
	HLL,
	HLLS,
	HLLU,
	HLSU,
	HLT,
	HMCK,
	HMDA,
	HOLU,
	HSE,
	HSEC,
	HSP,
	HSPC,
	HSPD,
	HSPL,
	HSTS,
	HTH,
	HTL,
	HUT,
	HUTS,
	INDS,
	INLT,
	INLTQ,
	INSM,
	INTF,
	ISL,
	ISLF,
	ISLM,
	ISLS,
	ISLT,
	ISLX,
	ISTH,
	ITTR,
	JTY,
	KNLU,
	KNSU,
	KRST,
	LAND,
	LAVA,
	LBED,
	LCTY,
	LDGU,
	LDNG,
	LEPC,
	LEV,
	LEVU,
	LGN,
	LGNS,
	LGNX,
	LK,
	LKC,
	LKI,
	LKN,
	LKNI,
	LKO,
	LKOI,
	LKS,
	LKSB,
	LKSC,
	LKSI,
	LKSN,
	LKSNI,
	LKX,
	LNDF,
	LOCK,
	LTER,
	LTHSE,
	MAR,
	MDVU,
	MDW,
	MESA,
	MESU,
	MFG,
	MFGB,
	MFGC,
	MFGCU,
	MFGLM,
	MFGM,
	MFGN,
	MFGPH,
	MFGQ,
	MFGSG,
	MGV,
	MILB,
	MKT,
	ML,
	MLM,
	MLO,
	MLSG,
	MLSGQ,
	MLSW,
	MLWND,
	MLWTR,
	MN,
	MNA,
	MNAU,
	MNC,
	MNCR,
	MNCU,
	MND,
	MNDT,
	MNDU,
	MNFE,
	MNMT,
	MNN,
	MNNI,
	MNPB,
	MNPL,
	MNQ,
	MNQR,
	MNSN,
	MOLE,
	MOOR,
	MOTU,
	MRN,
	MRSH,
	MRSHN,
	MSQE,
	MSSN,
	MSSNQ,
	MSTY,
	MT,
	MTS,
	MTSU,
	MTU,
	MUS,
	MVA,
	NKM,
	NOV,
	NRWS,
	NSY,
	NTK,
	NTKS,
	NVB,
	OAS,
	OBPT,
	OBS,
	OBSR,
	OCH,
	OCN,
	OILF,
	OILJ,
	OILP,
	OILQ,
	OILR,
	OILT,
	OILW,
	OVF,
	PAL,
	PAN,
	PANS,
	PASS,
	PCL,
	PCLD,
	PCLF,
	PCLI,
	PCLIX,
	PCLS,
	PEAT,
	PEN,
	PENX,
	PGDA,
	PIER,
	PK,
	PKLT,
	PKS,
	PKSU,
	PKU,
	PLAT,
	PLATX,
	PLDR,
	PLFU,
	PLN,
	PLNU,
	PLNX,
	PLTU,
	PMPO,
	PMPW,
	PND,
	PNDI,
	PNDN,
	PNDNI,
	PNDS,
	PNDSF,
	PNDSI,
	PNDSN,
	PNLU,
	PO,
	POOL,
	POOLI,
	PP,
	PPL,
	PPLA,
	PPLA2,
	PPLA3,
	PPLA4,
	PPLC,
	PPLF,
	PPLL,
	PPLQ,
	PPLR,
	PPLS,
	PPLW,
	PPLX,
	PPQ,
	PRK,
	PRKGT,
	PRKHQ,
	PRMN,
	PRN,
	PRNJ,
	PRNQ,
	PROM,
	PRSH,
	PRT,
	PRVU,
	PS,
	PSH,
	PSTB,
	PSTC,
	PSTP,
	PT,
	PTGE,
	PTS,
	PYR,
	PYRS,
	QCKS,
	QUAY,
	RAVU,
	RCH,
	RD,
	RDA,
	RDB,
	RDCUT,
	RDGB,
	RDGE,
	RDGG,
	RDGU,
	RDJCT,
	RDST,
	RDSU,
	RECG,
	RECR,
	REG,
	REP,
	RES,
	RESA,
	RESF,
	RESH,
	RESN,
	RESP,
	RESV,
	RESW,
	RF,
	RFC,
	RFSU,
	RFU,
	RFX,
	RGN,
	RGNE,
	RGNL,
	RHSE,
	RISU,
	RJCT,
	RK,
	RKFL,
	RKRY,
	RKS,
	RLG,
	RLGR,
	RMPU,
	RNCH,
	RNGA,
	RNGU,
	RPDS,
	RR,
	RRQ,
	RSD,
	RSGNL,
	RSRT,
	RSTN,
	RSTNQ,
	RSTP,
	RSTPQ,
	RSV,
	RSVI,
	RSVT,
	RTE,
	RUIN,
	RVN,
	RYD,
	SALT,
	SAND,
	SBED,
	SBKH,
	SCH,
	SCHA,
	SCHC,
	SCHM,
	SCHN,
	SCHT,
	SCNU,
	SCRB,
	SCRP,
	SCSU,
	SD,
	SDL,
	SDLU,
	SEA,
	SHFU,
	SHLU,
	SHOL,
	SHOR,
	SHPF,
	SHRN,
	SHSE,
	SHSU,
	SHVU,
	SILL,
	SILU,
	SINK,
	SLCE,
	SLID,
	SLP,
	SLPU,
	SMSU,
	SMU,
	SNOW,
	SNTR,
	SPA,
	SPIT,
	SPLY,
	SPNG,
	SPNS,
	SPNT,
	SPRU,
	SPUR,
	SQR,
	ST,
	STBL,
	STDM,
	STKR,
	STLMT,
	STM,
	STMA,
	STMB,
	STMC,
	STMD,
	STMH,
	STMI,
	STMIX,
	STMM,
	STMQ,
	STMS,
	STMSB,
	STMX,
	STNB,
	STNC,
	STNE,
	STNF,
	STNI,
	STNM,
	STNR,
	STNS,
	STNW,
	STPS,
	STRT,
	SWMP,
	SWT,
	SYSI,
	TAL,
	TERR,
	TERU,
	TMB,
	TMPL,
	TMSU,
	TMTU,
	TNGU,
	TNKD,
	TNL,
	TNLC,
	TNLN,
	TNLRD,
	TNLRR,
	TNLS,
	TOWR,
	TRANT,
	TRB,
	TREE,
	TRGD,
	TRGU,
	TRIG,
	TRL,
	TRMO,
	TRNU,
	TRR,
	TUND,
	UPLD,
	USGE,
	VAL,
	VALG,
	VALS,
	VALU,
	VALX,
	VETF,
	VIN,
	VINS,
	VLC,
	VLSU,
	WAD,
	WADB,
	WADJ,
	WADM,
	WADS,
	WADX,
	WALL,
	WALLA,
	WEIR,
	WHRF,
	WHRL,
	WLL,
	WLLQ,
	WLLS,
	WRCK,
	WTLD,
	WTLDI,
	WTRC,
	WTRH,
	WTRW,
	XCINE,
	XCONT,
	XDICE,
	XLIB,
	XMALL,
	XNITE,
	XPERF,
	XPLAT,
	XPUB,
	XREST,
	ZN,
	ZNB,
	ZNF,
	ZNL,
	ZOO,
	ZZZZZ
}

struct TLocation {
	1: string viewBoxDerivation;
	2: TPaths paths;
	3: string name;
	4: string id;
	5: TCentroid point;
	6: i32 population;
	7: string type;
	8: TBBox viewBox;
	9: optional string FIPSCode;
}

struct TQueries {
	1: string geoRef;
	2: double confidence;
	3: list<TLocation> locations;
}

struct TLocationFinderResult {
	1: optional list<string> warnings;
	2: optional list<string> errors;
	3: optional list<TLocation> locations;
	4: TBBox viewBox;
}

struct TQueryParserResult {
	1: optional list<string> warnings;
	2: optional list<string> errors;
	3: optional list<TQueries> queries;
	4: TBBox viewBox;
}

service GeospatialExtractorService extends EzBakeBase.EzBakeBaseService {
	/**
	 * Extract places in a given document based on language
	 */
	list<Place> extractPlacesBasedonLanguage(1: string text, 2: DocumentLanguage docLanguage);

	/**
	 * Extract places in a given document
	 */
	list<Place> extractPlaces(1: string text);

	/**
	 * Returns number of tagged documents in geo tagger
	 */
	i64 getGeoTagDocumentCounts();

	/**
	 * Returns list of languages supported by geo tagger
	 */
	list<Language> getSupportedLanguages();

	/**
	 * Returns list of character sets supported by geo tagger
	 */
	list<string> getSupportedChartSets();

	/**
	 * Location finder API
	 */
	TLocationFinderResult locationfinder(1: TLocationFinderInput input);

	/**
	 * Location finder API for a Point
	 */
	TLocationFinderResult findLocation(1: TCentroid point, 2: list<TLocationType> locTypes);

	/**
	 * Query Parser API
	 */
	TQueryParserResult queryLocations(1: TQueryParserInput input);
}
