
# Make sure Maven doesn't download the internet for each handout ...
# NOTE: We're copying the dependencies, because we want the local Maven repo to
#       be r/w (and the mounted dependencies are read-only).
#       It's a bit slow, but it's still much better than downloading everything
#       from the internet.
MAVEN_CACHE=/root/resources/maven-cache
if [ -d "$MAVEN_CACHE" ]; then
  echo "Copying cached Maven dependencies to ~/.m2/repository/"
  mkdir -p ~/.m2/repository
  cp -r $MAVEN_CACHE/* ~/.m2/repository/
fi



echo "Clone a temporary clone of the student's solution ..."
git clone $GITOMATOR_RESOURCES/solution
cd solution

# Make sure we're at the tip of the master branch
git checkout master


if [ -z "$ASSIGNMENT_DEADLINE" ]; then
  echo "Missing ASSIGNMENT_DEADLINE env (UTC time in 'YYYY-MM-DD HH:MM' format)"
  exit 255
else
  echo "Check out latest commit before the deadline"
  echo "Checkout commit `git log -1 --before="$ASSIGNMENT_DEADLINE" --format=%h`"
  git checkout `git log -1 --before="$ASSIGNMENT_DEADLINE" --format=%h`
fi



# Install the student solution locally, using Maven
echo "Run mvn install on the student's solution"
mvn install -Dmaven.test.skip=true -Dmaven.javadoc.skip=true -B -V
cd ..

echo "Create a temporary clone of the auto-marker repo ..."
git clone $GITOMATOR_RESOURCES/automarker
cd automarker
echo "Run mvn test on the automarker"
# By default, don't let `mvn test` run for more than 120 seconds
TIME_LIMIT_IN_SECONDS=${TIME_LIMIT_IN_SECONDS:-120}
mvn -Dsurefire.timeout=$TIME_LIMIT_IN_SECONDS test -B
cd ..

# echo "Copying surefire reports to the results mounted volume"
cp -R automarker/target/surefire-reports $GITOMATOR_RESULTS/
