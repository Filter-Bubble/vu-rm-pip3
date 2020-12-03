v_ixa_pipes = 1.1.1
v_text2naf = fa4178d
v_dbpedia_spotlight = 0.7.1
v_ixa_pipe_ned = 062a983
v_ixa_pipe_ned_semver = 1.1.6
v_vua_resources = ef75f30
v_svm_wsd = 8bb5319
v_libsvm = 557d857
v_vuheideltimewrapper = 3762c0e
v_ontotagger = c3796c5
v_vua_srl_dutch_nominal_events = 28b9cff
v_vua_srl_nl = 23a18eb
v_multilingual_factuality = cbad484
v_opinion_miner_deluxePP = 3d99e85
v_event_coreference = master
v_alpino = Alpino-x86_64-Linux-glibc-2.23-git233-sicstus
v_timbl = 02fe87d
v_ticcutils = 89d2dba

# TODO:
# possibly LIBRARY_PATH should contain ${virtualenv}/lib to make find_lib work

virtualenv = ${CURDIR}/env38
pythondir = ./lib/python
javadir = ./lib/java
resourcesdir = ${CURDIR}/lib/resources

patches = ./cfg
downloaddir = ./download
localrepo = ${CURDIR}/download/m2

.PHONY: download ixa-pipes-download

download: ixa-pipes-download ned-ned-download
extract: ixa-pipes-extract ned-extract

WGET = wget -c --verbose
MKDIR = mkdir -p
TARX = tar --checkpoint -zxvf
MVN_BLD = mvn -Dmaven.repo.local=/${localrepo} clean package
MVN_INS = mvn -Dmaven.repo.local=/${localrepo} install:install-file
CLONE = ./git-clone-version.sh


# ixa-pipes
# -----------------------------------------------------
ixa-pipes-download:
	${MKDIR} ${downloaddir}
	${WGET} \
		https://ixa2.si.ehu.es/ixa-pipes/models/ixa-pipes-${v_ixa_pipes}.tar.gz \
		-O ${downloaddir}/ixa-pipes-${v_ixa_pipes}.tar.gz

