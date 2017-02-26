#!/bin/bash

# 100 - Population gen_acs_100.sh
# prerequisites
# - indices on all geometry columns
# - all files in same (final) projection
# - already cut by geographic boundaries & grid cells

#SG: surrogate generation
#surg_code 		# SG.csv: SURROGATE_CODE, ie, 100...
#dbname 			# SC.csv: DBNAME, Name of database to store loaded table
#data_attribute		# SS.csv: DATA ATTRIBUTEField containing unique ID for each record in the GEOG_BNDRY_TBL
#weight_attribute	# SS.csv: WEIGHT ATTRIBUTE
#schema_name		# SC.csv: SCHEMA_NAME, Name of schema stored loaded table
#srid_final=900921	# SC.csv: SRID_FINAL, Final srid for common projection of processed files
#region=USA		# SS.csv: REGION
#surrogate_path 	# control.csv: OUTPUT DIRECTORY, bash scripts, output surrogate, logs 
#logfile             # output logs 


export surg_code=100					# SG.csv: SURROGATE_CODE
export dbname=surrogates				# SC.csv: DBNAME
export data_attribute=geoid				# SS.csv: DATA ATTRIBUTE
export weight_attribute=pop2014				# SS.csv: WEIGHT ATTRIBUTE
export schema_name=ppgsa_12km				# SC.csv: SCHEMA_NAME
export srid_final=900921				# SC.csv: SRID_FINAL
export region=USA					# SS.csv: REGION
export surrogate_path=/opt/surrogates/scripts/PGSA_scripts/PGgrid_12km_scripts/ 	#SScsv: SURROGATE_PATH, 
export logfile=gen_acs_100.log

echo "Surrogate 100 begins." >> ${logfile}
psql -a ${dbname} << END0 >> ${logfile}
DROP TABLE IF EXISTS ${schema_name}.denom_${surg_code};
DROP TABLE IF EXISTS ${schema_name}.numer_${surg_code};
DROP TABLE IF EXISTS ${schema_name}.surg_${surg_code};
END0


psql -a ${dbname} << END1 >> ${logfile}
CREATE TABLE ${schema_name}.denom_${surg_code} (${data_attribute} varchar (6) not null,
	denom integer default 0,
	primary key (${data_attribute}));

insert into ${schema_name}.denom_${surg_code}
SELECT ${data_attribute},
       ${weight_attribute} AS denom
  FROM ${schema_name}.acs2014_denom_${srid_final};
END1
  
export vac_dbname=${dbname}
export vac_schema=${schema_name}
export vac_table=denom_${surg_code}

./vacanalyze.sh

psql -a ${dbname} << END2 >>${logfile}
CREATE TABLE ${schema_name}.numer_${surg_code} (${data_attribute} varchar (6) not null,
	colnum integer not null,
	rownum integer not null,
	numer integer default 0,
	primary key (${data_attribute}, colnum, rownum));

insert into ${schema_name}.numer_${surg_code}
SELECT ${data_attribute},
       colnum,
       rownum,
       SUM(${weight_attribute}) AS numer
  FROM ${schema_name}.acs_cty_cell_${srid_final}
 GROUP BY ${data_attribute}, colnum, rownum;
END2

export vac_dbname=${dbname}
export vac_schema=${schema_name}
export vac_table=numer_${surg_code}

./vacanalyze.sh


psql -a ${dbname} << END3 >>${logfile}
CREATE TABLE ${schema_name}.surg_${surg_code} (surg_code integer not null,
	${data_attribute} varchar (6) not null,
	colnum integer not null,
	rownum integer not null,
	surg double precision,
	numer integer,
	denom integer,
	primary key (${data_attribute}, colnum, rownum));

insert into ${schema_name}.surg_${surg_code}
SELECT CAST('$surg_code' AS INTEGER) AS surg_code,
       d.${data_attribute},
       colnum,
       rownum,
       CAST( numer as double precision) / CAST( denom as double precision) AS surg,
       numer,
       denom
  FROM ${schema_name}.numer_${surg_code} n
  JOIN ${schema_name}.denom_${surg_code} d
 USING (${data_attribute})
 WHERE numer != 0
   AND denom != 0
 GROUP BY d.${data_attribute}, colnum, rownum, numer, denom
 ORDER BY d.${data_attribute}, colnum, rownum;

END3
 
export vac_dbname=${dbname}
export vac_schema=${schema_name}
export vac_table=surg_${surg_code}

./vacanalyze.sh

echo "ready to write surrogate file" >> ${logfile}
echo "#GRID" > ${surrogate_path}${region}_${surg_code}_NOFILL.txt >>${logfile}		# NEED TO PUT HEADER HERE
psql -F $'\t' -t -a --no-align ${dbname} << ENDS >> ${region}_${surg_code}_NOFILL.txt 

select surg_code, ${data_attribute}, colnum, rownum, surg, '!', numer, denom
	from ${schema_name}.surg_${surg_code}
	order by geoid, colnum, rownum;
ENDS
echo "Surrogate 100 ends." >> ${logfile}
