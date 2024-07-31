SRC := ub.c

BIN := ub
ANALYSIS := results.sarif

CODEQL_DB := db
CODEQL_ARTEFACTS := ${CODEQL_DB} _codeql_detected_source_root


all: ${BIN}

${BIN}: ${SRC}
	gcc -o $@ $^

analyse: ${ANALYSIS}

${ANALYSIS}: ${CODEQL_DB}
	codeql database analyze $< \
		--download codeql/cpp-queries@1.0\
		--format=sarif-latest \
		--output=$@

${CODEQL_DB}: ${SRC}
	codeql database create $@ --language=c

clean:
	rm -rf ${BIN} ${ANALYSIS} ${CODEQL_ARTEFACTS}

.PHONEY: all analyse clean