ixa-pipes-extract:
	${MKDIR} ${javadir}
	${MKDIR} ${resourcesdir}/nerc-models
	${MKDIR} build
	${TARX} ${downloaddir}/ixa-pipes-${v_ixa_pipes}.tar.gz -C build
	mv build/ixa-pipes-${v_ixa_pipes}/*nerc*.jar ${javadir}
	mv build/ixa-pipes-${v_ixa_pipes}/*tok*.jar ${javadir}
	mv build/ixa-pipes-${v_ixa_pipes}/nerc-models*/nl/*.bin ${resourcesdir}/nerc-models/
	rm -rf build


# ned
# -----------------------------------------------------
spotlight-download:
	${MKDIR} ${downloaddir}
	${WGET} https://sourceforge.net/projects/dbpedia-spotlight/files/2016-04/nl/model/nl.tar.gz -O ${downloaddir}/nl.tar.gz
	${WGET} https://sourceforge.net/projects/dbpedia-spotlight/files/spotlight/dbpedia-spotlight-${v_dbpedia_spotlight}.jar \
		-O ${downloaddir}/dbpedia-spotlight-${v_dbpedia_spotlight}.jar

spotlight-extract:
	dest = ${resourcesdir}/spotlight
	${MKDIR} ${dest}
	${TARX} ${downloaddir}/nl.tar.gz -C ${dest}

spotlight-install:
	${MKDIR} ${javadir}
	${MVN_INS} \
		-Dfile=${downloaddir}/dbpedia-spotlight-${v_dbpedia_spotlight}.jar \
		-DgroupId=org.dbpedia.spotlight \
	  -DartifactId=spotlight \
	  -Dversion=${v_dbpedia_spotlight} \
	  -Dpackaging=jar \
	  -DgeneratePom=true

ned-download:
	${MKDIR} ${downloaddir}
	${WGET} https://ixa2.si.ehu.es/ixa-pipes/models/wikipedia-db.tar.gz -O ${downloaddir}/wikipedia-db.tar.gz
	${CLONE} https://github.com/ixa-ehu/ixa-pipe-ned.git ${v_ixa_pipe_ned} ${downloaddir}/ixa-pipe-ned

ned-extract:
	dest = ${resourcesdir}/spotlight
	${MKDIR} ${dest}
	${TARX} ${downloaddir}/wikipedia-db.tar.gz -C ${dest}

ned-build: spotlight-install
	-patch --forward -p0 -i ${patches}/ixa_pipe_ned.patch
	cd ${downloaddir}/ixa-pipe-ned ; ${MVN_BLD}

ned-install:
	${MKDIR} ${javadir}
	cp ${downloaddir}/ixa-pipe-ned/target/ixa-pipe-ned-${v_ixa_pipe_ned_semver}.jar ${javadir}


# text2naf
# -----------------------------------------------------
text2naf-download:
	${MKDIR} ${downloaddir}
	${CLONE} https://github.com/cltl/text2naf.git ${v_text2naf} ${downloaddir}/text2naf

text2naf-build:
	cd ${downloaddir}/text2naf ; ${MVN_BLD}

text2naf-install:
	${MKDIR} ${javadir}
	cp ${downloaddir}/text2naf/target/*jar-with-dependencies.jar ${javadir}


# vua-resources
# -----------------------------------------------------
vua-resources-download:
	${MKDIR} ${downloaddir}
	${CLONE} https://github.com/cltl/vua-resources.git ${v_vua_resources} ${downloaddir}/vua-resources

vua-resources-extract:
	${MKDIR} ${resourcesdir}/vua-resources
	cp ${downloaddir}/vua-resources/Grammatical-words.nl                   ${resourcesdir}/vua-resources
	cp ${downloaddir}/vua-resources/odwn_orbn_gwg-LMF_1.3.xml.gz           ${resourcesdir}/vua-resources
	cp ${downloaddir}/vua-resources/PredicateMatrix.v1.3.txt.role.odwn.gz  ${resourcesdir}/vua-resources
	cp ${downloaddir}/vua-resources/nl-luIndex.xml                         ${resourcesdir}/vua-resources
	cp ${downloaddir}/vua-resources/ili.ttl.gz                             ${resourcesdir}/vua-resources
	cp ${downloaddir}/vua-resources/mapping_eurovoc_skos.label.concept.gz  ${resourcesdir}/vua-resources
	cp ${downloaddir}/vua-resources/source.txt                             ${resourcesdir}/vua-resources


# wsd
# -----------------------------------------------------
wsd-download:
	${MKDIR} ${downloaddir}
	# NOTE: there are issues with the certificate
	${WGET} --no-check-certificate \
	 	https://kyoto.let.vu.nl/~izquierdo/public/models_wsd_svm_dsc.tgz \
		-O ${downloaddir}/models_wsd_svm_dsc.tgz
	${CLONE} https://github.com/cjlin1/libsvm.git ${v_libsvm} ${downloaddir}/libsvm
	${CLONE} https://github.com/cltl/svm_wsd.git ${v_svm_wsd} ${downloaddir}/svm_wsd

wsd-extract:
	${MKDIR} ${resourcesdir}/svm_wsd
	${TARX} ${downloaddir}/models_wsd_svm_dsc.tgz -C ${resourcesdir}/svm_wsd

wsd-build:
	cd ${downloaddir}/libsvm ; make lib
	-cat ${patches}/svm_wsd.patch | sed "s=\$${resourcesdir}=${resourcesdir}=" | patch --forward -p0 
	-patch --forward -p0 -i ${patches}/libsvm.patch 

wsd-install:
	${MKDIR} ${pythondir}/svm_wsd/lib
	cp ${downloaddir}/svm_wsd/dsc_wsd_tagger.py ${pythondir}/svm_wsd
	cp ${downloaddir}/libsvm/python/* ${pythondir}/svm_wsd
	cp ${downloaddir}/libsvm/libsvm.so.2 ${virtualenv}/lib
	ln -s ${downloaddir}/libsvm/libsvm.so ${downloaddir}/libsvm/libsvm.so


# vuheideltimewrapper
# -----------------------------------------------------
vuheideltimewrapper-download:
	${MKDIR} ${downloaddir}
	${CLONE} https://github.com/cltl/vuheideltimewrapper.git ${v_vuheideltimewrapper} ${downloaddir}/vuheideltimewrapper

vuheideltimewrapper-extract:
	${MKDIR} ${resourcesdir}/vuheideltimewrapper
	cp ${downloaddir}/vuheideltimewrapper/lib/alpino-to-treetagger.csv ${resourcesdir}/vuheideltimewrapper
	cp ${downloaddir}/vuheideltimewrapper/conf/config.props ${resourcesdir}/vuheideltimewrapper

vuheideltimewrapper-build:
	cd ${downloaddir}/vuheideltimewrapper ; ${MVN_BLD}

vuheideltimewrapper-install:
	cp ${downloaddir}/vuheideltimewrapper/target/vu-heideltime-wrapper-1.0-jar-with-dependencies.jar ${javadir}


# ontotagger
# -----------------------------------------------------
ontotagger-download:
	${MKDIR} ${downloaddir}
	${CLONE} https://github.com/cltl/OntoTagger.git ${v_ontotagger} ${downloaddir}/OntoTagger

ontotagger-build:
	cd ${downloaddir}/OntoTagger; ${MVN_BLD}

ontotagger-install:
	cp ${downloaddir}/OntoTagger/target/ontotagger-v3.1.1-jar-with-dependencies.jar ${javadir}


# vua-srl-dutch-nominal-events
# -----------------------------------------------------?
vua-srl-dutch-nominal-events-download:
	${MKDIR} ${downloaddir}
	${CLONE} https://github.com/sarnoult/vua-srl-dutch-nominal-events.git \
		${v_vua_srl_dutch_nominal_events} \
		${downloaddir}/vua-srl-dutch-nominal-events

vua-srl-dutch-nominal-events-build:
	-patch --forward -p0 -i ${patches}/vua-srl-nominal-events.patch

vua-srl-dutch-nominal-events-install:
	${MKDIR} ${pythondir}/vua-srl-dutch-nominal-events
	cp ${downloaddir}/vua-srl-dutch-nominal-events/vua-srl-dutch-additional-roles.py  ${pythondir}/vua-srl-dutch-nominal-events


# vua-srl-nl 
# NOTES: 
#  * resources in ${pythondir}/vua-srl-nl
# -----------------------------------------------------
vua-srl-nl-download:
	${MKDIR} ${downloaddir}
	${CLONE} https://github.com/sarnoult/vua-srl-nl.git \
		${v_vua_srl_nl} \
		${downloaddir}/vua-srl-nl
	${CLONE} https://github.com/LanguageMachines/ticcutils.git \
		${v_ticcutils} \
		${downloaddir}/ticcutils
	${CLONE} https://github.com/LanguageMachines/timbl.git \
		${v_timbl} \
		${downloaddir}/timbl

vua-srl-build:
	cd ${downloaddir}/ticcutils ; bash bootstrap.sh ; ./configure --prefix=${virtualenv} ; make ; make install
	cd ${downloaddir}/timbl ; bash bootstrap.sh ; ./configure --prefix=${virtualenv} ; make ; make install

vua-srl-nl-install:
	${MKDIR} ${pythondir}/vua-srl-nl
	cp ${downloaddir}/vua-srl-nl/* ${pythondir}/vua-srl-nl/


# multilingual_factuality
# NOTES:
#  * resources in ${pythondir}/multilingual_factuality/resources
# -----------------------------------------------------
multilingual_factuality-download:
	${MKDIR} ${downloaddir}
	${CLONE} \
		https://github.com/cltl/multilingual_factuality.git \
	 	${v_multilingual_factuality} \
		${downloaddir}/multilingual_factuality

multilingual_factuality-install:
	${MKDIR} ${pythondir}/multilingual_factuality
	cp -r ${downloaddir}/multilingual_factuality/* ${pythondir}/multilingual_factuality/


# opinion-miner
# NOTES:
#  * use tag_file.py -f ${resourcesdir}/opinion-miner
#  
#  TODO:
#  polarity models?
# -----------------------------------------------------
opinion-miner-download:
	${MKDIR} ${downloaddir}
	${CLONE} \
		https://github.com/rubenIzquierdo/opinion_miner_deluxePP.git \
		${v_opinion_miner_deluxePP} \
		${downloaddir}/opinion_miner_deluxePP
	${WGET} \
		http://kyoto.let.vu.nl/~izquierdo/public/models_opinion_miner_deluxePP/hotel/models_hotel_nl.tgz \
		-O ${downloaddir}/models_hotel_nl.tgz 
	${WGET} \
		http://kyoto.let.vu.nl/~izquierdo/public/models_opinion_miner_deluxePP/news/models_news_nl.tgz \
		-O ${downloaddir}/models_news_nl.tgz 
	${WGET} \
		http://kyoto.let.vu.nl/~izquierdo/public/models_opinion_miner_deluxePP/model_nl_hotel_news.tgz \
		-O ${downloaddir}/model_nl_hotel_news.tgz 
	${WGET} \
		http://kyoto.let.vu.nl/~izquierdo/public/polarity_models.tgz \
		-O ${downloaddir}/polarity_models.tgz
	${WGET} \
		http://download.joachims.org/svm_light/current/svm_light.tar.gz \
		-O ${downloaddir}/svm_light.tar.gz

opinion-miner-extract:
	${MKDIR} ${resourcesdir}/opinion-miner-deluxPP
	${TARX} ${downloaddir}/models_hotel_nl.tgz -C ${resourcesdir}/opinion-miner-deluxPP
	${TARX} ${downloaddir}/models_news_nl.tgz -C ${resourcesdir}/opinion-miner-deluxPP
	${TARX} ${downloaddir}/model_nl_hotel_news.tgz -C ${resourcesdir}/opinion-miner-deluxPP
	${TARX} ${downloaddir}/polarity_models.tgz -C ${resourcesdir}/opinion-miner-deluxPP

opinion-miner-build:
	# dependency: CRF++
	${MKDIR} build
	${TARX} ${downloaddir}/opinion_miner_deluxePP/crf_lib/CRF++-0.58.tar.gz -C build
	cd build/CRF++-0.58 ; ./configure --prefix=${virtualenv} ; make ; make install
	rm -rf build
	# dependency: svm_light
	${MKDIR} build
	${TARX} ${downloaddir}/svm_light.tar.gz -C build
	-patch --forward -p0 -i ${patches}/svm_light.patch
	cd build ; make
	cp build/svm_learn build/svm_classify ${virtualenv}/bin
	rm -rf build 
	# Opinion miner itself
	${MKDIR} ${pythondir}/opinion-miner-deluxPP
	-patch --forward -p0 -i ${patches}/opinion_miner_deluxePP.patch

opinion-miner-install:
	cp ${downloaddir}/opinion_miner_deluxePP/*py ${pythondir}/opinion-miner-deluxPP


# event-coreference
# -----------------------------------------------------
event-coreference-download:
	${MKDIR} ${downloaddir}
	${CLONE} https://github.com/Filter-Bubble/EventCoreference.git ${v_event_coreference} ${downloaddir}/EventCoreference

event-coreference-build:
	cd ${downloaddir}/EventCoreference; ${MVN_BLD}

event-coreference-install:
	${MKDIR} ${javadir}/naf2sem
	cp ${downloaddir}/EventCoreference/target/EventCoreference-v3.1.2-jar-with-dependencies.jar ${javadir}
	cp ${downloaddir}/EventCoreference/scripts/jena-log4j.properties ${javadir}/naf2sem/


# stanza
# -----------------------------------------------------
stanza-postinstall:
	python -c 'import stanza; stanza.download("nl")'


# e2e-Dutch
# -----------------------------------------------------
e2s-dutch-postinstall:
	# TODO: download models, the setup_all.sh is not installed via pip.


# alpino
# -----------------------------------------------------
alpino-download:
	${WGET} http://www.let.rug.nl/vannoord/alp/Alpino/versions/binary/${v_alpino}.tar.gz -O ${downloaddir}/${v_alpino}.tar.gz

alpino-install:
	${MKDIR} build
	${TARX} ${downloaddir}/${v_alpino}.tar.gz -C build
	rm -rf ${resourcesdir}/Alpino
	rm -rf \
		build/Alpino/Treebank \
		build/Alpino/TreebankTools \
		build/Alpino/Tokenization \
		build/Alpino/Generation
	mv build/Alpino ${resourcesdir}/Alpino
	rm -rf build

