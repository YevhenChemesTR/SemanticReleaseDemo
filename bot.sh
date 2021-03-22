set -e
option="${1}"
default_version='0.0.0-SNAPSHOT'
next_version="${2:-$default_version}"
case ${option} in
   --prepare)
      ./mvnw \
        -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn -V \
        clean install -Drevision="$next_version"
      ;;
   --publish)
      # Publish Docker in Github Packages
      DOCKER_PKG=docker.pkg.github.com/yevhenchemestr/semanticreleasedemo/semantic-versioning-on-docker-build-and-helm-chart:"$next_version"
      docker login docker.pkg.github.com -u YevhenChemesTR -p "$GITHUB_TOKEN"
      docker tag docker.io/chemesev/semantic-versioning-on-docker-build-and-helm-chart:"$next_version" "$DOCKER_PKG"
      docker push "$DOCKER_PKG"

      # Publish Helm chart in Github Releases
      HELM_CHART_FILE_NAME="semantic-versioning-on-docker-build-and-helm-chart-$next_version.tgz"
      HELM_CHART_FILE_PATH="$(pwd)/target/helm/repo/$HELM_CHART_FILE_NAME"

      helm package $HELM_CHART_FILE_PATH

      echo "Mock publish: $HELM_CHART from $HELM_CHART_FILE_PATH"
      ;;
   *)
      echo "`basename ${0}`:usage: [--prepare] | [--publish]"
      exit 1 # Command to come out of the program with status 1
      ;;
esac