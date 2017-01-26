#!/bin/sh

## override environment variables defined in setenv.sh if there is one
pushd ${SPDM_HOME}/spdm-main/bin
if [ -r ./setenv.sh ]; then
   . ./setenv.sh
fi
popd

simulated_types=( \
   [0]=STUF \
   [1]=ICE_SCLK \
   [2]=AntPosition \
   [3]=SpiceAntennaAzimuth \
   [4]=L0A_Radar \
   [5]=L0B_Radar \
   [6]=L1A_Radar \
   [7]=L1C_S0_HiRes \
   [8]=L0A_Radiometer \
   [9]=L0B_Radiometer \
   [10]=L1A_Radiometer \
   [11]=L1B_TB \
   [12]=L1C_TB \
   [13]=L2_SM_A \
   [14]=L2_SM_P \
   [15]=L2_SM_AP \
   [16]=L1B_S0_LoRes \
   [17]=L2_FT_A \
   [18]=PP_Log \
   [19]=PP_QA \
   [20]=L0A_ECS \
   [21]=L0A_Log \
   [22]=QA \
   [23]=Log \
   [24]=ISO_Metadata \
   [25]=CAL_ST \
   [26]=CAL_LT_HIRES \
   [27]=CAL_LT_LORES \
   [28]=CAL_LT_LORES_LIST \
   [29]=CAL_LT_HIRES_LIST \
   [30]=RunConfig \
   [31]=SNOW \
   [32]=TSURF \
   [33]=PRECIP \
   [34]=SNOW_EXT \
   [35]=GEOS_TAVG3_ASM \
   [36]=GEOS_INST1_ASM \
   [37]=L3_SM_A \
   [38]=L3_SM_P \
   [39]=L3_SM_AP \
   [40]=L3_FT_A \
   [41]=BETA_PARAM \
   [42]=L3_SM_COMPOSITE \
   [43]=L3_SM_COMPOSITE_LIST \
   [44]=NDVI_LIST \
   [45]=GBTS \
   [46]=SpiceSpacecraftTrajectory \
   [47]=GEOS_INST3_ASM \
   [48]=GEOS_INST3_FCST \
   [49]=TotalElectronContent \
   [50]=SolarRadioFlux \
   [51]=SpiceSpacecraftAttitude \
   [52]=SpiceSCLK \
   [53]=SpiceEarthOrientation \
   [54]=PP_ISO_Metadata \
   [55]=NCEP_GFS_ASM \
   [56]=NCEP_GFS_FCST \
   [57]=WAVE_HEIGHT_ASM \
   [58]=WAVE_HEIGHT_FCST \
   [59]=SeaSurfSalinity \
   [60]=SeaSurfTemp \
   [61]=AntarcticIceTemp \
   [62]=L1B_TB_RFICAL \
   [63]=LUTHistory \
   [64]=L3_FT_P \
   [65]=L1B_TB_E \
   [66]=L1C_TB_E \
   [67]=L3_FT_P_E \
   [68]=L2_SM_P_E \
   [69]=L3_SM_P_E \
   [70]=L2_S0_S1
   [71]=L2_SM_SP
   [72]=S1_INTENS
   [73]=L2_S0_S1_TC
   [74]=S1_NOISE_CAL
   [75]=SOIL_TEXTURE
   [76]=SURFACE_ROUGHNESS_COEFF
   [77]=URBAN_FRACTION
   [78]=WATER_FRACTION
   [79]=SNOW_DEFAULT
   [80]=PRECIP_DEFAULT
   
)

pushd ${SPDM_HOME}/spdm-main/bin/test/utilities

# Remove simulated outputs
for (( i = 0; i < ${#simulated_types[@]}; i++))
do
    echo "Removing all products of type '${simulated_types[i]}' from catalog"
    sh removeByTypeFromCatalog.sh ${simulated_types[i]}
done

popd

sh level1Pipeline_testSetup.sh
sh level2Pipeline_testSetup.sh
sh level3Pipeline_testSetup.sh
sh sentinelPipeline_testSetup.sh

username=${FILEMGR_DB_USER}
password=${FILEMGR_DB_PASS}

sqlplus $username/$password@${DB_HOST}:${DB_PORT}/${DB_INSTANT}.JPL.NASA.GOV << EOF
delete from ORBITS;
truncate table LUT_HISTORY;
truncate table ORBITSSTATUS;
truncate table DAILYSTATUS;
/
EOF
