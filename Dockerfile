FROM google/dart:2.7

WORKDIR /app
ADD pubspec.* /app/
RUN pub get
ADD . /app/
RUN pub get --offline

WORKDIR /app
EXPOSE 80

ENTRYPOINT []