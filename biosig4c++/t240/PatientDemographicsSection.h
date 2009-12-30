/*
 * Generated by asn1c-0.9.21 (http://lionet.info/asn1c)
 * From ASN.1 module "FEF-IntermediateDraft"
 * 	found in "../annexb-snacc-122001.asn1"
 */

#ifndef	_PatientDemographicsSection_H_
#define	_PatientDemographicsSection_H_


#include <asn_application.h>

/* Including external dependencies */
#include "Handle.h"
#include "FEFString.h"
#include "PatientSex.h"
#include "PatientRace.h"
#include "PatientType.h"
#include "AbsoluteTime.h"
#include "HandleRef.h"
#include <asn_SEQUENCE_OF.h>
#include <constr_SEQUENCE_OF.h>
#include <constr_SEQUENCE.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Forward declarations */
struct PersonNameGroup;
struct PatMeasure;
struct PersonName;
struct ExtNomenRef;

/* PatientDemographicsSection */
typedef struct PatientDemographicsSection {
	Handle_t	 handle;
	FEFString_t	*patientid	/* OPTIONAL */;
	FEFString_t	*ungroupedname	/* OPTIONAL */;
	struct PersonNameGroup	*characternamegroup	/* OPTIONAL */;
	struct PersonNameGroup	*ideographicnamegroup	/* OPTIONAL */;
	struct PersonNameGroup	*phoneticnamegroup	/* OPTIONAL */;
	FEFString_t	*birthname	/* OPTIONAL */;
	PatientSex_t	*sex	/* OPTIONAL */;
	PatientRace_t	*race	/* OPTIONAL */;
	PatientType_t	*patienttype	/* OPTIONAL */;
	AbsoluteTime_t	*dateofbirth	/* OPTIONAL */;
	FEFString_t	*patientgeninfo	/* OPTIONAL */;
	struct PatMeasure	*patientage	/* OPTIONAL */;
	struct PatMeasure	*gestationalage	/* OPTIONAL */;
	struct PatMeasure	*patientheight	/* OPTIONAL */;
	struct PatMeasure	*patientweight	/* OPTIONAL */;
	struct PatMeasure	*patientbirthlength	/* OPTIONAL */;
	struct PatMeasure	*patientbirthweight	/* OPTIONAL */;
	FEFString_t	*motherpatientid	/* OPTIONAL */;
	struct PersonName	*mothername	/* OPTIONAL */;
	struct PatMeasure	*patientheadcircumference	/* OPTIONAL */;
	struct PatMeasure	*patientbsa	/* OPTIONAL */;
	FEFString_t	*bedid	/* OPTIONAL */;
	FEFString_t	*diagnosticinfo	/* OPTIONAL */;
	struct PatientDemographicsSection__diagnosticcodes {
		A_SEQUENCE_OF(struct ExtNomenRef) list;
		
		/* Context for parsing across buffer boundaries */
		asn_struct_ctx_t _asn_ctx;
	} *diagnosticcodes;
	HandleRef_t	*admittingphysician	/* OPTIONAL */;
	HandleRef_t	*attendingphysician	/* OPTIONAL */;
	AbsoluteTime_t	*dateofprocedure	/* OPTIONAL */;
	FEFString_t	*proceduredescription	/* OPTIONAL */;
	struct PatientDemographicsSection__procedurecodes {
		A_SEQUENCE_OF(struct ExtNomenRef) list;
		
		/* Context for parsing across buffer boundaries */
		asn_struct_ctx_t _asn_ctx;
	} *procedurecodes;
	HandleRef_t	*anaesthetist	/* OPTIONAL */;
	HandleRef_t	*surgeon	/* OPTIONAL */;
	
	/* Context for parsing across buffer boundaries */
	asn_struct_ctx_t _asn_ctx;
} PatientDemographicsSection_t;

/* Implementation */
extern asn_TYPE_descriptor_t asn_DEF_PatientDemographicsSection;

#ifdef __cplusplus
}
#endif

/* Referred external types */
#include "PersonNameGroup.h"
#include "PatMeasure.h"
#include "PersonName.h"
#include "ExtNomenRef.h"

#endif	/* _PatientDemographicsSection_H_ */