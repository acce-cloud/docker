#!/bin/sh
export release=1.4.2

if [ -z $SPDM_HOME ] ; then
   echo "Please setenv SPDM_HOME"
   exit 1
fi

mkdir spdm-${release}
for i in *.tar.gz
do
   (cd spdm-${release}; tar xvfz ../$i)
done



if [ -d $SPDM_HOME/spdm-$release ] ; then
   mv ${SPDM_HOME}/spdm-${release} ${SPDM_HOME}/spdm-${release}-`date "+%Y%m%d%H%M"`
fi

mv spdm-${release} ${SPDM_HOME}

for i in common filemgr sips crawler pge resource workflow ws webapp main
do
   if [ -h ${SPDM_HOME}/spdm-$i ] ; then   
	rm ${SPDM_HOME}/spdm-$i
   fi
   ln -s ${SPDM_HOME}/spdm-${release}/spdm-$i-$release ${SPDM_HOME}/spdm-$i
#   if [ ! -d ${SPDM_HOME}/spdm-$i/logs ] ; then
#	   mkdir ${SPDM_HOME}/spdm-$i/logs
#   fi
done

# Sorry for the blatant hack
echo Copying the following files to Resource Manager lib:
ls ${SPDM_HOME}/spdm-${release}/spdm-workflow-$release/lib/spdm-workflow*.jar
cp ${SPDM_HOME}/spdm-${release}/spdm-workflow-$release/lib/spdm-workflow*.jar ${SPDM_HOME}/spdm-${release}/spdm-resource-$release/lib

# Configure spdm-ws/web.xml host
#
pushd ${SPDM_HOME}/spdm-ws
   jar xvf spdm-ws/spdm-ws-${release}.war
popd

echo [INFO] -----------------------------------------------------------------------------------------------------
echo [INFO] spdm ${release} is now installed at $SPDM_HOME/spdm-${release}
echo [INFO] set up SPDM instance configuration in $SPDM_HOME/spdm-main/bin/setenv.sh
echo [INFO] sh configure.sh to check the SPDM directory layout and change configuration for spdm-ws and spdm-webapp
echo [INFO] -----------------------------------------------------------------------------------------------------
