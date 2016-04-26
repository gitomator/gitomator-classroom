#! /bin/sh

cd
git clone $GITOMATOR_RESOURCES/solution
git clone $GITOMATOR_RESOURCES/automarker

cd solution
mvn install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -B -V
cd

cd automarker
mvn clean
mvn test -B
cd

cp -r automarker/target/surefire-reports $GITOMATOR_RESULTS/
cd
